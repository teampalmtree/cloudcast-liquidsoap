#########################
## GET NEXT QUEUE FILE ##
#########################

def get_next_queue_file() =

    # make a http request to the gateway
    engine_next_queue_file_response = http.get(timeout = 5., engine_next_queue_file_uri)
    engine_next_queue_file_response_data = snd(engine_next_queue_file_response)
    next_queue_file_json = safe_json(engine_next_queue_file_response_data)

    if
        # check for none
        next_queue_file_json == '"NONE"'
    then
        [('error', 'failure')]
    else
        of_json(default = [('error', 'failure')], next_queue_file_json)
    end

end

########################
## SET QUEUE SCHEDULE ##
########################

def set_queue_schedule() =

    # get current queue
    current_queue_file = !queue_file

    # get current schedule queue show uri
    current_engine_queue_schedule_uri = string.replace(pattern = '<schedule_id>', fun(s) -> current_queue_file['schedule_id'], engine_queue_schedule_uri)

    # make a http request to the gateway
    current_engine_queue_schedule_response = http.get(timeout = 5., current_engine_queue_schedule_uri)
    current_engine_queue_schedule_response_data = snd(current_engine_queue_schedule_response)
    queue_schedule_json = safe_json(current_engine_queue_schedule_response_data)
    # set queue schedule
    queue_schedule := of_json(default = [('error', 'failure')], queue_schedule_json)

    # load the promos for this schedule
    load_promos()

end

################
## POLL QUEUE ##
################

# queue files one at a time
def poll_queue() =

    if
        # see if the queue is ready (for a new file)
        !queue_file_ready
    then

        # get queue
        next_queue_file = get_next_queue_file()

        if
            # determine request to generate
            next_queue_file['error'] != "failure"
        then

            ###############################
            ## SCHEDULE CHANGE DETECTION ##
            ###############################

            # get current queue
            current_queue_file = !queue_file

            if
                # see if this is a schedule change
                current_queue_file == []
                or current_queue_file['schedule_id'] != next_queue_file['schedule_id']
            then

                # flag the schedule change
                queue_schedule_changed := true

            end

            ##################
            ## QUEUE UPDATE ##
            ##################

            # set queue to next
            queue_file := next_queue_file
            # push file name to server queue
            ignore(server.execute("schedule.push #{next_queue_file['file_name']}"))
            # log file queued
            log("Queue: Added #{next_queue_file['file_name']}")
            # the queue is satisfied
            queue_file_ready := false
            # update schedule input status
            schedule_input_status := true

        else

            # log file queued
            log("Queue: Empty")
            # go offline as the queue is empty
            schedule_input_status := false

        end

    end

    # sleep for a bit
    !queue_poll_delay

end

########################
## PLAY SCHEDULE FILE ##
########################

def play_schedule_file() =

    #####################################
    ## NOTIFY CC OF SCHEDULE FILE PLAY ##
    #####################################

    # get current queue
    current_queue_file = !queue_file
    # log file played
    log("Queue: Playing #{current_queue_file['file_name']}")
    # generate play schedule file url
    current_engine_play_schedule_file_uri
        = string.replace(pattern = '<schedule_file_id>', fun(s) -> current_queue_file['schedule_file_id'], engine_play_schedule_file_uri)
    # post metadata
    engine_play_schedule_file_response = http.get(timeout = 5., current_engine_play_schedule_file_uri)
    # ignore response
    ignore(engine_play_schedule_file_response)

    ############################################
    ## IF SCHEDULE CHANGE, SET QUEUE SCHEDULE ##
    ############################################

    if
        # if the queue has determined that there is a schedule change
        !queue_schedule_changed
    then

        # log schedule change
        log("Queue: Schedule Changed")
        # set queue schedule
        set_queue_schedule()
        # reset schedule change flag
        queue_schedule_changed := false

    end

    ######################
    ## QUEUE FILE READY ##
    ######################

    # que is ready for another file
    queue_file_ready := true

end