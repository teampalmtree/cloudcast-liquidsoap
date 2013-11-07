###############
## SUPERLIST ##
###############

# add dummy protocol
add_protocol("nothing",fun(_,_)->[])

def superlist(~id = "", uri) =

    # reference to the playlist
    playlist = ref []
    # reference to the uri
    playlist_uri = ref uri
    # availability
    available = ref true

    # file request function
    def map(el) =

        meta = fst(el)
        file = snd(el)
        s = list.fold(fun (cur, el) -> "#{cur},#{fst(el)}=#{string.escape(snd(el))}", "", meta)

        if s == "" then
            file
        else
            "annotate:#{s}:#{file}"
        end

    end

    # load function
    def load() =

        # create a request resource to the uri
        playlist_request = request.create.raw(!playlist_uri)

        if

            # perform request to get the playlist
            request.resolve(playlist_request)

        then

            # get the filename for this request (local copy)
            playlist_filename = request.filename(playlist_request)
            # parse local playlist
            playlist_files = playlist.parse(playlist_filename)
            # check for none
            if snd(list.nth(playlist_files, 0)) != 'NONE' then

                # re-map playlist files
                playlist_files = list.map(map, playlist_files)
                # update playlist with files requested, sorting randomly
                playlist := list.sort(fun (x, y) -> int_of_float(random.float()), playlist_files)
                log("Superlist: Loaded playlist of #{list.length(!playlist)} files")

            else

                # set no files available
                available := false
                # set playlist empty
                playlist := []
                # log no files available
                log("Superlist: No Files Available")

            end

        else

            # set no files available
            available := false
            # set playlist empty
            playlist := []
            # log request resolution failure
            log("Superlist: Couldn't Read Playlist")

        end

        # release request resources
        request.destroy(playlist_request)


    end

    # reload function
    def reload(uri = "") =

        # if new URI passed, update instance
        if uri != "" then
            playlist_uri := uri
        end

        # log reloading
        log("Superlist: Reloading Playlist with URI #{!playlist_uri}")
        # load playlist URI
        load()

    end

    # The next function
    def next() =

        # if playlist empty, and files are available, attempt reload
        if !available then

            # check for empty playlist, attempt auto-reload
            if list.length(!playlist) == 0 then

                # log playlist exhausted
                log("Superlist: Exhausted Playlist with URI #{!playlist_uri}")
                # reload playlist
                reload(!playlist_uri)

            end

            # grab next file from playlist
            file = list.hd(!playlist)
            # update playlist, removing next file
            playlist := list.tl(!playlist)
            # create request for the file
            request.create(file)

        else

            # create empty request
            request.create("nothing:")

        end

    end

    # instantiate the source
    source = request.dynamic(id = id, length = 0.5, next)
    # return
    ( source, ( available, reload ))

end