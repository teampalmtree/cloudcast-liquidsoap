###########
## QUEUE ##
###########

# queue file loop
add_timeout(fast = false, !queue_poll_delay, poll_queue)

############
## INPUTS ##
############

# input status loop
add_timeout(fast = false, !update_inputs_post_delay, update_inputs)

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

################
## SHOW INPUT ##
################

# create show input
show_input = mksafe(
    audio_to_stereo(
        input.harbor(
            id = "show_input",
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
talkover_input = audio_to_stereo(
    input.harbor(
        id = "talkover_input",
        port = !talkover_input_port,
        auth = authorize_talkover_user,
        buffer = !talkover_input_buffer_seconds,
        max = !talkover_input_buffer_seconds_max,
        on_connect = talkover_input_connect,
        on_disconnect = talkover_input_disconnect,
        'talkover'
    )
)

# eat blanks on the talkover input
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
        input.harbor(
            id = "master_input",
            port = !master_input_port,
            auth = authorize_master_user,
            max = !show_input_buffer_seconds_max,
            on_connect = master_input_connect,
            on_disconnect = master_input_disconnect,
            'master'
        )
    )
)

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

# mix in jingles when:
# - jingles are available (loaded)
# - detect quiet
# - are in the meat of a song
# - have not occurred in a while (ready)
# - are not playing ads
# - and we don't have (talkover input & enabled)
radio := add(normalize = false, [
    !radio,
    switch(
        id = 'jingles_switch', [(
        {
            !jingles_available
            and !quiet_detected
            and !track_meat
            and !jingles_ready
            and not !restricted_playing
            and not (!talkover_input_status and !talkover_input_enabled)
        },
        once(jingles)
    )])
])

##########################
## HOOK INPUTS TOGETHER ##
##########################

# create silence
silence = amplify(0.00001, noise())
# switch radio/silence
radio :=  switch(
    id = 'silence_switch',
    track_sensitive = false,
    [
        ({ !schedule_input_status and !schedule_input_enabled }, !radio),
        ({ true }, silence)
    ]
)

# switch show/radio
radio :=  switch(
    id = 'show_switch',
    track_sensitive = false,
    transitions = [ input_transition, input_transition ],
    [
        ({ !show_input_status and !show_input_enabled }, show_input),
        ({ true }, !radio)
    ]
)

# switch radio+talkover/radio
radio := switch(
    id = 'talkover_switch',
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
    id = 'master_switch',
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
list.iter(initialize_stream, !streams)
