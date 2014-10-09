require 'map-functions'
require 'pathfinding'
require 'graph'
require 'priority_queue'

max_window_width = 960
max_window_height = 720

function love.load()
	math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)
	mainFont = love.graphics.newFont("fonts/gotham_htf_book.otf", 20);
	window_height, window_width, tiletable, tilewidth, tileheight = loadMap('maps/desert.lua')
	window_width = (window_width > max_window_width) and max_window_width or window_width
	window_height = (window_height > max_window_height) and max_window_height or window_height
	love.window.setMode(window_width, window_height)
	graph = build_graph(tiletable, tilewidth, tileheight)
	goal = find_goal()
	start = nil
	changed_start = false
	changed_goal = false
	start_is_defined = false
	x_offset = 0
	y_offset = 0
end

function love.draw()
	--drawMap()
	draw_map(graph, x_offset, y_offset)
	if path then
		for k, v in pairs(path) do
			current = path[k]
			next = path[k+1]
			if current and next then
				love.graphics.line(current.x+x_offset, current.y+y_offset, next.x+x_offset, next.y+y_offset)
			end
		end
		if start_is_defined == true then
			love.graphics.circle( "fill", start.x+x_offset, start.y+y_offset, 7, 100 )
		end 
	else
		for _, node in pairs(graph) do
			love.graphics.point(node.x+x_offset, node.y+y_offset)
			for k, v in pairs(node.adj) do
				love.graphics.line(node.x+x_offset, node.y+y_offset, graph[k].x+x_offset, graph[k].y+y_offset)
			end
		end
	end
    love.graphics.setFont(mainFont);
    love.graphics.print("Current fps: "..tostring(love.timer.getFPS( )), 6, 6)
end

function love.update(dt)
	if mouse_pressed then
		x, y = love.mouse.getPosition()
		for _, node in pairs(graph) do
			if x > node.x-tilewidth/2 and x < node.x+tilewidth/2 and y > node.y-tileheight/2 and y < node.y+tileheight/2 then
				if node.type ~= "b" and node.type ~= "o" then
					changed_start = true
					start_is_defined = true
					start = node
					break
				end
			end
		end
	end
	if goal and start and (changed_start or changed_goal) then
		path = a_star(graph, start, goal)
		changed_start = false
		changed_goal = false
	end
end

function starting_position()
	repeat
		index = math.random(#graph)
	until graph[index].type == " "
	starting_node = graph[index]
	x, y = starting_node.x, starting_node.y
	start_is_defined = true
	return x, y
end

function find_goal()
	for _, node in pairs(graph) do
		if node.type == "b" then
			goal = node
			break
		end
	end
	return goal
end

function test_priority_queue()
	for _, node in pairs(graph) do
		node.f = node.index
		insert(node)
	end
	while queue.heap_size ~= 0 do
		print(extract_max().f)
	end
end

function love.mousepressed(x, y, button)
	mouse_pressed = true
end

function love.mousereleased(x, y, button)
	mouse_pressed = false
end

function love.keypressed(key, isrepeat)
	local old_goal = goal		
	local index = goal.index
	local new_index = nil
	local w = #tiletable[1]
	local xoffset = 0
	local yoffset = 0
	if key == "left" then
		new_index = goal.index - 1
		xoffset = 32
	elseif key == "right" then
		new_index = goal.index + 1
		xoffset = -32
	elseif key == "down" then
		new_index = goal.index + w
		yoffset = 32
	elseif key == "up" then		
		new_index = goal.index - w
		yoffset = -32
	end
	if new_index then		
		neighbour = graph[new_index]
		if neighbour then
			if neighbour.type ~= "o" then
				goal.type = goal.old_type
				neighbour.old_type = neighbour.type
				neighbour.type = "b"
				goal = neighbour
				x_offset = x_offset + xoffset
				y_offset = y_offset + yoffset
			end
		end
	end
	if old_goal ~= new_goal then
		changed_goal = true
	end
	neighbour = nil
end