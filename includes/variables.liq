#############
## GENERAL ##
#############

# general
#http_json_header = ref [("Content-Type","application/json; charset=utf-8")]
http_timeout = ref 5.

# URLs
settings_mapped_uri = cloudcast_uri ^ "/settings/mapped.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
streams_active_uri = cloudcast_uri ^ "/streams/active.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_schedule_jingles_uri = cloudcast_uri ^ "/engine/schedule_jingles/<schedule_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_save_stream_statistics_uri = cloudcast_uri ^ "/engine/save_stream_statistics/<stream_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_next_queues_uri = cloudcast_uri ^ "/engine/next_queues.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_play_schedule_file_uri = cloudcast_uri ^ "/engine/play_schedule_file/<schedule_file_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_update_inputs_uri = cloudcast_uri ^ "/engine/update_inputs.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_authenticate_uri = cloudcast_uri ^ "/engine/authenticate.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_reset_queued_uri = cloudcast_uri ^ "/engine/reset_queued.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters

##############
## SETTINGS ##
##############

# general
station_name = ref ''

# transitions
transition_cross_seconds = ref 0.
transition_fade_seconds = ref 0.
transition_delay_seconds = ref 0.

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
radio = ref audio_to_stereo(request.queue(id = 'schedule', length = 0.5))
# list of upcoming queues
next_queues = ref []
# current active queue
current_queue = ref []
# next queues poll delay
next_queues_poll_delay = ref 5.

#############
## JINGLES ##
#############

# jingles playlist
jingles_playlist = superlist(id = 'jingles', '')
jingles = audio_to_stereo(fst(jingles_playlist))
jingles_available = fst(snd(jingles_playlist))
jingles_reload = snd(snd(jingles_playlist))

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