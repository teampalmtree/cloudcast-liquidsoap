######################
## SET/GET SETTINGS ##
######################

def get_settings() =

    # make a http request to the engine
    settings_response = http.get(settings_uri)
    settings_response_data = snd(settings_response)
    settings_json = safe_json(settings_response_data)
    of_json(default = [('error', 'fail')], settings_json)

end

def set_settings(settings) =
    
    ##################
    ## SET SETTINGS ##
    ##################
    
    # transitions
    transition_fade_seconds := float_of_string(settings['transition_fade_seconds'])
    transition_seconds := float_of_string(settings['transition_seconds'])
    transition_width_seconds := float_of_string(settings['transition_width_seconds'])
    transition_power_margin := float_of_string(settings['transition_power_margin'])
    transition_high_power := float_of_string(settings['transition_high_power'])
    transition_medium_power := float_of_string(settings['transition_medium_power'])
    
    # jingles
    jingle_quiet_threshold := float_of_string(settings['jingle_quiet_threshold'])
    jingle_quiet_seconds := float_of_string(settings['jingle_quiet_seconds'])
    jingle_noise_seconds := float_of_string(settings['jingle_noise_seconds'])
    jingle_start_delay_seconds := float_of_string(settings['jingle_start_delay_seconds'])
    jingle_end_padding_seconds := float_of_string(settings['jingle_end_padding_seconds'])

    # inputs
    show_input_port := int_of_string(settings['show_input_port'])
    talkover_input_port := int_of_string(settings['talkover_input_port'])
    master_input_port := int_of_string(settings['master_input_port'])
    input_transition_fade_seconds := float_of_string(settings['input_transition_fade_seconds'])

    # talkover
    talkover_transition_fade_seconds := float_of_string(settings['talkover_transition_fade_seconds'])
    talkover_radio_amplification := float_of_string(settings['talkover_radio_amplification'])
    talkover_quiet_seconds := float_of_string(settings['talkover_quiet_seconds'])
    talkover_noise_seconds := float_of_string(settings['talkover_noise_seconds'])
    talkover_quiet_threshold := float_of_string(settings['talkover_quiet_threshold'])

    ##################
    ## LOG SETTINGS ##
    ##################

    # transitions
    log('Settings: transition_fade_seconds = ' ^ string_of(!transition_fade_seconds))
    log('Settings: transition_seconds = ' ^ string_of(!transition_seconds))
    log('Settings: transition_width_seconds = ' ^ string_of(!transition_width_seconds))
    log('Settings: transition_power_margin = ' ^ string_of(!transition_power_margin))
    log('Settings: transition_high_power = ' ^ string_of(!transition_high_power))
    log('Settings: transition_medium_power = ' ^ string_of(!transition_medium_power))

    # jingles
    log('Settings: jingle_quiet_threshold = ' ^ string_of(!jingle_quiet_threshold))
    log('Settings: jingle_quiet_seconds = ' ^ string_of(!jingle_quiet_seconds))
    log('Settings: jingle_noise_seconds = ' ^ string_of(!jingle_noise_seconds))
    log('Settings: jingle_start_delay_seconds = ' ^ string_of(!jingle_start_delay_seconds))
    log('Settings: jingle_end_padding_seconds = ' ^ string_of(!jingle_end_padding_seconds))

    # inputs
    log('Settings: show_input_port = ' ^ string_of(!show_input_port))
    log('Settings: talkover_input_port = ' ^ string_of(!talkover_input_port))
    log('Settings: master_input_port = ' ^ string_of(!master_input_port))
    log('Settings: input_transition_fade_seconds = ' ^ string_of(!input_transition_fade_seconds))

    # talkover
    log('Settings: talkover_transition_fade_seconds = ' ^ string_of(!talkover_transition_fade_seconds))
    log('Settings: talkover_radio_amplification = ' ^ string_of(!talkover_radio_amplification))
    log('Settings: talkover_quiet_seconds = ' ^ string_of(!talkover_quiet_seconds))
    log('Settings: talkover_noise_seconds = ' ^ string_of(!talkover_noise_seconds))
    log('Settings: talkover_quiet_threshold = ' ^ string_of(!talkover_quiet_threshold))

end

################
## INITIALIZE ##
################

# get settings
settings = get_settings()
# set settings
set_settings(settings)