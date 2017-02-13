local M = {}

function M.get_value(id, min, max)
	local bg = gui.get_node(id.."/bg")
	local knob = gui.get_node(id.."/knob")

	local size = gui.get_size(bg)
	local pos = gui.get_position(knob)
	return (pos.y / size.y) * max + min
end

function M.on_input(id, action_id, action)
	local knob = gui.get_node(id.."/knob")
	local hitbox = gui.get_node(id.."/hitbox")
	local color = gui.get_color(knob)
	if action.released then
		color.w = 1
		gui.set_color(knob, color)
	elseif action.pressed and gui.pick_node(hitbox, action.x, action.y) then
		color.w = 0.5
		gui.set_color(knob, color)
	elseif color.w < 1 then
		local pos = gui.get_position(knob)
		pos.y = pos.y + action.dy

		local bg = gui.get_node(id.."/bg")
		local size = gui.get_size(bg)
		pos.y = math.max(0, math.min(pos.y, size.y))

		gui.set_position(knob, pos)
		return true
	end
end

return M