local M = {}

function M.is_on(id)
	local bg = gui.get_node(id.."/bg")
	local knob = gui.get_node(id.."/knob")
	
	local size = gui.get_size(bg)
	local pos = gui.get_position(knob)
	return pos.x > 0
end

function M.on_input(id, action_id, action)
	local knob = gui.get_node(id.."/knob")	
	local color = gui.get_color(knob)
	if action.pressed then
		if gui.pick_node(knob, action.x, action.y) then
			color.w = 0.5
			gui.set_color(knob, color)
		end
	elseif action.released and color.w < 1 then
		color.w = 1
		gui.set_color(knob, color)
		
		if gui.pick_node(knob, action.x, action.y) then
			local pos = gui.get_position(knob)	
			if pos.x > 0 then
				gui.set_position(knob, gui.get_position(gui.get_node(id.."/bg_on")))
			else
				gui.set_position(knob, gui.get_position(gui.get_node(id.."/bg_off")))
			end
			return true
		end
	end
end

return M