############
## FADERS ##
############

# fading functions
fade_out = fun(a) -> fade.out(type = "lin", duration = !transition_fade_seconds, a)
fade_in = fun(a) -> fade.in(type = "lin", duration = !transition_fade_seconds, a)

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

############################
## BUMPER-FILE TRANSITION ##
############################

def bumper_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: Bumper-File")
    # finish the bumper while fading in b
    add(normalize = false, [
        sequence([
            file_a,
            fallback(track_sensitive = false, [])
        ]),
        sequence([
            blank(duration = !transition_delay_seconds),
            fade_in(file_b)
        ])
    ])

end

###########################
## INTRO-FILE TRANSITION ##
###########################

def intro_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: Intro-File")
   # start intro, fading in music after a delay
   add(normalize = false, [
       sequence([
           file_a,
           fallback(track_sensitive = false, [])
       ]),
       sequence([
           blank(duration = !transition_delay_seconds),
           fade_in(file_b)
       ])
   ])

end

#############################
## FILE-SWEEPER TRANSITION ##
#############################

def file_sweeper_transition(file_a, file_b) =


    # log transition
    log("Transitions: File-Sweeper")
    # fade out file while starting sweeper
    add(normalize = false, [
        sequence([
            fade_out(file_a),
            fallback(track_sensitive = false, [])
        ]),
        sequence([
            blank(duration = !transition_fade_seconds / 2.),
            file_b
        ])
    ])

end

#############################
## SWEEPER-FILE TRANSITION ##
#############################

def sweeper_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: Sweeper-File")
    # finish sweeper, fade in file
    add(normalize = false, [
        sequence([
            file_a,
            fallback(track_sensitive = false, [])
        ]),
        sequence([
            blank(duration = !transition_fade_seconds / 2.),
            fade_in(file_b)
        ])
    ])

end

##########################
## FILE-FILE TRANSITION ##
##########################

def file_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: File-File")
    # finish the ad, fade in b
    add(normalize = false, [
            fade_out(file_a),
        fade_in(file_b)
    ])

end

#######################
## TRANSITION TRIAGE ##
#######################

def transition(power_a, power_b, meta_a, meta_b, file_a, file_b)

    log("Transititons: Triaging...")
    # see if a or b is an ad
    genre_a = meta_a['genre']
    genre_b = meta_b['genre']

    ############################
    ## BUMPER-FILE TRANSITION ##
    ############################

    if (genre_a == 'Bumper') and (genre_b != 'Intro') then
        bumper_file_transition(file_a, file_b)

    ############################
    ## INTRO-FILE TRANSITIONS ##
    ############################

    elsif (genre_a == 'Intro') then
        intro_file_transition(file_a, file_b)

    #############################
    ## FILE-SWEEPER TRANSITION ##
    #############################

    elsif (genre_b == 'Sweeper') then
        file_sweeper_transition(file_a, file_b)

    #############################
    ## SWEEPER-FILE TRANSITION ##
    #############################

    elsif (genre_a == 'Sweeper') then
        sweeper_file_transition(file_a, file_b)

    ##########################
    ## FILE-FILE TRANSITION ##
    ##########################

    else
        file_file_transition(file_a, file_b)

    end

end
