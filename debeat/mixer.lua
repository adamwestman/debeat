local M = {}

local mixer_url = nil

function M.set_default(default_mixer_url)
	mixer_url = default_mixer_url
end

function M.is_ready()
	return mixer_url ~= nil
end

function M.play(sound_url, config)
	assert(sound_url)

	config = config or {}
	config.url = sound_url
	msg.post(mixer_url, "play", config)
end

function M.stop(sound_url, config)
	assert(sound_url)

	config = config or {}
	config.url = sound_url
	msg.post(mixer_url, "stop", config)
end

function M.set_gain(sound_url, gain, config)
	assert(sound_url)
	assert(gain)

	config = config or {}
	config.url = sound_url
	config.gain = gain
	msg.post(mixer_url, "set_gain", config)
end

function M.set_group_gain(group, gain, config)
	assert(group)
	assert(gain)

	config = config or {}
	config.group = group
	config.gain = gain
	msg.post(mixer_url, "set_group_gain", config)
end

return M