##################
## RESET QUEUED ##
##################

def reset_queued() =

    # make a http request to the engine
    ignore(http.get(timeout = !http_timeout, headers = !http_ajax_headers, engine_reset_queued_uri))

end

######################
## POLL NEXT QUEUES ##
######################

# get next queues
def get_next_queues() =

    # make a http request to the engine
    engine_next_queues_response = http.get(timeout = !http_timeout, headers = !http_ajax_headers, engine_next_queues_uri)
    engine_next_queues_response_data = snd(engine_next_queues_response)
    next_queues_json = safe_json(engine_next_queues_response_data)
    log('Queue: Unsafe JSON: #{engine_next_queues_response_data} Safe JSON: #{next_queues_json}')
    # return next queues json parsed
    of_json(default = [[('error', 'failure')]], next_queues_json)

end

# push queue
def push_queue(queue) =

    # push file name to server queue
    ignore(server.execute("schedule.push #{queue['file_name']}"))
    # log file queued
    log("Queue: Added #{queue['file_name']}")

end

# poll next queues
def poll_next_queues() =

    # get queue
    the_next_queues = get_next_queues()
    first_next_queue = list.nth(the_next_queues, 0)
    # determine request to generate
    if first_next_queue['error'] != "failure" then

        ########################
        ## NEXT QUEUES UPDATE ##
        ########################

        # append next queue to queues
        next_queues := list.append(the_next_queues, !next_queues)
        # push all new queues to the schedule
        list.iter(push_queue, the_next_queues)
        # update schedule input status
        schedule_input_status := true

    else

        ##################################
        ## UPDATE SCHEDULE INPUT STATUS ##
        ##################################

        # update schedule input status to offline if no next files
        if list.length(!next_queues) == 0 then
            schedule_input_status := false
        end

    end

    # keep poling
    !next_queues_poll_delay

end

########################
## PLAY CURRENT QUEUE ##
########################

# play schedule file
def play_schedule_file() =

    ###############################
    ## NOTIFY SCHEDULE FILE PLAY ##
    ###############################

    # get updated current queue
    the_current_queue = !current_queue
    # log file played
    log("Queue: Playing #{the_current_queue['file_name']}")
    # generate play schedule file url
    current_engine_play_schedule_file_uri
        = string.replace(pattern = '<schedule_file_id>', fun(s) -> the_current_queue['schedule_file_id'], engine_play_schedule_file_uri)
    # post metadata
    current_engine_play_schedule_file_response = http.get(timeout = !http_timeout, headers = !http_ajax_headers, current_engine_play_schedule_file_uri)
    current_engine_play_schedule_file_response_data = snd(current_engine_play_schedule_file_response)

    ##############################
    ## PLAY RESPONSE VALIDATION ##
    ##############################

    # verify we got a success
    if current_engine_play_schedule_file_response_data == 'SUCCESS' then

        ############################
        ## PROCESS STREAM UPDATES ##
        ############################

        # get current genre
        current_genre = the_current_queue['file_genre']

        if
            # do stream updates for non-promos
            (current_genre != 'Sweeper')
            and (current_genre != 'Bumper')
            and (current_genre != 'Intro')
            and (current_genre != 'Ad')
        then

            # process stream updates
            save_stream_statistics()
            update_stream_metadatas()

        end

        # don't loop
        (-1.)

    else

        # http retry delay
        !http_retry_delay

    end

end

# play current queue
def play_current_queue() =

    #############################
    ## GET CURRENT SCHEDULE ID ##
    #############################

    current_schedule_id = ref ''
    # get current queue
    the_current_queue = !current_queue
    # set the current schedule id if we have a current queue
    if the_current_queue != [] then
        current_schedule_id := the_current_queue['schedule_id']
    end

    ###########################################
    ## GET CURRENT QUEUE, REMOVE FROM QUEUES ##
    ###########################################

    # update current queue
    current_queue := list.nth(!next_queues, 0)
    # remove current queue
    next_queues := list.tl(!next_queues)

    #####################################
    ## NOTIFY CC OF SCHEDULE FILE PLAY ##
    #####################################

    # notify cc of schedule file play
    add_timeout(fast = true, 0., play_schedule_file)

    ###############################
    ## SCHEDULE CHANGE DETECTION ##
    ###############################

    if
        # see if this is a schedule change
        !current_schedule_id == ''
        or !current_schedule_id != the_current_queue['schedule_id']
    then

        # log schedule change
        log("Queue: Schedule Changed, Loading New Jingles")
        # load the promos for this schedule
        add_timeout(fast = true, 0., load_promos)

    end

end