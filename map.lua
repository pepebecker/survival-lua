local json = require 'lib.json'
local utils = require 'utils'

local M = {}

function M.loadAssets()
	M.shadows = {}
	M.shadows.side = love.graphics.newImage('images/shadow-side.png')
	M.shadows.cornerOutsie = love.graphics.newImage('images/shadow-corner-outside.png')
	M.shadows.cornerInside = love.graphics.newImage('images/shadow-corner-inside.png')
end

function M.getTile(map, x, y)
	if x < 1 or y < 1 or x > #map.tiles[y] or y > #map.tiles then
		return {
			x = x,
			y = y,
			outside = true,
			walkable = false,
			shadow = {
				cast = false,
				receive = false,
			},
		}
	end
	return map.tiles[y][x]
end

function M.createTile(map, x, y, sx, sy, walkable, wall)
	local w = map.options.sprite.width
	local h = map.options.sprite.height
	local sprite = love.graphics.newQuad(sx * w, sy * h, w, h, map.tileset:getDimensions())
	return {
		x = x,
		y = y,
		w = w,
		h = h,
		sprite = sprite,
		walkable = walkable,
		wall = wall,
		shadow = {
			cast = false,
			receive = false,
		},
	}
end

function M.load(path)
	contents,_ = love.filesystem.read(path)
	local map = json.decode(contents)
	map.tileset = love.graphics.newImage('images/' .. map.options.tileset)

	for row=1,#map.tiles do
		for col=1,#map.tiles[row] do
			local tileType = map.options.types[map.tiles[row][col]]
			local x = col-1
			local y = row-1
			local sx = tileType.sx
			local sy = tileType.sy
			local walkable = tileType.walkable
			local wall = tileType.wall
			local tile = M.createTile(map, x, y, sx, sy, walkable, wall)
			if tileType.shadow then
				tile.shadow = tileType.shadow
			end
			map.tiles[row][col] = tile
		end
	end

	return map
end

function M.draw(map)
	local tileset = map.tileset
	local sx = map.options.tile.width / map.options.sprite.width
	local sy = map.options.tile.height / map.options.sprite.height
	for row=1,#map.tiles do
		for col=1,#map.tiles[row] do
			local tile = map.tiles[row][col]
			local x = tile.x * map.options.tile.width
			local y = tile.y * map.options.tile.height
			love.graphics.draw(tileset, tile.sprite, x, y, 0, sx, sy)
		end
	end
	M.drawShadows(map)
end

function M.drawShadows(map)
	local spriteW,spriteH = M.shadows.side:getDimensions()
	local tw = map.options.tile.width
	local th = map.options.tile.height
	local sx = (tw / spriteW) * .5
	local sy = (th / spriteH) * .5

	function drawCornerInside(x, y, rot, sx, sy)
		love.graphics.draw(M.shadows.cornerInside, x+(tw/2)*sx, y+(th/2)*sy, utils.deg2rad(rot), sx, sy, tw/2, th/2)
	end

	function drawSide(x, y, rot, sx, sy)
		love.graphics.draw(M.shadows.side, x+(tw/2)*sx, y+(th/2)*sy, utils.deg2rad(rot), sx, sy, tw/2, th/2)
	end

	function drawCornerOutside(x, y, rot, sx, sy)
		love.graphics.draw(M.shadows.cornerOutsie, x+(tw/2)*sx, y+(th/2)*sy, utils.deg2rad(rot), sx, sy, tw/2, th/2)
	end

	function doesCast(col, row)
		return M.getTile(map, col, row).shadow.cast
	end

	for row=1,#map.tiles do
		for col=1,#map.tiles[row] do
			local tile = M.getTile(map, col, row)
			local receive = tile.shadow.receive
			if receive then
				local tl,tr,bl,br = false,false,false,false
				local tx = (col - 1) * map.options.tile.width
				local ty = (row - 1) * map.options.tile.height
				local top = doesCast(col, row - 1)
				local left = doesCast(col - 1, row)
				local right = doesCast(col + 1, row)
				local bottom = doesCast(col, row + 1)
				local topLeft = doesCast(col - 1, row - 1)
				local topRight = doesCast(col + 1, row - 1)
				local bottomLeft = doesCast(col - 1, row + 1)
				local bottomRight = doesCast(col + 1, row + 1)

				if left and top then
					drawCornerInside(tx, ty, 0, sx, sy)
					tl = true
				end

				if top and right then
					drawCornerInside(tx+tw/2, ty, 90, sx, sy)
					tr = true
				end

				if right and bottom then
					drawCornerInside(tx+tw/2, ty+th/2, 180, sx, sy)
					br = true
				end

				if bottom and left then
					drawCornerInside(tx, ty+th/2, 270, sx, sy)
					bl = true
				end

				if left then
					if not tl then
						drawSide(tx, ty, 0, sx, sy)
					end
					if not bl then
						drawSide(tx, ty+th/2, 0, sx, sy)
					end
				end

				if top then
					if not tl then
						drawSide(tx, ty, 90, sx, sy)
					end
					if not tr then
						drawSide(tx+tw/2, ty, 90, sx, sy)
					end
				end

				if right then
					if not tr then
						drawSide(tx+tw/2, ty, 180, sx, sy)
					end
					if not br then
						drawSide(tx+tw/2, ty+th/2, 180, sx, sy)
					end
				end

				if bottom then
					if not bl then
						drawSide(tx, ty+th/2, 270, sx, sy)
					end
					if not br then
						drawSide(tx+tw/2, ty+th/2, 270, sx, sy)
					end
				end

				if topLeft and not top and not left then
					drawCornerOutside(tx, ty, 0, sx, sy)
				end

				if topRight and not top and not right then
					drawCornerOutside(tx+tw/2, ty, 90, sx, sy)
				end

				if bottomRight and not bottom and not right then
					drawCornerOutside(tx+tw/2, ty+th/2, 180, sx, sy)
				end

				if bottomLeft and not bottom and not left then
					drawCornerOutside(tx, ty+th/2, 270, sx, sy)
				end
			end
		end
	end
end

return M
