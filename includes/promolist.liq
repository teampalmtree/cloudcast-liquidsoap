###############
## PROMOLIST ##
###############

def promolist(~id = "", uri) =

    # A reference to the playlist
    playlist = ref []
    # A reference to the uri
    playlist_uri = ref uri

    # The load function
    def load_playlist() =

        files =
            if
                test_process("test -d #{quote(!playlist_uri)}")
            then

                log("Promolist: Playlist is a directory")
                get_process_lines("find #{quote(!playlist_uri)} -type f | sort")

            else

                playlist = request.create.raw(!playlist_uri)
                result =
                    if request.resolve(playlist) then

                        playlist = request.filename(playlist)
                        files = playlist.parse(playlist)

                        def file_request(el) =
                            meta = fst(el)
                            file = snd(el)
                            s = list.fold(fun (cur, el) ->
                                "#{cur},#{fst(el)}=#{string.escape(snd(el))}", "", meta)
                            if s == "" then
                                file
                            else
                                "annotate:#{s}:#{file}"
                            end
                        end

                        list.map(file_request, files)

                    else

                        log("Promolist: Couldn't read playlist, request resolution failed")
                        []

                    end

                request.destroy(playlist)
                result

            end

        playlist := list.sort(fun (x,y) -> int_of_float(random.float()), files)

    end

    # The reload function
    def reload(uri = "") =

        if uri != "" then
            playlist_uri := uri
        end

        log("Promolist: Reloading playlist with URI #{!playlist_uri}")
        load_playlist()

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

    # Instanciate the source
    source = request.dynamic(id=id,next)
    # Get its id.
    #id = source.id(source)

    # Load the playlist
    load_playlist()
    # Return
    (reload,source)

end