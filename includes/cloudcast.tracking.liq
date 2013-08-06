#####################
## QUIET FUNCTIONS ##
#####################

def quiet_on()
    log("Tracking: Quiet Detected")
    quiet_detected := true
end

def quiet_off()
    quiet_detected := false
end

#####################
## TRACK FUNCTIONS ##
#####################

def track_start_complete() =

    log("Tracking: Beginning Complete")
    track_beginning := false
    (-1.)

end

def track_start(m) =

    log("Tracking: Beginning")
    # update beginning status
    track_beginning := true

    # send file off
    add_timeout(fast = false, 0., post_file)
    # call track start complete
    add_timeout(fast = false, !jingle_start_delay_seconds, track_start_complete)
    # send stats off
    add_timeout(fast = false, 0., post_stream_statistics)

end

def track_end_complete() =

    log("Tracking: Ending Complete")
    track_ending := false
    (-1.)

end

def track_end(t, m) =

    # log ending
    log("Tracking: Ending")
    # update ending status
    track_ending := true

    # if we have nothing in the queue, schedule is not active
    if
        !queue_length == 0.
    then
        schedule_input_status := false
    end

    # call track end complete
    add_timeout(fast = false, !jingle_end_padding_seconds, track_end_complete)

end

def jingle_end(r, m)
    quiet_detected := false
end