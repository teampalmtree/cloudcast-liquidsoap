################################
## SWEEPERS (HARSH SONG-SONG) ##
################################

# get sweepers playlist url
sweepers_url = string.replace(pattern = '<genre>', fun(s) -> 'Sweeper', files_genre_uri)
# pre-load sweepers playlist, set reload strategy
sweepers = audio_to_stereo(
    playlist(
        id = 'sweepers',
        conservative = true,
        default_duration = 1.,
        mime_type = 'audio/mpegurl',
        sweepers_url
    )
)

##################################
## JINGLES (OVER QUIET IN SONG) ##
##################################

# get jingles playlist url
jingles_url = string.replace(pattern = '<genre>', fun(s) -> 'Jingle', files_genre_uri)
# pre-load jingles playlist, set reload strategy
jingles = audio_to_stereo(
    playlist(
        id = 'jingles',
        conservative = true,
        default_duration = 1.,
        mime_type = 'audio/mpegurl',
        jingles_url
    )
)

#######################
## BUMPERS (AD-SONG) ##
#######################

# get bumpers playlist url
bumpers_url = string.replace(pattern = '<genre>', fun(s) -> 'Bumper', files_genre_uri)
# pre-load bumpers playlist, set reload strategy
bumpers = audio_to_stereo(
    playlist(
        id = 'bumpers',
        conservative = true,
        default_duration = 1.,
        mime_type = 'audio/mpegurl',
        bumpers_url
    )
)

######################
## RELOAD PLAYLISTS ##
######################

def reload_playlists(~protocol, ~data, ~headers, uri) =

    # get uri parts
    uri_parts = url.split(uri)
    # verify authorized
    if
        authorized_uri(uri_parts)
    then
        # use telnet API to reload playlists
        ignore(server.execute("sweepers.reload"))
        ignore(server.execute("jingles.reload"))
        ignore(server.execute("bumpers.reload"))
        # log service
        log('Playlists: Reloaded')
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

# register reload playlists service
harbor.http.register(port = services_port, method = "GET", "/reload_playlists", reload_playlists)