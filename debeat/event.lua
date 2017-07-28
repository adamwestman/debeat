--- A Signal system following the event-listener design, where handlers can be added to and later removed from specific events.
-- @usage
-- event.add_listener("fire", function()
--   print("Fire happened")
-- end)
--
-- event("fire")
-- event.trigger("fire")

local M = {}

local listeners = {}

local function ensure_hash(str)
	return type(str) == "string" and hash(str) or str
end

--- Add a handler to the specified event.
function M.add_listener(event_name, handler)
	assert(event_name)
	assert(handler)

	event_name = ensure_hash(event_name)
	local group = listeners[event_name] or {}
	assert(not group[handler], "Trying to add existing handler to listener group")

	group[handler] = true
	listeners[event_name] = group
end

--- Remove a previously added handler from the specified event.
function M.remove_listener(event_name, handler)
	assert(event_name)
	assert(handler)

	event_name = ensure_hash(event_name)
	local group = listeners[event_name] or {}
	assert(group[handler], "Trying to remove undefined handler from listener group")

	group[handler] = nil
end

--- Trigger an event and invoke all handlers attached to it.
function M.trigger(event_name)
	event_name = ensure_hash(event_name)

	local group = listeners[event_name] or {}
	for handler,_ in pairs(group) do
		handler(event_name)
	end
end

M = setmetatable(M, {
	__call = function(self, ...)
		return M.trigger(...)
	end,
})

return M
