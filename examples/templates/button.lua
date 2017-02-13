local M = {}

function M.set_text(id, text)
	local lbl = gui.get_node(id.."/lbl")
	gui.set_text(lbl, text)
end

function M.on_input(id, action_id, action)
	local bg = gui.get_node(id.."/bg")
	local color = gui.get_color(bg)
	if action.pressed then
		if gui.pick_node(bg, action.x, action.y) then
			color.w = 0.5
			gui.set_color(bg, color)
		end
	elseif action.released and color.w < 1 then
		color.w = 1
		gui.set_color(bg, color)
		
		if gui.pick_node(bg, action.x, action.y) then
			return true
		end
	end
end

return M