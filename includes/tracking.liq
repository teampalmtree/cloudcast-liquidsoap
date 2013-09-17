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

def track_start_process() =

    # mark schedule file played
    play_schedule_file()
    # save stream stats
    #save_stream_statistics()
    # update stream metadatas
    #update_stream_metadatas()
    # don't repeat
    (-1.)

end

def track_start(m) =

    log("Tracking: Beginning")
    # send file off
    add_timeout(fast = false, 0., track_start_process)
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
    # if the queue is still ready, we are about to go offline
    schedule_input_status := not !queue_file_ready
    # call track end complete
    add_timeout(fast = false, !jingle_end_padding_seconds, track_end_complete)

end

def jingle_end(r, m)
    quiet_detected := false
end