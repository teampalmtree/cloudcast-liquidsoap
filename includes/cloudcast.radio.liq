###########
## QUEUE ##
###########

# queue file loop
add_timeout(fast = false, !queue_file_poll_delay, poll_file)

############
## INPUTS ##
############

# input status loop
add_timeout(fast = false, !inputs_post_delay, post_inputs)

##############
## TRACKING ##
##############

# setup track functions
radio := on_track(track_start, !radio)
radio := on_end(delay = !jingle_end_padding_seconds, track_end, !radio)

#################
## TRANSITIONS ##
#################

# calculate transition inhibition
transition_inhibit = !transition_seconds * 2.
# crossfading
radio := smart_cross(conservative = true, width = !transition_width_seconds, duration = !transition_seconds, inhibit = transition_inhibit, transition, !radio)

#############
## JINGLES ##
#############

# add jingles end function
jingles = on_end(delay = 1., jingle_end, jingles)
# quiet detection
radio := on_blank(
    track_sensitive = true,
    threshold = !jingle_quiet_threshold,
    max_blank = !jingle_quiet_seconds,
    min_noise = !jingle_noise_seconds,
    on_noise = quiet_off,
    quiet_on,
    !radio
)

# mix in jingles during quiet (use delay here?)
radio := add(normalize = false, [
    !radio,
    switch([({ !quiet_detected and not !advertisement_playing and not !track_beginning and not !track_ending }, jingles)])
])

################
## SHOW INPUT ##
################

# create show input
show_input = mksafe(
    audio_to_stereo(
        input.harbor(id="show_input",
            port = !show_input_port,
            auth = authorize_show_user,
            max = !show_input_buffer_seconds_max,
            on_connect = show_input_connect,
            on_disconnect = show_input_disconnect,
            'show'
        )
    )
)

####################
## TALKOVER INPUT ##
####################

# create talkover input
talkover_input = mksafe(
    audio_to_stereo(
        input.harbor(id="talkover_input",
            port = !talkover_input_port,
            auth = authorize_talkover_user,
            buffer = !talkover_input_buffer_seconds,
            max = !talkover_input_buffer_seconds_max,
            on_connect = talkover_input_connect,
            on_disconnect = talkover_input_disconnect,
            'talkover'
        )
    )
)

# skip blanks on the talkover input
talkover_input = strip_blank(
    track_sensitive = false,
    threshold = !talkover_quiet_threshold,
    max_blank = !talkover_quiet_seconds,
    min_noise = !talkover_noise_seconds,
    talkover_input
)

##################
## MASTER INPUT ##
##################

# create master input
master_input = mksafe(
    audio_to_stereo(
        input.harbor(id="master_input",
            port = !master_input_port,
            auth = authorize_master_user,
            max = !show_input_buffer_seconds_max,
            on_connect = master_input_connect,
            on_disconnect = master_input_disconnect,
            'master'
        )
    )
)

##########################
## HOOK INPUTS TOGETHER ##
##########################

# create silence
silence = amplify(0.00001, noise())
# switch radio/silence
radio :=  switch(
     track_sensitive = false,
     [
        ({ !schedule_input_status and !schedule_input_enabled }, !radio),
        ({ true }, silence)
    ]
)

# switch show/radio
radio :=  switch(
     track_sensitive = false,
     transitions = [ input_transition, input_transition ],
     [
        ({ !show_input_status and !show_input_enabled }, show_input),
        ({ true }, !radio)
    ]
)

# switch radio+talkover/radio
radio := switch(
    track_sensitive = false,
    transitions = [ talkover_transition, talkover_transition ],
    [
        ({ !talkover_input_status and !talkover_input_enabled and source.is_ready(talkover_input) }, add(normalize = false, [
            talkover_input,
            amplify(!talkover_radio_amplification, !radio)
        ])),
        ({ true }, !radio)
    ]
)

# switch master/radio
radio := switch(
    track_sensitive = false,
    transitions = [ input_transition, input_transition ],
    [
        ({ !master_input_status and !master_input_enabled }, master_input),
        ({ true }, !radio)
    ]
)

#############
## OUTPUTS ##
#############

# loop over streams to create outputs
list.iter(initialize_output, !streams)
