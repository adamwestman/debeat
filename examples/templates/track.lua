local toggle = require("examples.templates.toggle")

local M = {}

function M.set_name(id, text)
	gui.set_text(gui.get_node(id.."/name"), text)	
end

function M.is_playing(id)
	return toggle.is_on(id.."/play")
end

function M.on_input(id, action_id, action)
	return toggle.on_input(id.."/play", action_id, action)
end

return M