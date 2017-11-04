local utils = require 'utils'
local character = require 'character'
local astar = require 'lib.a-star'

local M = {}

function M.loadAssets()
	character.loadAssets()
	M.sprites = {
		idle = {},
		move = {},
		attack = {},
	}
	M.frames = {
		idle = 0,
		move = 0,
		attack = 0,
	}
	for i=0,16 do
		local sprite = love.graphics.newImage('images/zombie/skeleton-idle_' .. i .. '.png')
		table.insert(M.sprites.idle, sprite)
	end
	for i=0,16 do
		local sprite = love.graphics.newImage('images/zombie/skeleton-move_' .. i .. '.png')
		table.insert(M.sprites.move, sprite)
	end
	for i=0,8 do
		local sprite = love.graphics.newImage('images/zombie/skeleton-attack_' .. i .. '.png')
		table.insert(M.sprites.attack, sprite)
	end
end

function M.init(map)
	character.init(map)
	M.list = {}
	for i=1,#map.options.spawners do
		local spawner = map.options.spawners[i]
		local zombie = M.create(spawner.x, spawner.y, spawner.dir)
		table.insert(M.list, zombie)
	end
end

function M.create(x, y, dir)
	local zombie = character.create(x, y, dir)
	zombie.arrived = true
	zombie.attacking = false
	return zombie
end

function M.setTarget(zombie, target)
	zombie.target = target
end

local function updateFrame(zombie, dt)
	local t = math.floor(love.timer.getTime() * 4 * zombie.speed)
	M.frames.attack = (t % #M.sprites.attack) + 1
	M.frames.move = (t % #M.sprites.move) + 1
	M.frames.idle = (t % #M.sprites.idle) + 1
end

-- local function updateNextTile(zombie)
-- 	if not zombie.moving and zombie.target then
-- 		if zombie.pos.y < zombie.target.pos.y then
-- 			character.move(zombie, 0, 1)
-- 		elseif zombie.pos.y > zombie.target.pos.y then
-- 			character.move(zombie, 0, -1)
-- 		elseif zombie.pos.x < zombie.target.pos.x then
-- 			character.move(zombie, 1, 0)
-- 		elseif zombie.pos.x > zombie.target.pos.x then
-- 			character.move(zombie, -1, 0)
-- 		end
-- 		if zombie.pos.x == zombie.target.pos.x and zombie.pos.y == zombie.target.pos.y then
-- 			if not zombie.arrived then
-- 				zombie.arrived = true
-- 				zombie.attacking = true
-- 			end
-- 		else
-- 			if zombie.arrived then
-- 				zombie.arrived = false
-- 				zombie.attacking = false
-- 			end
-- 		end
-- 	end
-- end

local function updateNextTile(zombie)
	-- local path = astar.path(zo , graph [ 3 ], graph, true, valid_node_func )
end

function M.update(zombie, dt)
	character.update(zombie, dt)
	updateFrame(zombie, dt)
	updateNextTile(zombie)
end

function M.drawShadow(zombie)
	character.drawShadow(zombie)
end

function M.draw(zombie)
	local sprite
	if zombie.attacking then
		sprite = M.sprites.attack[M.frames.attack]
	elseif zombie.moving then
		sprite = M.sprites.move[M.frames.move]
	else
		sprite = M.sprites.idle[M.frames.idle]
	end
	character.draw(zombie, sprite)
end

return M
