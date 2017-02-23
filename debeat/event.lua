local M = {}

local listeners = {}

function M.add_listener(event_name, handler)
	assert(event_name)
	assert(handler)
	
	local group = listeners[event_name] or {}
	assert(not group[handler], "Trying to add existing handler to listener group")
	
	group[handler] = true
	listeners[event_name] = group
end

function M.remove_listener(event_name, handler)
	assert(event_name)
	assert(handler)
	
	local group = listeners[event_name] or {}
	assert(group[handler], "Trying to remove undefined handler from listener group")
	
	group[handler] = nil
end

function M.trigger(event_name)
	local group = listeners[event_name] or {}
	for handler,_ in pairs(group) do
		handler()	
	end
end

return M