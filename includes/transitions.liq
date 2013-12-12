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

#######################
## INPUT TRANSITIONS ##
#######################

# intro
def intro_input_transition(a, b) =

    # log transition
    log("Transitions: Intro Input")
    # fade out music, start intro, start input
    add(normalize = false, [
        sequence([
            fade_out(a),
            fallback(track_sensitive = false, [])
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
            intros,
            fallback(track_sensitive = false, [])
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
            fade_in(b)
        ])
    ])

end

# closer
def closer_input_transition(a, b) =

    # log transition
    log("Transitions: Closer Input")
    # fade out music, start intro, start input
    add(normalize = false, [
        sequence([
            fade_out(a),
            fallback(track_sensitive = false, [])
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
            once(closers),
            fallback(track_sensitive = false, [])
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
            fade_in(b)
        ])
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
            file_a,
            fallback(track_sensitive = false, [])
        ]), sequence(merge = true, [
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
        ]), sequence(merge = true, [
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
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
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
        ]), sequence(merge = true, [
            blank(duration = !transition_delay_seconds),
            fade_in(file_b)
        ])
    ])

end

##################################
## CROSSED FILE-FILE TRANSITION ##
##################################

def crossed_file_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: Crossed File-File")
    # cross fade files
    add(normalize = false, [
        fade_in(file_b),
        fade_out(file_a)
    ])

end

##########################
## FILE-FILE TRANSITION ##
##########################

def file_file_transition(file_a, file_b) =

    # log transition
    log("Transitions: File-File")
    # finish the file, start the next file
    sequence([
        file_a,
        file_b
    ])

end

#######################
## TRANSITION TRIAGE ##
#######################

def transition(file_a, file_b)

    # if we have a next queue, get it as well
    if list.length(!next_queues) > 0 then

        ##############################
        ## GET CURRENT & NEXT GENRE ##
        ##############################

        # get current queue
        the_current_queue = !current_queue
        # get current genre
        genre_a = the_current_queue['file_genre']
        # get the next queue
        the_next_queue = list.nth(!next_queues, 0)
        # get the next genre
        genre_b = the_next_queue['file_genre']

        # log triage
        log("Transititons: Triaging (#{genre_a} -> #{genre_b})")

        ########################
        ## FILE-AD TRANSITION ##
        ########################

        if (genre_b == 'Ad') then
            file_file_transition(file_a, file_b)

        ########################
        ## AD-FILE TRANSITION ##
        ########################

        elsif (genre_a == 'Ad') and (genre_b != 'Bumper') then
            file_file_transition(file_a, file_b)

        ############################
        ## FILE-BUMPER TRANSITION ##
        ############################

        elsif (genre_b == 'Bumper') then
            file_file_transition(file_a, file_b)

        ############################
        ## BUMPER-FILE TRANSITION ##
        ############################

        elsif (genre_a == 'Bumper') and (genre_b != 'Intro') then
            bumper_file_transition(file_a, file_b)

        ###########################
        ## FILE-INTRO TRANSITION ##
        ###########################

        elsif (genre_b == 'Intro') then
            file_file_transition(file_a, file_b)

        ############################
        ## INTRO-FILE TRANSITIONS ##
        ############################

        elsif (genre_a == 'Intro') then
            intro_file_transition(file_a, file_b)

        #########################
        ## FILE-SET TRANSITION ##
        #########################

        elsif (genre_b == 'Set') then
            file_file_transition(file_a, file_b)

        #########################
        ## SET-FILE TRANSITION ##
        #########################

        elsif (genre_a == 'Set') then
            file_file_transition(file_a, file_b)

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

        ##################################
        ## CROSSED FILE-FILE TRANSITION ##
        ##################################

        else
            crossed_file_file_transition(file_a, file_b)

        end

    else

        # log out of queue
        log("Transititons: Out of Queue")
        # we are out of queue, no transition
        file_file_transition(file_a, file_b)

    end

end
