local M = {}

local frames = {}
local frame_sum = 0
local frame_index = 1
local MAX_SAMPLES = 10
M.average_ms = 0
M.raw_average_time = 0
M.fps = 0

function M.update(dt)
	if frames[frame_index] then frame_sum = frame_sum - frames[frame_index] end
	frame_sum = frame_sum + dt
	frames[frame_index] = dt
	frame_index = math.fmod(frame_index + 1, MAX_SAMPLES)
	M.raw_average_time = frame_sum / MAX_SAMPLES
	M.average_ms = math.floor(M.raw_average_time * 100000) / 100
	M.fps = math.floor(1.0 / M.raw_average_time * 100) / 100
end

return M
