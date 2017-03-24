local dtable = require("debeat.util.dtable")

local M = {}

--- Plays sounds in the order they were added, looping around at end.
M.TYPE_SEQUENCE = hash("SEQUENCE")
--- Plays randomly from the queued sounds, allowing repeat play every "repeat_offset".
M.TYPE_RANDOM = hash("RANDOM")

--- Default configs
--@field gating[number] time in seconds required to pass between calls to play, or they will be ignored. Defaults to 0.1 seconds.
--@field behaviour[hash] how should the added sounds be selected for play. Defaults to SEQUENCE.
--@field repeat_offset[number] how often can a sound be repeated, every X. Defaults to every 1.
--@field global[boolean] Is this a global script, available in @{get} or local to the original creator. Defaulst to false.
M.default_config = {
	gating = 0.1,
	behaviour = M.TYPE_SEQUENCE,
	repeat_offset = 1,
	global = false,
}

local global = {}

--- Create a new queue.
-- @param id[hash] name of the queue.
-- @param config[table] optional table with configuration values. See @{default_config} for options.
-- @return instance[table]
function M.create(id, config)
	assert(type(id) == "userdata", string.format("Expected id of type hash, received %s", type(id)))
	config = dtable.merge(config, M.default_config)

	local name = tostring(id)
	local offset = config.repeat_offset
	local behaviour = config.behaviour

	assert(offset > 0, string.format("Repeat offset has to be more than 0, received %s", tostring(offset)))
	assert(behaviour == M.TYPE_SEQUENCE or behaviour == M.TYPE_RANDOM, string.format("Unsuported behaviour type %s requested", tostring(behaviour)))

	local available = {}
	local default_order = {}
	local last_play = 0
	local instance = {}

	--- Add a sound to the queue.
	-- @param url [url] sound component url
	function instance.add(url)
		assert(type(url) == "userdata", "Expected a url of type userdata, received "..type(url))
		for _,existing in pairs(available) do
			assert(existing ~= url, "Multiple additions of same sound is not allowed")
		end
		table.insert(available, url)
		table.insert(default_order, url)
	end

	--- Play the next queued sound, unless blocked by gating.
	-- @param delay [number] delay in seconds before the sound starts playing, default is 0.
	-- @param gain [number]  sound gain between 0 and 1, default is 1.
	function instance.play(delay, gain)
		local time = socket.gettime()
		if (time - last_play) > config.gating then
			last_play = time
		else
			print(string.format("Warning, queue %s called too frequently", name), time - last_play)
			return
		end
		if #available == 0 then
			print(string.format("Error, queue %s has no sounds", name))
			return
		end

		local url = table.remove(available, 1)
		msg.post(url, "play_sound", {delay=delay, gain=gain})

		if behaviour == M.TYPE_SEQUENCE then
			table.insert(available, url)

		elseif behaviour == M.TYPE_RANDOM then
			local min_offset = math.min(offset, #available+1)
			local index = math.random(min_offset, #available+1)
			table.insert(available, index, url)
		end
	end

	--- Tell all queued sounds to stop playing.
	function instance.stop()
		for _,url in pairs(available) do
			msg.post(url, "stop_sound")
		end
	end

	--- Reset queue play order.
	function instance.reset()
		for i,sound in ipairs(default_order) do
			available[i] = sound
		end
	end

	--- Retrieve the id passed along on create.
	-- @return id[hash]
	function instance.get_id()
		return id
	end

	--- Check if this instance is a global queue.
	-- @return global[boolean]
	function instance.is_global()
		return config.global
	end

	if config.global then
		if global[id] then
			print("Error", msg.url())
			error("A global queue with the given id already exists")
		else
			global[id] = instance
		end
	end

	return instance
end

--- Clear global references.
function M.destroy(instance)
	if instance.is_global() then
		global[instance.get_id()] = nil
	end
end

--- Check for and return a queue with the given id from the global scope if found.
-- @param id[hash] if of a global queue.
-- @return instance[@{queue.create}]
function M.get(id)
	return global[id]
end

return M