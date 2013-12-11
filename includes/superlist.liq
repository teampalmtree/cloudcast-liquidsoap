###############
## SUPERLIST ##
###############

def superlist(id, timeout, uri) =

    # playlist of files
    playlist = ref []
    # reference to the uri
    playlist_uri = ref uri
    # source for this superlist
    source = audio_to_stereo(request.queue(id = id, length = 0.5))

    # push
    def push(file) =

        # push file name to queue
        ignore(server.execute("#{id}.push #{file}"))
        # log the push
        log("Superlist: Added #{file} to #{id} Playlist")

    end

    # load function
    def load() =

        # make sure we have a uri
        if !playlist_uri != "" then

            # make a http request to the uri
            playlist_uri_response = http.get(timeout = timeout, headers = !http_ajax_headers, !playlist_uri)
            playlist_uri_response_data = snd(playlist_uri_response)
            playlist_uri_json = safe_json(playlist_uri_response_data)

            # check for error
            if playlist_uri_json != '"NONE"' then

                # update playlist
                playlist := of_json(default = [], playlist_uri_json)
                # push all files to the superlist queue
                list.iter(push, !playlist)

            end

        end

    end

    # reload function
    def reload(uri = "") =

        # update uri
        if uri != "" then
            playlist_uri := uri
        end

        # log reloading
        log("Superlist: Reloading #{id} Playlist")
        # load playlist URI
        load()

    end

    def play(m) =

        # update playlist, removing next file
        playlist := list.tl(!playlist)
        # if we have no files left, reload
        if list.length(!playlist) == 0 then

            # log playlist exhausted
            log("Superlist: Exhausted #{id} Playlist")
            # reload superlist
            reload()

        end

    end

    # add on track to source
    source = on_track(play, source)
    # do an initial load
    load()
    # return
    ( source, reload )

end