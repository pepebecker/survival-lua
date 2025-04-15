local map = require 'map'
local utils = require 'utils'

local M = {}

function M.loadAssets()
	M.sprite = love.graphics.newImage('images/bullet.png')
end

function M.init(map)
	M.map = map
end

function M.create(cx, cy, dir)
	return {
		pos = {
			x = cx,
			y = cy,
		},
		dir = dir,
		speed = 500
	}
end

function M.update(bullet, dt)
	if not bullet or bullet.hit then
		return
	end

	if bullet.dir == 'up' then
		bullet.pos.y = bullet.pos.y - dt * bullet.speed
	end
	if bullet.dir == 'down' then
		bullet.pos.y = bullet.pos.y + dt * bullet.speed
	end
	if bullet.dir == 'left' then
		bullet.pos.x = bullet.pos.x - dt * bullet.speed
	end
	if bullet.dir == 'right' then
		bullet.pos.x = bullet.pos.x + dt * bullet.speed
	end

	tile = map.getTileAtPixelPos(M.map, bullet.pos.x, bullet.pos.y)
	if not tile.walkable then
		bullet.hit = true
	end
end

function M.draw(bullet)
	local w = 8
	local h = 8
	local spriteW, spriteH = M.sprite:getDimensions()
	local sx = w / spriteW
	local sy = h / spriteH
	love.graphics.draw(M.sprite, bullet.pos.x - w/2, bullet.pos.y - h/2, 0, sx, sy)
end

return M
