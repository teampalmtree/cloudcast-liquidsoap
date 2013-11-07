#####################
## QUIET FUNCTIONS ##
#####################

def quiet_on()
    quiet_detected := true
    log("Tracking: Quiet Detected")
end

def quiet_off()
    quiet_detected := false
    log("Tracking: Noise Detected")
end

#####################
## TRACK FUNCTIONS ##
#####################

def track_start_complete() =

    log("Tracking: Beginning Complete")
    # we are in the meat of the song
    track_meat := true
    (-1.)

end

def track_start(m) =

    # play current queue
    play_current_queue()

    # get the current queue
    the_current_queue = !current_queue
    # get the duration of this file
    current_file_duration_seconds = float_of_string(the_current_queue['file_duration_seconds'])
    # call track start complete
    if current_file_duration_seconds > (!jingle_start_delay_seconds + !jingle_end_padding_seconds) then

        # log track beginning
        log("Tracking: Beginning")
        # call beginning complete soon
        add_timeout(fast = true, !jingle_start_delay_seconds, track_start_complete)

    end

end

def track_end_complete() =
    log("Tracking: Ending Complete")
    (-1.)
end

def track_end(t, m) =

    # if we ran into track meat, process the ending
    if !track_meat then

        # log ending
        log("Tracking: Ending")
        # we are exiting the meat of the song
        track_meat := false
        # call track end complete
        add_timeout(fast = true, !jingle_end_padding_seconds, track_end_complete)

    end

end

def jingle_ready() =

    # allow a jingle to occur now that the timeout has expired
    jingles_ready := true
    log("Tracking: Jingles Ready")
    (-1.)

end

def jingle_end(r, m)

    # prevent this jingle from happening again to soon
    jingles_ready := false
    # call track end complete
    add_timeout(fast = true, !jingle_ready_delay_seconds, jingle_ready)

end