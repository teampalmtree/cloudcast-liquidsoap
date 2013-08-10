####################
## GATHER STREAMS ##
####################

# make a http request to the engine
streams_active_response = http.get(streams_active_uri)
streams_active_response_data = snd(streams_active_response)
streams_active_response_data = safe_json(streams_active_response_data)
streams := of_json(default = [[('error', 'fail')]], streams_active_response_data)

########################
## INITIALIZE STREAMS ##
########################

def initialize_stream(stream) =

    if
        # check type
        stream['type'] == '0'
    then
        # log local stream
        log("Outputs: Local")
        # create audio card output
        output.ao(!radio)
    else
        # log connection
        log("Streams: Host=#{stream['host']}:#{stream['port']}, Mount=#{stream['mount']}")
        # create icecast output
        output.icecast(%mp3,
            icy_metadata = 'false',
            host = stream['host'],
            port = int_of_string(stream['port']),
            user = stream['source_username'],
            password = stream['source_password'],
            mount = stream['mount'],
            !radio)
    end

    ignore(1)

end

#####################
## SAVE STATISTICS ##
#####################

def save_stream_statistic(stream) =

    # generate save url for this stream
    current_engine_save_stream_statistics_uri
        = string.replace(pattern = '<stream_id>', fun(s) -> stream['id'], engine_save_stream_statistics_uri)
    # save statistics
    current_engine_save_stream_statistics_response = http.get(current_engine_save_stream_statistics_uri)
    # ignore response
    ignore(current_engine_save_stream_statistics_response)

end

def save_stream_statistics() =

    # loop stats for each stream
    list.iter(save_stream_statistic, !streams)
    # don't repeat
    (-1.)

end

#####################
## UPDATE METADATA ##
#####################

def update_stream_metadata(stream) =

    if
        # check type (icecast)
        stream['type'] == '1'
    then

        # get file
        queue = !current_queue
        # create metadata
        metadata = [('song', queue['file_artist'] ^ ' - ' ^ queue['file_title'])]
        # send metadata packet to stream
        icy.update_metadata(
            host = stream['host'],
            port = int_of_string(stream['port']),
            user = stream['source_username'],
            password = stream['source_password'],
            mount = stream['mount'],
            metadata
        )

    end

end

def update_stream_metadatas() =

    # loop metadata update for each stream
    list.iter(update_stream_metadata, !streams)
    # don't repeat
    (-1.)

end