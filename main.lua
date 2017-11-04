local map = require 'map'
local zombie = require 'zombie'
local player = require 'player'
local bullet = require 'bullet'

local maps = {}
local bullets = {}
local currentMapIndex = 1
local survivor

function love.load()
	love.window.setTitle('Survival')

	map.loadAssets()

	table.insert(maps, map.load('maps/map1.json'))

	local currentMap = maps[currentMapIndex]

	zombie.loadAssets()
	zombie.init(currentMap)

	player.loadAssets()
	player.init(currentMap)
	local start = currentMap.options.start
	survivor = player.create(start.x, start.y, start.dir)

	for i=1,#zombie.list do
		zombie.setTarget(zombie.list[i], survivor)
	end
end

function shoot(survivor, dx, dy)
	local bullet = player.shoot(survivor, dx, dy)
	if bullet then
		table.insert(bullets, bullet)
	end
end

function handleInput(dt)
	if love.keyboard.isDown('up') then
		player.move(survivor, 0, -1)
	end
	if love.keyboard.isDown('down') then
		player.move(survivor, 0, 1)
	end
	if love.keyboard.isDown('left') then
		player.move(survivor, -1, 0)
	end
	if love.keyboard.isDown('right') then
		player.move(survivor, 1, 0)
	end

	if love.keyboard.isDown('w') then
		shoot(survivor, 0, -1)
	end
	if love.keyboard.isDown('s') then
		shoot(survivor, 0, 1)
	end
	if love.keyboard.isDown('a') then
		shoot(survivor, -1, 0)
	end
	if love.keyboard.isDown('d') then
		shoot(survivor, 1, 0)
	end
end

function love.update(dt)
	player.update(survivor, dt)

	for i=1,#zombie.list do
		zombie.update(zombie.list[i], dt)
	end

	for i=1,#bullets do
		bullet.update(bullets[i], dt)
	end

	handleInput(dt)
end

function love.draw()
	currentMap = maps[currentMapIndex]
	opts = currentMap.options
	map.draw(currentMap)

	-----------------------------------
	-- draw shadows
	-----------------------------------

	player.drawShadow(survivor)

	for i=1,#zombie.list do
		zombie.drawShadow(zombie.list[i])
	end

	-----------------------------------
	-- draw bullets
	-----------------------------------

	for i=1,#bullets do
		bullet.draw(bullets[i])
	end

	-----------------------------------
	-- draw characters
	-----------------------------------

	player.draw(survivor)

	for i=1,#zombie.list do
		zombie.draw(zombie.list[i])
	end
end
