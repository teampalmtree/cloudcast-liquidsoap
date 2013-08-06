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

###################
## AD TRANSITION ##
###################

def ad_transition(song_a, song_b) =

    # log transition
    log("Transitions: Ad")
    # simple end and start
    sequence([ song_a, song_b ])

end

########################
## AD-SONG TRANSITION ##
########################

def ad_song_transition(song_a, song_b) =

    # log transition
    log("Transitions: Ad-Song")
    # bring back the music with bumper
    sequence([
        song_a,
        add(normalize = false, [
            delay(initial = true, 1.0, once(bumpers)),
            song_fade_in(song_b)
        ])
    ])

end

#####################
## SONG TRANSITION ##
#####################

# song-song transition
def song_transition(power_a, power_b, song_a, song_b) =

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

    ####################################
    ## FADE OUT A, SWEEPER, FADE IN B ##
    ####################################

    else
        # Otherwise, A and B are just too loud to overlap nicely,
        # or the difference between them is too large and overlapping would
        # completely mask one of them.
        log("Transitions: Song: End/Sweeper/Begin")
        sequence([
            song_a,
            once(sweepers),
            song_b
        ])

    end

end

#######################
## TRANSITION TRIAGE ##
#######################

def transition(power_a, power_b, meta_a, meta_b, song_a, song_b)

    log("Transititons: Triaging...")
    # see if a or b is an ad
    ad_a = meta_a['genre'] == 'Ad'
    ad_b = meta_b['genre'] == 'Ad'

    # triage based on content
    if ad_a and ad_b then
        ad_transition(song_a, song_b)
    elsif not ad_a and ad_b then
        ad_transition(song_a, song_b)
    elsif ad_a and not ad_b then
        ad_song_transition(song_a, song_b)
    else
        song_transition(power_a, power_b, song_a, song_b)
    end

end
