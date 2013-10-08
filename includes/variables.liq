#############
## GENERAL ##
#############

# general
#http_json_header = ref [("Content-Type","application/json; charset=utf-8")]

# URLs
settings_mapped_uri = cloudcast_uri ^ "/settings/mapped.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
streams_active_uri = cloudcast_uri ^ "/streams/active.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
files_sweepers_uri = cloudcast_uri ^ "/files/sweepers.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
files_jingles_uri = cloudcast_uri ^ "/files/jingles.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
files_bumpers_uri = cloudcast_uri ^ "/files/bumpers.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_queue_schedule_uri = cloudcast_uri ^ "/engine/queue_schedule/<schedule_id>.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_schedule_sweepers_uri = cloudcast_uri ^ "/engine/schedule_sweepers/<schedule_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_schedule_jingles_uri = cloudcast_uri ^ "/engine/schedule_jingles/<schedule_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_schedule_bumpers_uri = cloudcast_uri ^ "/engine/schedule_bumpers/<schedule_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_save_stream_statistics_uri = cloudcast_uri ^ "/engine/save_stream_statistics/<stream_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_next_queue_file_uri = cloudcast_uri ^ "/engine/next_queue_file.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_play_schedule_file_uri = cloudcast_uri ^ "/engine/play_schedule_file/<schedule_file_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_update_inputs_uri = cloudcast_uri ^ "/engine/update_inputs.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_authenticate_uri = cloudcast_uri ^ "/engine/authenticate.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters

##############
## SETTINGS ##
##############

# general
station_name = ref ''

# transitions
transition_fade_seconds = ref 0.
transition_seconds = ref 0.
transition_width_seconds = ref 0.
transition_power_margin = ref 0.
transition_high_power = ref 0.
transition_medium_power = ref 0.

# jingles
jingle_quiet_threshold = ref 0.
jingle_quiet_seconds = ref 0.
jingle_noise_seconds = ref 0.
jingle_start_delay_seconds = ref 0.
jingle_end_padding_seconds = ref 0.
jingle_ready_delay_seconds = ref 0.

# inputs
show_input_port = ref 0
talkover_input_port = ref 0
master_input_port = ref 0
input_transition_fade_seconds = ref 0.

# talkover
talkover_transition_fade_seconds = ref 0.
talkover_radio_amplification = ref 0.
talkover_quiet_seconds = ref 0.
talkover_noise_seconds = ref 0.
talkover_quiet_threshold = ref 0.

###########
## QUEUE ##
###########

# create server queue to manage upcoming tracks
radio = ref mksafe(audio_to_stereo(request.queue(id = 'schedule', length = 0.5)))
# last queued schedule file
queue_file = ref []
# true is the queue can accept another file
queue_file_ready = ref true
# current schedule for this queue
queue_schedule = ref []
# queue to queue schedule change detected
queue_schedule_changed = ref false
# queue poll delay
queue_poll_delay = ref 5.

############
## PROMOS ##
############

# promo availability
sweepers_available = ref false
jingles_available = ref false
bumpers_available = ref false
# sweepers playlist
sweepers_playlist = promolist(id = 'sweepers', files_sweepers_uri)
sweepers_reload = fst(sweepers_playlist)
sweepers = audio_to_stereo(snd(sweepers_playlist))
# jingles playlist
jingles_playlist = promolist(id = 'jingles', files_jingles_uri)
jingles_reload = fst(jingles_playlist)
jingles = audio_to_stereo(snd(jingles_playlist))
# bumpers playlist
bumpers_playlist = promolist(id = 'bumpers', files_bumpers_uri)
bumpers_reload = fst(bumpers_playlist)
bumpers = audio_to_stereo(snd(bumpers_playlist))
# sweeper interval
sweeper_interval = ref 0
sweeper_file_count = ref 1

##############
## TRACKING ##
##############

# track beginning/ending
track_meat = ref false
# jingle parameters
quiet_detected = ref false
restricted_playing = ref false
jingles_ready = ref true

#############
## STREAMS ##
#############

streams = ref []

############
## INPUTS ##
############

# update input poll delay
update_inputs_post_delay = ref 5.

# input buffer settings
input_buffer_seconds = ref 5.
input_buffer_seconds_max = ref 40.

# current input statuses
schedule_input_status = ref false
show_input_status = ref false
talkover_input_status = ref false
master_input_status = ref false

# server state of statuses
server_schedule_input_status = ref false
server_show_input_status = ref false
server_talkover_input_status = ref false
server_master_input_status = ref false

# current input enableds
schedule_input_enabled = ref true
show_input_enabled = ref true
talkover_input_enabled = ref true
master_input_enabled = ref true

# server state of enableds
server_schedule_input_enabled = ref false
server_show_input_enabled = ref false
server_talkover_input_enabled = ref false
server_master_input_enabled = ref false

# current input usernames
show_input_username = ref ''
talkover_input_username = ref ''
master_input_username = ref ''

# server state of usernames
server_show_input_username = ref ''
server_talkover_input_username = ref ''
server_master_input_username = ref ''

# talkober input active
talkover_input_active = ref false