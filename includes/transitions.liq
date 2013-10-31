######################
## SONG TRANSITIONS ##
######################

# song fading functions
song_fade_out = fun(a) -> fade.out(type = "lin", duration = !transition_fade_seconds, a)
song_fade_in = fun(a) -> fade.in(type = "lin", duration = !transition_fade_seconds, a)

######################
## INPUT TRANSITION ##
######################

def input_transition(a, b) =

    # log transition
    log("Transitions: Input")
    # bring back the music with sweeper
    add(normalize = false, [
        fade.initial(duration = !input_transition_fade_seconds, b),
        fade.final(duration = !input_transition_fade_seconds, a)
    ])

end

#########################
## TALKOVER TRANSITION ##
#########################

def talkover_transition(a, b) =

    # log transition
    log("Transitions: Talkover")
    # bring back the music with sweeper
    add(normalize = false, [
        fade.initial(duration = !talkover_transition_fade_seconds, b),
        fade.final(duration = !talkover_transition_fade_seconds, a)
    ])

end

######################
## AD-AD TRANSITION ##
######################

def ad_ad_transition(song_a, song_b) =

    # log transition
    log("Transitions: Ad-Ad")
    # simple end and start
    sequence([ song_a, song_b ])

end

#########################
## AD-INTRO TRANSITION ##
#########################

def ad_intro_transition(song_a, song_b) =

    # log transition
    log("Transitions: Ad-Intro")
    # simple end and start
    sequence([ song_a, song_b ])

end

########################
## FILE-AD TRANSITION ##
########################

def file_ad_transition(song_a, song_b) =

    # log transition
    log("Transitions: File-Ad")
    # simple end and start
    sequence([ song_a, song_b ])

end

########################
## AD-FILE TRANSITION ##
########################

def ad_file_transition(song_a, song_b) =

    # log transition
    log("Transitions: Ad-File")

    if
        # make sure bumpers are available
        !bumpers_available
        # and we don't have (talkover input & enabled)
        and not (!talkover_input_status and !talkover_input_enabled)
    then

        # bring back the music with bumper
        sequence([
            song_a,
            add(normalize = false, [
                sequence([
                    blank(duration = 1.),
                    once(bumpers),
                    fallback(track_sensitive = false, [])
                ]),
                song_fade_in(song_b)
            ])
        ])

    else

        # finish the ad, fade in b
        sequence([
            song_a,
            song_fade_in(song_b)
        ])

    end

end

##################################
## FILE-SWEEPER-FILE TRANSITION ##
##################################

def file_sweeper_file_transition(song_a, song_b) =

    # log transition
    log("Transitions: File-Sweeper-File")

    if
        # make sure we have sweepers
        !sweepers_available
        # and we don't have (talkover input & enabled)
        and not (!talkover_input_status and !talkover_input_enabled)
    then

        # fade out a, half way through bringing in
        # sweeper and b
        add(normalize = false, [
            song_fade_out(song_a),
            sequence([
                blank(duration = !transition_fade_seconds / 2.),
                once(sweepers),
                fallback(track_sensitive = false, [])
            ]),
            sequence([
                blank(duration = !transition_fade_seconds / 2.),
                song_fade_in(song_b)
            ])

        ])

    else

        # just play a and b back to back
        sequence([song_a, song_b])

    end

end

##########################
## FILE-FILE TRANSITION ##
##########################

# song-song transition
def file_file_transition(power_a, power_b, song_a, song_b) =

    ############################
    ## FADE A OUT + FADE B IN ##
    ############################

    if
        # A == B (normal)
        # if A and B are not too loud and close, fully cross-fade them
        power_a <= !transition_medium_power
        and power_b <= !transition_medium_power
        and abs(power_a - power_b) <= !transition_power_margin
    then
        log("Transitions: Song: Crossed, Fade-in, Fade-out")
        add(normalize = false, [ song_fade_out(song_a), song_fade_in(song_b) ])

    ##########################
    ## FADE A OUT + START B ##
    ##########################

    elsif
        # A < B
        # if B is significantly louder than A, only fade-out A.
        # we don't want to fade almost silent things, ask for >medium
        power_b >= power_a + !transition_power_margin
        and power_a >= !transition_medium_power
        and power_b <= !transition_high_power
    then
        log("Transitions: Song: Crossed, Fade-out")
        add(normalize = false, [ song_fade_out(song_a) , song_b ])

    #######################
    ## END A + FADE IN B ##
    #######################

    elsif
        #  A > B
        # Opposite as the previous one.
        power_a >= power_b + !transition_power_margin
        and power_b >= !transition_medium_power
        and power_a <= !transition_high_power
    then
        log("Transitions: Song: Crossed, Fade-in")
        add(normalize = false, [ song_a, song_fade_in(song_b) ])

    #####################
    ## END A + START B ##
    #####################

    elsif
        # A == B (low)
        # Do not fade if it's already very low.
        power_b >= power_a + !transition_power_margin
        and power_a <= !transition_medium_power
        and power_b <= !transition_high_power
    then
        log("Transitions: Song: Crossed, No Fade")
        add(normalize = false, [ song_a, song_b ])

    # What to do with a loud end and a quiet beginning ?
    # A good idea is to use a sweeper to separate the two tracks,
    # but that's another story.

    ######################################
    ## FADE OUT A + SWEEPER + FADE IN B ##
    ######################################

    else
        # Otherwise, A and B are just too loud to overlap nicely,
        # or the difference between them is too large and overlapping would
        # completely mask one of them.
        log("Transitions: Song: End/Sweeper/Begin")
        # throw a sweeper in between
        file_sweeper_file_transition(song_a, song_b)

    end

end

#######################
## TRANSITION TRIAGE ##
#######################

def transition(power_a, power_b, meta_a, meta_b, song_a, song_b)

    log("Transititons: Triaging...")
    # see if a or b is an ad
    genre_a = meta_a['genre']
    genre_b = meta_b['genre']

    ######################
    ## AD-AD TRANSITION ##
    ######################

    if (genre_a == 'Ad') and (genre_b == 'Ad') then
        ad_ad_transition(song_a, song_b)

    #########################
    ## AD-INTRO TRANSITION ##
    #########################

    elsif (genre_a == 'Ad') and (genre_b == 'Intro') then
        ad_intro_transition(song_a, song_b)

    ########################
    ## FILE-AD TRANSITION ##
    ########################

    elsif (genre_b == 'Ad') then
        file_ad_transition(song_a, song_b)

    ########################
    ## AD-FILE TRANSITION ##
    ########################

    elsif (genre_a == 'Ad') then
        ad_file_transition(song_a, song_b)

    ############################
    ## INTRO-FILE TRANSITIONS ##
    ############################

    elsif (genre_a == 'Intro') then
        intro_file_transition(song_a, song_b)

    ##########################
    ## FILE-FILE TRANSITION ##
    ##########################

    else

        # see if our sweeper interval is zero (automatic sweepers)
        if !sweeper_interval == 0 then

            # run standard file-file transition
            file_file_transition(power_a, power_b, song_a, song_b)

        else

            # if we aren't fully automated, force a sweeper when it is our turn
            if !sweeper_file_count == !sweeper_interval then

                # reset sweeper file count
                sweeper_file_count := 1
                file_sweeper_file_transition(song_a, song_b)

            else

                # increment sweeper file count
                sweeper_file_count := !sweeper_file_count + 1
                file_file_transition(power_a, power_b, song_a, song_b)

            end

        end

    end

end
