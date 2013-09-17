##########################
## LOAD SCHEDULE PROMOS ##
##########################

def load_promos() =

    # get current queue schedule
    current_queue_schedule = !queue_schedule

    ################################
    ## SWEEPERS (HARSH SONG-SONG) ##
    ################################

    if
        current_queue_schedule['sweepers_available'] == 'true'
    then

        # set sweepers available
        sweepers_available := true
        # get sweepers playlist url
        current_engine_schedule_sweepers_uri = string.replace(pattern = '<show_id>', fun(s) -> current_queue_schedule['show_id'], engine_schedule_sweepers_uri)
        # load sweepers playlist
        sweepers_reload(uri = current_engine_schedule_sweepers_uri)

    else

        # set sweepers unavailable
        sweepers_available := false

    end

    ##################################
    ## JINGLES (OVER QUIET IN SONG) ##
    ##################################

    if
        current_queue_schedule['jingles_available'] == 'true'
    then

        # set jingles available
        jingles_available := true
        # get jingles playlist url
        current_engine_schedule_jingles_uri = string.replace(pattern = '<show_id>', fun(s) -> current_queue_schedule['show_id'], engine_schedule_jingles_uri)
        # load jingles playlist
        jingles_reload(uri = current_engine_schedule_jingles_uri)

    else

        # set jingles unavailable
        jingles_available := false

    end

    #######################
    ## BUMPERS (AD-SONG) ##
    #######################

    if
        current_queue_schedule['bumpers_available'] == 'true'
    then

        # set bumpers available
        bumpers_available := true
        # get bumpers playlist url
        current_engine_schedule_bumpers_uri = string.replace(pattern = '<show_id>', fun(s) -> current_queue_schedule['show_id'], engine_schedule_bumpers_uri)
        # load bumpers playlist
        bumpers_reload(uri = current_engine_schedule_bumpers_uri)

    else

        # set jingles unavailable
        bumpers_available := false

    end

    # log loaded playlists
    log("Promos: Loaded (Sweepers: #{!sweepers_available}, Jingles: #{!jingles_available}, Bumpers: #{!bumpers_available})")

end