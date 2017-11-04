local utils = require 'utils'
local character = require 'character'
local bullet = require 'bullet'

local M = {}

function M.loadAssets()
	character.loadAssets()
	bullet.loadAssets()
	M.sprites = {}
	M.sprites.idle = love.graphics.newImage('images/survivor/survivor-idle_0.png')
end

function M.init(map)
	M.map = map
	character.init(map)
	M.fireRate = .5
	M.lastTime = love.timer.getTime()
end

function M.create(x, y, dir)
	local player = character.create(x, y, dir)
	player.speed = 6
	return player
end

function M.turn(player, dx, dy)
	character.turn(player, dx, dy)
end

function M.shoot(player, dx, dy)
	if love.timer.getTime() - M.lastTime > M.fireRate then
		M.lastTime = love.timer.getTime()
		M.turn(player, dx, dy)
		local x = player.pixelPos.x + M.map.options.tile.width / 2
		local y = player.pixelPos.y + M.map.options.tile.height / 2
		return bullet.create(x, y, player.dir)
	end
end

function M.move(player, dx, dy)
	character.move(player, dx, dy)
end

function M.update(player, dt)
	character.update(player, dt)
end

function M.drawShadow(player)
	character.drawShadow(player, M.sprites.idle)
end

function M.draw(player)
	character.draw(player, M.sprites.idle)
end

return M
