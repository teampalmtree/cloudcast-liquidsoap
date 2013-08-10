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
    # we are in the meat of the song
    track_meat := true
    (-1.)

end

def track_start(m) =

    log("Tracking: Beginning")
    # send file off
    add_timeout(fast = false, 0., play_schedule_file)
    # send stats off
    add_timeout(fast = false, 0., save_stream_statistics)
    # send out metadata updates
    add_timeout(fast = false, 0., update_stream_metadatas)
    # call track start complete
    add_timeout(fast = false, !jingle_start_delay_seconds, track_start_complete)

end

def track_end_complete() =

    log("Tracking: Ending Complete")
    (-1.)

end

def track_end(t, m) =

    # log ending
    log("Tracking: Ending")
    # we are exiting the meat of the song
    track_meat := false

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