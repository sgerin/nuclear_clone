require 'map-functions'
require 'pathfinding'
require 'graph'
require 'priority_queue'


function love.load()
	math.randomseed(os.time())
	window_height, window_width, tiletable, tilewidth, tileheight = loadMap('maps/desert.lua')
	love.window.setMode(window_width, window_height)
	graph = build_graph(tiletable, tilewidth, tileheight)
	goal = find_goal()
	start = 0
	changed_start = false
	start_is_defined = false
end

function love.draw()
	drawMap()
	if path then
		for k, v in pairs(path) do
			current = path[k]
			next = path[k+1]
			if current and next then
				love.graphics.line(current.x, current.y, next.x, next.y)
			end
		end
		if start_is_defined == true then
			love.graphics.circle( "fill", start.x, start.y, 7, 100 )
		end 
	else
		for _, node in pairs(graph) do
			love.graphics.point(node.x, node.y )
			for k, v in pairs(node.adj) do
				love.graphics.line(node.x, node.y, graph[k].x, graph[k].y)
			end
		end
	end
end

function love.update(dt)
	if goal and start and changed_start then
		path = a_star(graph, start, goal)
		changed_start = false
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

function love.mousereleased(x, y, button)
	if button == "l" then
		for _, node in pairs(graph) do
			if x > node.x-tilewidth/2 and x < node.x+tilewidth/2 and y > node.y-tileheight/2 and y < node.y+tileheight/2 then
				if node.type == " " then
					changed_start = true
					start_is_defined = true
					start = node
					break
				end
			end
		end
	end
end
