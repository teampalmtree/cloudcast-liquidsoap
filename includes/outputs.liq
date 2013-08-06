####################
## GATHER STREAMS ##
####################

# make a http request to the engine
streams_response = http.get(streams_uri)
streams_response_data = snd(streams_response)
streams_response_data = safe_json(streams_response_data)
streams := of_json(default = [[('error', 'fail')]], streams_response_data)

########################
## INITIALIZE OUTPUTS ##
########################

def initialize_output(stream) =

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
        log("Outputs: Host=#{stream['host']}:#{stream['port']}, Mount=#{stream['mount']}")
        # create icecast output
        output.icecast(%mp3,
            host = stream['host'],
            port = int_of_string(stream['port']),
            user = stream['source_username'],
            password = stream['source_password'],
            mount = stream['mount'],
            !radio)
    end

    ignore(1)

end