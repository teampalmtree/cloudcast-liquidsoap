####################
## GET NEXT QUEUE ##
####################

def get_next_queue() =

    # make a http request to the gateway
    engine_next_queue_response = http.get(engine_next_queue_uri)
    engine_next_queue_response_data = snd(engine_next_queue_response)
    next_queue_json = safe_json(engine_next_queue_response_data)
    of_json(default = [('error', 'failure')], next_queue_json)

end

################
## POLL QUEUE ##
################

# queue files one at a time
def poll_queue() =

    if
        !queue_length == 0.
    then

        # get queue
        next_queue = get_next_queue()

        if
            # determine request to generate
            next_queue['error'] != "failure"
        then

            # set queue to next
            current_queue := next_queue
            # push file name to server queue
            ignore(server.execute("schedule.push #{next_queue['file_name']}"))
            # log file queued
            log("Queue: Added #{next_queue['file_name']}")

            # up queue length (this will satisfy the queue for now)
            queue_length := !queue_length + 1.
            # update schedule input status
            schedule_input_status := true

        end

    end

    !queue_poll_delay

end

########################
## PLAY SCHEDULE FILE ##
########################

def play_schedule_file() =

    # get current queue
    queue = !current_queue
    # generate play schedule file url
    current_engine_play_schedule_file_uri
        = string.replace(pattern = '<schedule_file_id>', fun(s) -> queue['schedule_file_id'], engine_play_schedule_file_uri)
    # post metadata
    engine_play_schedule_file_response = http.get(current_engine_play_schedule_file_uri)
    # ignore response
    ignore(engine_play_schedule_file_response)
    # end metadata wait (will cause the queue to get another file)
    queue_length := !queue_length - 1.
    # don't repeat
    (-1.)

end