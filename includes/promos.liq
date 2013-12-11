############
## PROMOS ##
############

# jingles superlist
jingles_superlist = superlist('jingles', !http_timeout, '')
jingles = audio_to_stereo(fst(jingles_superlist))
jingles_reload = snd(jingles_superlist)

# intros superlist
intros_superlist = superlist('intros', !http_timeout, '')
intros = audio_to_stereo(fst(intros_superlist))
intros_reload = snd(intros_superlist)

# closers superlist
closers_superlist = superlist('closers', !http_timeout, '')
closers = audio_to_stereo(fst(closers_superlist))
closers_reload = snd(closers_superlist)

ignore(closers)

#################
## LOAD INTROS ##
#################

def load_intros(schedule_id) =

    # get intros playlist uri
    current_engine_schedule_promos_uri = string.replace(pattern = '<genre>', fun(s) -> 'Intro', engine_schedule_promos_uri)
    current_engine_schedule_promos_uri = string.replace(pattern = '<schedule_id>', fun(s) -> schedule_id, current_engine_schedule_promos_uri)
    # load intros playlist
    intros_reload(current_engine_schedule_promos_uri)

end

##################
## LOAD JINGLES ##
##################

def load_jingles(schedule_id) =

    # get jingles playlist uri
    current_engine_schedule_promos_uri = string.replace(pattern = '<genre>', fun(s) -> 'Jingle', engine_schedule_promos_uri)
    current_engine_schedule_promos_uri = string.replace(pattern = '<schedule_id>', fun(s) -> schedule_id, current_engine_schedule_promos_uri)
    # load jingles playlist
    jingles_reload(current_engine_schedule_promos_uri)

end

##################
## LOAD CLOSERS ##
##################

def load_closers(schedule_id) =

    # get closers playlist uri
    current_engine_schedule_promos_uri = string.replace(pattern = '<genre>', fun(s) -> 'Closer', engine_schedule_promos_uri)
    current_engine_schedule_promos_uri = string.replace(pattern = '<schedule_id>', fun(s) -> schedule_id, current_engine_schedule_promos_uri)
    # load closers playlist
    closers_reload(current_engine_schedule_promos_uri)

end

#################
## LOAD PROMOS ##
#################

def load_promos() =

    # log loading
    log("Promos: Loading...")
    # get the current queue
    the_current_queue = !current_queue
    # get current schedule id
    current_schedule_id = the_current_queue['schedule_id']
    # load promos for this schedule
    load_intros(current_schedule_id)
    load_jingles(current_schedule_id)
    load_closers(current_schedule_id)
    # don't loop
    (-1.)

end