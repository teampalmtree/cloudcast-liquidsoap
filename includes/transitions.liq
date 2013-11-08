############
## FADERS ##
############

# file faders
fade_out = fun(s) -> fade.final(type = "lin", duration = !transition_fade_seconds, s)
fade_in = fun(s) -> fade.initial(type = "lin", duration = !transition_fade_seconds, s)
# input faders
input_fade_out = fun(s) -> fade.final(type = "lin", duration = !input_transition_fade_seconds, s)
input_fade_in = fun(s) -> fade.initial(type = "lin", duration = !input_transition_fade_seconds, s)
# talkover faders
talkover_fade_out = fun(s) -> fade.final(type = "lin", duration = !talkover_transition_fade_seconds, s)
talkover_fade_in = fun(s) -> fade.initial(type = "lin", duration = !talkover_transition_fade_seconds, s)

######################
## INPUT TRANSITION ##
######################

def input_transition(a, b) =

    # log transition
    log("Transitions: Input")
    # bring back the music with sweeper
    add(normalize = false, [
        input_fade_in(b),
        input_fade_out(a)
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
        talkover_fade_in(b),
        talkover_fade_out(a)
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
            blank(duration = !transition_delay_seconds),
            fade_in(file_b)
        ]), sequence([
            file_a,
            fallback(track_sensitive = false, [])
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
           blank(duration = !transition_delay_seconds),
           fade_in(file_b)
       ]), sequence([
           file_a,
           fallback(track_sensitive = false, [])
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
            blank(duration = !transition_delay_seconds),
            file_b
        ]), sequence([
            fade_out(file_a),
            fallback(track_sensitive = false, [])
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
            blank(duration = !transition_delay_seconds),
            fade_in(file_b)
        ]), sequence([
            file_a,
            fallback(track_sensitive = false, [])
        ]),
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
        fade_in(file_b),
        fade_out(file_a)
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
