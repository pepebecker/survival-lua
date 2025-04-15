local map = require 'map'
local utils = require 'utils'
local position = require 'position'

local M = {}

function M.loadAssets()
	M.sprites = {}
	M.sprites.shadow = love.graphics.newImage('images/character-shadow.png')
	M.sprites.target = love.graphics.newImage('images/target.png')
end

function M.init(map)
	M.map = map
end

function M.create(x, y, dir)
	return {
		pixelPos = {
			x = x * M.map.options.tile.width,
			y = y * M.map.options.tile.height,
		},
		pos = {
			x = x,
			y = y,
		},
		nextTile = {
			x = x,
			y = y,
		},
		dir = dir,
		speed = 4,
		moving = false,
	}
end

function M.turn(character, dx, dy)
	if dx > 0 then
		character.dir = 'right'
	end
	if dx < 0 then
		character.dir = 'left'
	end
	if dy > 0 then
		character.dir = 'down'
	end
	if dy < 0 then
		character.dir = 'up'
	end
end

function M.move(character, dx, dy)
	if not character.moving then
		local nextX = character.pos.x + dx + 1
		local nextY = character.pos.y + dy + 1
		local tile = map.getTile(M.map, nextX, nextY)

		character.nextTile = tile

		M.turn(character, dx, dy)

		if tile.walkable then
			character.moving = true
		end
	end
end

local function moving(character, dt)
	if character.moving and character.nextTile then
		local tw = M.map.options.tile.width
		local th = M.map.options.tile.height
		local differenceX = character.nextTile.x * tw - character.pixelPos.x
		local differenceY = character.nextTile.y * th - character.pixelPos.y
		local movementX = 0
		local movementY = 0

		if differenceX > 0 then
			movementX = 1
		end
		if differenceX < 0 then
			movementX = -1
		end
		if differenceY > 0 then
			movementY = 1
		end
		if differenceY < 0 then
			movementY = -1
		end

		if not character.nextTile.walkable then
			character.moving = false
			return
		end

		if math.abs(differenceX) < 3 and math.abs(differenceY) < 3 then
			character.pos.x = character.nextTile.x
			character.pos.y = character.nextTile.y
			character.pixelPos.x = character.nextTile.x * tw
			character.pixelPos.y = character.nextTile.y * th
			character.moving = false
			return
		end

		character.pixelPos.x = character.pixelPos.x + movementX * dt * 10 * character.speed
		character.pixelPos.y = character.pixelPos.y + movementY * dt * 10 * character.speed
	end
end

function M.update(character, dt)
	moving(character, dt)
end

function M.collidesWithPoint(character, x, y)
	position.comparePixelPos(x, y, character.pixelPos.x, character.pixelPos.y)
end

local function draw(image, x, y, rot, w, h)
	local rot = utils.deg2rad(rot)
	local imgW,imgH = image:getDimensions()
	local sx = w / imgW
	local sy = h / imgH
	local ox = imgW / 2
	local oy = imgH / 2
	love.graphics.draw(image, x+w/2 , y+h/2, rot, sx, sy, ox, oy)
end

function M.drawShadow(character)
	local tw = M.map.options.tile.width
	local th = M.map.options.tile.height
	local x = character.pixelPos.x
	local y = character.pixelPos.y
	draw(M.sprites.shadow, x, y, 0, tw, th)

	local tx = character.nextTile.x * tw
	local ty = character.nextTile.y * th
	love.graphics.setColor(255, 255, 255, 50)
	draw(M.sprites.target, tx, ty, 0, tw, th)
	love.graphics.setColor(255, 255, 255, 255)
end

function M.draw(character, image)
	local tw = M.map.options.tile.width
	local th = M.map.options.tile.height
	local x = character.pixelPos.x
	local y = character.pixelPos.y
	local rot = utils.dir2rot(character.dir)
	draw(image, x, y, rot, tw, th)
end

return M
