#############
## GENERAL ##
#############

# general
#http_json_header = ref [("Content-Type","application/json; charset=utf-8")]

# URLs
settings_mapped_uri = cloudcast_uri ^ "/settings/mapped.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
streams_active_uri = cloudcast_uri ^ "/streams/active.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
files_genre_uri = cloudcast_uri ^ "/files/genre/<genre>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_save_stream_statistics_uri = cloudcast_uri ^ "/engine/save_stream_statistics/<stream_id>.rawxml" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
engine_next_queue_uri = cloudcast_uri ^ "/engine/next_queue.json" ^ "?key=" ^ cloudcast_uri_key ^ "&" ^ cloudcast_uri_parameters
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
radio = ref audio_to_stereo(request.queue(id = 'schedule'))
# tracks currently in queue
queue_length = ref 0.
# last queued schedule file
current_queue = ref []
# queue poll delay
queue_poll_delay = ref 5.

##############
## TRACKING ##
##############

# track beginning/ending
track_meat = ref false

# jingle parameters
quiet_detected = ref false
advertisement_playing = ref false

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
show_input_buffer_seconds_max = ref 80.
talkover_input_buffer_seconds = ref 2.
talkover_input_buffer_seconds_max = ref 5.

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