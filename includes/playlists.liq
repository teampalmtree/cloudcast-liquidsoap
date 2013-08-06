################################
## SWEEPERS (HARSH SONG-SONG) ##
################################

# get sweepers playlist url
sweepers_url = string.replace(pattern = '<genre>', fun(s) -> 'Sweeper', files_genre_uri)
# pre-load sweepers playlist, set reload strategy
sweepers = audio_to_stereo(
    playlist(
        mime_type = 'audio/mpegurl',
        reload = 1,
        reload_mode = 'rounds',
        sweepers_url
    )
)

##################################
## JINGLES (OVER QUIET IN SONG) ##
##################################

# get jingles playlist url
jingles_url = string.replace(pattern = '<genre>', fun(s) -> 'Jingle', files_genre_uri)
# pre-load jingles playlist, set reload strategy
jingles = audio_to_stereo(
    playlist(
        mime_type = 'audio/mpegurl',
        reload = 1,
        reload_mode = 'rounds',
        jingles_url
    )
)

#######################
## BUMPERS (AD-SONG) ##
#######################

# get bumpers playlist url
bumpers_url = string.replace(pattern = '<genre>', fun(s) -> 'Bumper', files_genre_uri)
# pre-load bumpers playlist, set reload strategy
bumpers = audio_to_stereo(
    playlist(
        mime_type = 'audio/mpegurl',
        reload = 1,
        reload_mode = 'rounds',
        bumpers_url
    )
)