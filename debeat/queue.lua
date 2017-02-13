local dtable = require("debeat.util.dtable")

local M = {}

--- Plays sounds in the order they were added, looping around at end.
M.TYPE_SEQUENCE = hash("SEQUENCE")
--- Plays randomly from the queued sounds, requiring min_offset other sounds to play before repeating.
M.TYPE_RANDOM = hash("RANDOM")

M.default_config = {
	gating = 0.1,
	behaviour = M.TYPE_SEQUENCE,
	min_offset = 1,
}

function M.create(id, config)
	assert(id, "Queue id not defined")
	id = tostring(id)
	config = dtable.merge(config, M.default_config)

	local available = {}
	local last_play = 0

	local instance = {}

	--- Add a sound to the queue.
	-- @param url [url] sound component url
	function instance.add(url)
		assert(type(url) == "userdata", "Expected a url of type userdata, received "..type(url))
		for _,sound in pairs(available) do
			assert(sound ~= url, "Multiple additions of same sound is not allowed")
		end
		table.insert(available, url)
	end

	--- Play the next queued sound, unless blocked by gating.
	-- @param delay [number] delay in seconds before the sound starts playing, default is 0.
	-- @param gain [number]  sound gain between 0 and 1, default is 1.
	function instance.play(delay, gain)
		local time = socket.gettime()
		if (time - last_play) > config.gating then
			last_play = time
		else
			print(string.format("Warning, queue %s called too frequently", id), time - last_play)
			return
		end
		if #available == 0 then
			print(string.format("Error, queue %s has no sounds", id))
			return
		end

		local sound = table.remove(available, 1)
		msg.post(sound, "play_sound", {delay=delay, gain=gain})

		if config.behaviour == M.TYPE_SEQUENCE then
			table.insert(available, sound)

		elseif config.behaviour == M.TYPE_RANDOM then
			local min_offset = math.min(config.min_offset, #available+1)
			local offset = math.random(min_offset, #available+1)
			table.insert(available, offset, sound)
		end
	end

	--- Tell all queued sounds to stop playing.
	function instance.stop()
		for _,sound in pairs(available) do
			msg.post(sound, "stop_sound")
		end
	end

	return instance
end

return M