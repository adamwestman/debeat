local toggle = require("examples.templates.toggle")
local slider = require("examples.templates.slider")
local equalizer = require("examples.templates.equalizer")

local M = {}

function M.set_name(id, name)
	local lbl_name = gui.get_node(id.."/name")
	gui.set_text(lbl_name, name)
end

function M.is_muted(id)
	return not toggle.is_on(id.."/mute")
end

function M.get_gain(id, min, max)
	if toggle.is_on(id.."/mute") then
		return slider.get_value(id.."/gain", min, max)
	else
		return min
	end
end

function M.update(id, group_hash)
	equalizer.update(id.."/equalizer", group_hash)
end

function M.on_input(id, action_id, action)
	if slider.on_input(id.."/gain", action_id, action) then
		return true
	elseif toggle.on_input(id.."/mute", action_id, action) then
		return true
	end
end


return M