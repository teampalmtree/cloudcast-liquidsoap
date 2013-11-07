##################
## LOAD JINGLES ##
##################

def load_jingles() =

    # get the current queue
    the_current_queue = !current_queue
    # get jingles playlist url
    current_engine_schedule_jingles_uri = string.replace(pattern = '<schedule_id>', fun(s) -> the_current_queue['schedule_id'], engine_schedule_jingles_uri)
    # load jingles playlist
    jingles_reload(current_engine_schedule_jingles_uri)
    # log loaded playlists
    log("Jingles: Loaded")
    # don't loop
    (-1.)

end