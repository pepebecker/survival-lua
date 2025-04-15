local M = {}

function M.deg2rad(deg)
	return (deg / 180) * math.pi
end

function M.dir2rot(dir)
	rotations = {
		right = 0,
		down = 90,
		left = 180,
		up = 270,
	}
	return rotations[dir]
end

-- function M.posFromPixelPos

return M
