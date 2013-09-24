###############
## PROMOLIST ##
###############

def promolist(~id = "", uri) =

    # A reference to the playlist
    playlist = ref []
    # A reference to the uri
    playlist_uri = ref uri

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
            # re-map playlist files
            playlist_files = list.map(map, playlist_files)
            # update playlist with files requested, sorting randomly
            playlist := list.sort(fun (x, y) -> int_of_float(random.float()), playlist_files)
        else
            log("Promolist: Couldn't read playlist, request resolution failed")
            # update playlist with files requested, sorting randomly
            playlist := []
        end

        # release request resources
        request.destroy(playlist_request)


    end

    # reload function
    def reload(uri = "") =

        if uri != "" then
            playlist_uri := uri
        end

        log("Promolist: Reloading playlist with URI #{!playlist_uri}")
        load()

    end

    # The next function
    def next() =

        if
            # if playlist stopped, reload
            list.length(!playlist) == 0
        then
            reload(!playlist_uri)
        end

        # continue playlist
        file = list.hd(!playlist)
        playlist := list.tl(!playlist)
        request.create(file)

    end

    # instanciate the source
    source = request.dynamic(id = id, next)
    # load the playlist
    load()
    # return
    (reload, source)

end