##########
## FILE ##
##########

def get_file() =

    # make a http request to the gateway
    engine_file_response = http.get(engine_file_uri)
    engine_file_response_data = snd(engine_file_response)
    file_json = safe_json(engine_file_response_data)
    of_json(default = [('error', 'failure')], file_json)

end

###########
## QUEUE ##
###########

# queue files one at a time
def poll_file() =

    if
        !queue_length == 0.
    then

        # get file
        file = get_file()

        if
            # determine request to generate
            file['error'] != "failure"
        then

            # set queued file
            queue_file := file
            # push file name to server queue
            ignore(server.execute("schedule.push #{file['name']}"))
            # log file queued
            log("Queue: Added #{file['name']}")

            # up queue length (this will satisfy the queue for now)
            queue_length := !queue_length + 1.
            # update schedule input status
            schedule_input_status := true

        end

    end

    !queue_file_poll_delay

end

#####################
## POST STATISTICS ##
#####################

def post_stream_statistics_single(stream) =

    # generate url for this stream
    current_streams_statistics_uri
        = string.replace(pattern = '<stream_id>', fun(s) -> stream['id'], streams_statistics_uri)
    # get statistics
    current_streams_statistics_response = http.get(current_streams_statistics_uri)
    # ignore response
    ignore(current_streams_statistics_response)

end

def post_stream_statistics() =

    # loop stats for each stream
    list.iter(post_stream_statistics_single, !streams)
    # don't repeat
    (-1.)

end

###############
## POST FILE ##
###############

def post_file() =

    # post metadata
    engine_file_response = http.post(
        data = json_of(!queue_file),
        engine_file_uri
    )

    # ignore response
    ignore(engine_file_response)
    # end metadata wait (will cause the queue to get another file)
    queue_length := !queue_length - 1.
    # don't repeat
    (-1.)

end