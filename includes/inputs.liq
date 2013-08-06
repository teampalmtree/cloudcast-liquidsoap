#################
## POST INPUTS ##
#################

def post_inputs() =

    if
        # statuses
        !schedule_input_status != !server_schedule_input_status
        or !show_input_status != !server_show_input_status
        or !talkover_input_status != !server_talkover_input_status
        or !master_input_status != !server_master_input_status

        # enableds
        or !schedule_input_enabled != !server_schedule_input_enabled
        or !show_input_enabled != !server_show_input_enabled
        or !talkover_input_enabled != !server_talkover_input_enabled
        or !master_input_enabled != !server_master_input_enabled

        # usernames
        or !show_input_username != !server_show_input_username
        or !talkover_input_username != !server_talkover_input_username
        or !master_input_username != !server_master_input_username

    then

        # update server statuses
        server_schedule_input_status := !schedule_input_status
        server_show_input_status := !show_input_status
        server_talkover_input_status := !talkover_input_status
        server_master_input_status := !master_input_status

        # update server enableds
        server_schedule_input_enabled := !schedule_input_enabled
        server_show_input_enabled := !show_input_enabled
        server_talkover_input_enabled := !talkover_input_enabled
        server_master_input_enabled := !master_input_enabled

        # update server usernames
        server_show_input_username := !show_input_username
        server_talkover_input_username := !talkover_input_username
        server_master_input_username := !master_input_username

        # create inputs json
        inputs = [
            [('name', 'schedule'), ('status', string_of(!server_schedule_input_status)), ('enabled', string_of(!schedule_input_enabled))],
            [('name', 'show'), ('status', string_of(!server_show_input_status)), ('username', !server_show_input_username), ('enabled', string_of(!show_input_enabled))],
            [('name', 'talkover'), ('status', string_of(!server_talkover_input_status)), ('username', !server_talkover_input_username), ('enabled', string_of(!talkover_input_enabled))],
            [('name', 'master'), ('status', string_of(!server_master_input_status)), ('username', !server_master_input_username), ('enabled', string_of(!master_input_enabled))]
        ]

        # post inputs
        engine_inputs_response = http.post(
            data = json_of(inputs),
            engine_inputs_uri
        )

        # ignore response
        ignore(engine_inputs_response)

    end

    !inputs_post_delay

end

##################################
## CONNECT/DISCONNECT FUNCTIONS ##
##################################

# show input
def show_input_connect(header) =
    log('Inputs: Show Connected')
    show_input_status := true
end
def show_input_disconnect() =
    show_input_status := false
    show_input_username := ''
end

# talkover input
def talkover_input_connect(header) =
    log('Inputs: Talkover Connected')
    talkover_input_status := true
end
def talkover_input_disconnect() =
    talkover_input_status := false
    talkover_input_username := ''
end

# master input
def master_input_connect(header) =
    log('Inputs: Master Connected')
    master_input_status := true
end
def master_input_disconnect() =
    master_input_status := false
    master_input_username := ''
end

############################
## INPUT SERVICE FUNCTION ##
############################

def input_service(~protocol, ~data, ~headers, uri) =

    # get uri parts
    uri_parts = url.split(uri)
    # verify authorized
    if
        authorized_uri(uri_parts)
    then

        # get uri paramters
        uri_parameters = snd(uri_parts)
        # get input name & enabled flag
        uri_parameters_input = uri_parameters['input']
        uri_parameters_enabled = uri_parameters['enabled']
        # log request
        log("Inputs: '#{uri_parameters_input}' ? #{uri_parameters_enabled}")

        # get enabled parameters
        input_enabled = bool_of_string(uri_parameters_enabled)
        # set input enabled
        if uri_parameters_input == 'schedule' then
            schedule_input_enabled := input_enabled
        elsif uri_parameters_input == 'show' then
            show_input_enabled := input_enabled
        elsif uri_parameters_input == 'talkover' then
            talkover_input_enabled := input_enabled
        elsif uri_parameters_input == 'master' then
            master_input_enabled := input_enabled
        end

        # send response
        http_response(
            protocol = protocol,
            code = 200,
            data = 'SUCCESS'
        )

    else

        # send response
        http_response(
            protocol = protocol,
            code = 500,
            data = 'NOT_AUTHORIZED'
        )

    end

end

# register enable talkover service
harbor.http.register(port = services_port, method = "GET", "/input", input_service)