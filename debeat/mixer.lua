--- Controll play, stop and change gain on music tracks and sound groups.
local M = {}

local mixer_url = nil

function M.set_default(default_mixer_url)
	mixer_url = default_mixer_url
end

--- Is the mixer setup and ready.
-- @return ready [boolean]
function M.is_ready()
	return mixer_url ~= nil
end

--- Instruct the mxier to refresh available sound groups.
-- Needed in case proxies introduce new groups.
function M.refresh_groups()
	msg.post(mixer_url, "setup_groups")	
end

--- Instruct the mixer to start playing a sound component.
-- @param sound_url [url] msg.url() to a sound component.
-- @param config [table] optional configurations.
-- * gain [number]  sound gain between 0 and 1, default is 1. 
-- * delay [number] delay in seconds before the sound starts playing, default is 0.
-- * attack [number] time in seconds during which the sound fade in, default is 0.1
-- * easing [go.EASING_*] curve at which the gain value will fade in, default is LINEAR.
function M.play(sound_url, config)
	assert(type(sound_url) == "userdata", "Expected a sound_url of type userdata, received "..type(sound_url))

	config = config or {}
	config.url = sound_url
	msg.post(mixer_url, "play", config)
end

--- Instruct the mixer to stop playing a sound component.
-- @param sound_url [url] msg.url() to a sound component.
-- @param config [table] optional configurations.
-- * delay [number] delay in seconds before the sound start fading out, default is 0.
-- * decay [number] time in seconds during which the sound fades out, default is 0.1
-- * easing [go.EASING_*] curve at which the gain value will fade out, default is LINEAR.
function M.stop(sound_url, config)
	assert(type(sound_url) == "userdata", "Expected a sound_url of type userdata, received "..type(sound_url))

	config = config or {}
	config.url = sound_url
	msg.post(mixer_url, "stop", config)
end

--- Change the gain of an already playing sound component.
-- @param sound_url [url] msg.url() to a sound component.
-- @param gain [number]  sound gain between 0 and 1, default is 1. 
-- @param config [table] optional configurations.
-- * delay [number] delay in seconds before the sound start fading to the new gain, default is 0.
-- * duration [number] time in seconds during which the sound fades to the new gain, default is 0.01
-- * easing [go.EASING_*] curve at which the gain value will change, default is LINEAR.
function M.set_gain(sound_url, gain, config)
	assert(type(sound_url) == "userdata", "Expected a sound_url of type userdata, received "..type(sound_url))
	assert(type(gain) == "number", "Expected a gain of type number, received "..type(gain))

	config = config or {}
	config.url = sound_url
	config.gain = gain
	msg.post(mixer_url, "set_sound_gain", config)
end

--- Change the gain of a sound group.
-- @param group [hash] an already loaded sound-group.
-- @param gain [number]  sound gain between 0 and 1, default is 1. 
-- @param config [table] optional configurations.
-- * delay [number] delay in seconds before the sound start fading to the new gain, default is 0.
-- * duration [number] time in seconds during which the sound fades to the new gain, default is 0.01
-- * easing [go.EASING_*] curve at which the gain value will change, default is LINEAR.
function M.set_group_gain(group, gain, config)
	assert(type(group) == "userdata", "Expected a group of type userdata, received "..type(group))
	assert(type(gain) == "number", "Expected a gain of type number, received "..type(gain))

	config = config or {}
	config.group = group
	config.gain = gain
	msg.post(mixer_url, "set_group_gain", config)
end

return M