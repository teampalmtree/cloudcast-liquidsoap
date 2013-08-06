def authorize_user(username, password, type) =

    # create & fill array object
    credentials = [('username', username), ('password', password), ('type', type)]
    # post metadata
    engine_authenticate_response = http.post(
        data = json_of(credentials),
        engine_authenticate_uri
    )

    # process response
    user_authentication = snd(engine_authenticate_response)
    log("AUTH: " ^ user_authentication)
    # see if user is authed
    user_authenticated = (user_authentication == 'SUCCESS')

    if
        # update username for current user
        user_authenticated
    then
        if type == 'show' then
            show_input_username := username
        elsif type == 'talkover' then
            talkover_input_username := username
        elsif type == 'master' then
            master_input_username := username
        end
    else
        log("Users: Authorization Failed (#{username})")
    end

    # return result
    user_authenticated

end

# show user
def authorize_show_user(username, password) =
    authorize_user(username, password, 'show')
end

# talkover user
def authorize_talkover_user(username, password) =
    authorize_user(username, password, 'talkover')
end

# master user
def authorize_master_user(username, password) =
    authorize_user(username, password, 'master')
end