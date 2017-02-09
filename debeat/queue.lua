local dtable = require("dbeat.util.dtable")

local M = {}

M.TYPE_SEQUENCE = hash("SEQUENCE")
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

	function instance.add_sound(url)
		for _,sound in pairs(available) do
			assert(sound ~= url, "Multiple additions of same sound is not allowed")
		end
		table.insert(available, url)
	end

	function instance.play(delay, gain)
		if (os.clock() - last_play) > config.gating then
			last_play = os.clock()
		else
			print(string.format("Warning, queue %s called too frequently", id))
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
			local min_offset = math.min(config.min_offset, #available)
			local offset = math.random(min_offset, #available)
			table.insert(available, offset, sound)
		end
	end

	function instance.stop()
		for _,sound in pairs(available) do
			msg.post(sound, "stop_sound")
		end
	end

	return instance
end

return M