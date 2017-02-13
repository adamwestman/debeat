local M = {}

function M.update(id, group_hash)
	local gain = sound.get_group_gain(group_hash)

    -- Convert to decibel.
	local db = 20 * math.log10(gain)
	
	
	-- Get RMS (gain Root Mean Square). Left and right channel separately.
	local left_rms, right_rms = sound.get_rms(group_hash, 2048 / 65536.0)
    local left_rmsdb = 20 * math.log10(left_rms)
	local right_rmsdb = 20 * math.log10(right_rms)

	-- Get gain peak. Left and right separately.
	local left_peak, right_peak = sound.get_peak(group_hash, 2048 * 10 / 65536.0)
    local left_peakdb = 20 * math.log10(left_peak)
	local right_peakdb = 20 * math.log10(right_peak)
	local peak_db = (left_peakdb+right_peakdb) * 0.5
	
	-- render visual
	local lbl_gain_db = gui.get_node(id.."/gain_db")
	gui.set_text(lbl_gain_db, string.format("%.1f", db))
	
	local lbl_peak_db = gui.get_node(id.."/peak_db")
	gui.set_text(lbl_peak_db, string.format("%.2f", peak_db))
	
	local bg = gui.get_node(id.."/bg")
	local max_y = gui.get_size(bg).y
	
	local peak_l = gui.get_node(id.."/peak_l")
	local peak_r = gui.get_node(id.."/peak_r")
	
	local size_l = gui.get_size(peak_l)
	size_l.y = max_y + (max_y * math.max(left_rmsdb, -60)) / 60
	gui.set_size(peak_l, size_l)
	
	local size_r = gui.get_size(peak_r)
	size_r.y = max_y + (max_y * math.max(right_rmsdb, -60)) / 60
	gui.set_size(peak_r, size_r)
	
	local rms_l = gui.get_node(id.."/rms_l")
	local rms_r = gui.get_node(id.."/rms_r")
	
	local pos_l = gui.get_position(rms_l)
	pos_l.y = max_y + (max_y * math.max(left_peakdb, -60)) / 60
	gui.set_position(rms_l, pos_l)
	
	local pos_r = gui.get_position(rms_r)
	pos_r.y = max_y + (max_y * math.max(right_peakdb, -60)) / 60
	gui.set_position(rms_r, pos_r)
end

return M