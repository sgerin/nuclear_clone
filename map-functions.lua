-- declaring local variables that will be used only inside map-functions.lua
local tileW, tileH, tileset, quads, tileTable, window_width, window_height

function loadMap(path)
  love.filesystem.load(path)() -- attention! extra parenthesis
  return window_height, window_width, tileTable, tileW, tileH
end

function newMap(tileWidth, tileHeight, tilesetPath, tileString, quadInfo)
  
  tileW = tileWidth
  tileH = tileHeight
  tileset = love.graphics.newImage(tilesetPath)
  
  local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()
  
  quads = {}
  
  for _,info in ipairs(quadInfo) do
    quads[info[1]] = love.graphics.newQuad(info[2], info[3], tileW,  tileH, tilesetW, tilesetH)
  end
  
  tileTable = {}
  
  local width = #(tileString:match("[^\n]+"))

  --for x = 1,width do tileTable[x] = {} end

  local rowIndex,columnIndex = 1,1
  for row in tileString:gmatch("[^\n]+") do
    assert(#row == width, 'Map is not aligned: width of row ' .. tostring(rowIndex) .. ' should be ' .. tostring(width) .. ', but it is ' .. tostring(#row))
    tileTable[rowIndex] = {}
	columnIndex = 1
    for character in row:gmatch(".") do
      tileTable[rowIndex][columnIndex] = character
      columnIndex = columnIndex + 1
    end
    rowIndex=rowIndex+1
  end
  window_height, window_width = (rowIndex-1)*tileH, (columnIndex-1)*tileW
end

function drawMap()
  for rowIndex,row in ipairs(tileTable) do
    for columnIndex,char in ipairs(row) do
      local y,x = (rowIndex-1)*tileW, (columnIndex-1)*tileH
      love.graphics.draw(tileset, quads[ char ] , x, y)
    end
  end
end

function draw_map(graph, x_offset, y_offset)
	for _, node in pairs(graph) do
        local y,x = node.y-tileheight/2, node.x-tilewidth/2 --(rowIndex-1)*tileW, (columnIndex-1)*tileH
        love.graphics.draw(tileset, quads[node.type], x+x_offset, y+y_offset)
	end
end
