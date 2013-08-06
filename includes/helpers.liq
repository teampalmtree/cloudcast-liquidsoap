#############
## GENERAL ##
#############

# logging function
log = log(label = "CloudCast", level = 2)

# produce safe JSON
def safe_json(s) =

# get non-null json strings
string.replace(pattern = '":null',
    fun(s) -> string.replace(pattern = 'null',
        fun(s) -> '"null"', s), s)

end

###########################
## SERVICE AUTHROIZATION ##
###########################

def authorized_uri(uri_parts) =

    # get parameters
    uri_paramters = snd(uri_parts)
    # verify authorized
    (uri_paramters['key'] == services_key)

end

######################
## RESTART FUNCTION ##
######################

def restart_service(~protocol, ~data, ~headers, uri) =

    # get uri parts
    uri_parts = url.split(uri)
    # verify authorized
    if
        authorized_uri(uri_parts)
    then
        # log service
        log('Helpers: Restarting...')
        # shutdown LS
        shutdown()
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

# register restart service
harbor.http.register(port = services_port, method = "GET", "/restart", restart_service)