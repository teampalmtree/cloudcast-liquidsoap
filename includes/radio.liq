###########
## QUEUE ##
###########

# reset queued
reset_queued()
# poll the queue for the initial song
add_timeout(fast = true, !next_queues_poll_delay, poll_next_queues)

############
## INPUTS ##
############

# input status loop
add_timeout(fast = true, !update_inputs_post_delay, update_inputs)

##############
## TRACKING ##
##############

# setup track functions
radio := on_track(track_start, !radio)
radio := on_end(delay = !jingle_end_padding_seconds, track_end, !radio)

#################
## TRANSITIONS ##
#################

# cross fading
radio := cross(duration = !transition_cross_seconds, inhibit = 0., transition, !radio)
# output radio to dummy
output.dummy(fallible = true, !radio)

################
## SHOW INPUT ##
################

# create show input
show_input = audio_to_stereo(
    input.harbor(
        id = "show_input",
        port = !show_input_port,
        auth = authenticate_show,
        max = !input_buffer_seconds_max,
        on_connect = show_input_connect,
        on_disconnect = show_input_disconnect,
        'show'
    )
)

# dummy output to reduce input latency
output.dummy(fallible = true, show_input)

####################
## TALKOVER INPUT ##
####################

# create talkover input
talkover_input = audio_to_stereo(
    input.harbor(
        id = "talkover_input",
        port = !talkover_input_port,
        auth = authenticate_talkover,
        buffer = !input_buffer_seconds,
        max = !input_buffer_seconds_max,
        on_connect = talkover_input_connect,
        on_disconnect = talkover_input_disconnect,
        'talkover'
    )
)

# talkover input quiet detection
talkover_input = on_blank(
    track_sensitive = false,
    threshold = !talkover_quiet_threshold,
    max_blank = !talkover_quiet_seconds,
    min_noise = !talkover_noise_seconds,
    on_noise = activate_talkover_input,
    deactivate_talkover_input,
    talkover_input
)

# eat blanks on the talkover input
talkover_input = strip_blank(
    track_sensitive = false,
    threshold = !talkover_quiet_threshold,
    max_blank = !talkover_quiet_seconds,
    min_noise = !talkover_noise_seconds,
    talkover_input
)

# dummy output to reduce input latency
output.dummy(fallible = true, talkover_input)

##################
## MASTER INPUT ##
##################

# create master input
master_input = audio_to_stereo(
    input.harbor(
        id = "master_input",
        port = !master_input_port,
        auth = authenticate_master,
        max = !input_buffer_seconds_max,
        on_connect = master_input_connect,
        on_disconnect = master_input_disconnect,
        'master'
    )
)

# dummy output to reduce input latency
output.dummy(fallible = true, master_input)

##########################
## HOOK INPUTS TOGETHER ##
##########################

# create loop
loop = single(!loop_file)
# switch radio/loop
radio :=  switch(
    id = 'loop_switch',
    track_sensitive = false,
    [
        ({ !schedule_input_enabled }, !radio),
        ({ true }, loop)
    ]
)

# switch show/radio
radio :=  switch(
    id = 'show_switch',
    track_sensitive = false,
    transitions = [ intro_input_transition, closer_input_transition ],
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
        ({ !talkover_input_status and !talkover_input_enabled and !talkover_input_active },
            add(normalize = false, [
                talkover_input,
                amplify(!talkover_radio_amplification, !radio)
            ])
        ), ({ true }, !radio)
    ]
)

# switch master/radio
radio := switch(
    id = 'master_switch',
    track_sensitive = false,
    transitions = [ intro_input_transition, closer_input_transition ],
    [
        ({ !master_input_status and !master_input_enabled }, master_input),
        ({ true }, !radio)
    ]
)

#############
## JINGLES ##
#############

# add jingles end function
jingles = on_end(delay = 0., jingle_end, jingles)
# quiet detection
radio := on_blank(
    track_sensitive = false,
    threshold = !jingle_quiet_threshold,
    max_blank = !jingle_quiet_seconds,
    min_noise = !jingle_noise_seconds,
    on_noise = quiet_off,
    quiet_on,
    !radio
)

# mix in jingles when:
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
            # always required
            !quiet_detected
            and !jingles_ready
            and not (!talkover_input_status and !talkover_input_enabled)
            and (
                # show/master input requirements
                ((!show_input_status and !show_input_enabled) or (!master_input_status and !master_input_enabled))
                # schedule input requirements
                or (!track_meat and not !restricted_playing)
            )
        },
        jingles
    )])
])

#############
## OUTPUTS ##
#############

# loop over streams to create outputs
list.iter(initialize_stream, !streams)
