local M = {}

function M.init(tileSize)
  M.tileSize = tileSize
end

function M.new(x, y)
	return {
    x = x,
    y = y
  }
end

function M.toPixelPos(x, y)
  return {
    x = x * M.tileSize,
    y = y * M.tileSize
  }
end

function M.fromPixelPos(x, y)
  return {
    x = math.floor(x / M.tileSize),
    y = math.floor(y / M.tileSize)
  }
end

function M.comparePixelPos(x1, y1, x2, y2)
  p1 = M.fromPixelPos(x1, y1)
  p2 = M.fromPixelPos(x2, y2)
  return p1.x == p2.x and p1.y == p2.y
end

function M.comparePixelPosToTilePos(x1, y1, x2, y2)
  p1 = M.fromPixelPos(x1, y1)
  return p1.x == x2 and p1.y == y2
end

return M
