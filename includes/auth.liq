def authenticate(username, password, input) =

    # create & fill array object
    credentials = [('username', username), ('password', password), ('input', input)]
    # post metadata
    engine_authenticate_response = http.post(
        data = json_of(credentials),
        headers = !http_ajax_headers,
        engine_authenticate_uri
    )

    # process response
    authentication = snd(engine_authenticate_response)
    # see if user is authenticated
    authenticated = (authentication == 'SUCCESS')

    if
        # update username for current user
        authenticated
    then
        if input == 'show' then
            show_input_username := username
        elsif input == 'talkover' then
            talkover_input_username := username
        elsif input == 'master' then
            master_input_username := username
        end
    else
        log("Auth: Authentication Failed for #{username} (#{authentication})")
    end

    # return result
    authenticated

end

# show user
def authenticate_show(username, password) =
    authenticate(username, password, 'show')
end

# talkover user
def authenticate_talkover(username, password) =
    authenticate(username, password, 'talkover')
end

# master user
def authenticate_master(username, password) =
    authenticate(username, password, 'master')
end