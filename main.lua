require 'map-functions'
require 'pathfinding'
require 'graph'
require 'priority_queue'

max_window_width = 960
max_window_height = 640

function love.load()
	math.randomseed(os.time())
	local joysticks = love.joystick.getJoysticks()
	joystick = joysticks[1]
	x_offset = 0
	y_offset = 0
    love.keyboard.setKeyRepeat(true)
	mainFont = love.graphics.newFont("fonts/gotham_htf_book.otf", 20);
	window_height, window_width, tiletable, tilewidth, tileheight = loadMap('maps/desert.lua')
	print(window_height)
	--window_width = (window_width > max_window_width) and max_window_width or window_width
	--window_height = (window_height > max_window_height) and max_window_height or window_height
	if window_width ~= 960 or window_height ~= 640 then
		love.event.quit( )
	end
	love.window.setMode(window_width, window_height)
	graph = build_graph(tiletable, tilewidth, tileheight)
	player_node = find_player()
	player = {}
	player.velocity = 500
	player.x, player.y = get_node_center(player_node)
	ennemies = {}
	start_is_defined = false
	place_ennemies(20)
	paths = {}
	paths.computed = false
	start = nil
	changed_start = false
	changed_goal = false
end

function love.draw()
	--drawMap()
	draw_map(graph, x_offset, y_offset)
	if paths and paths.computed then
		for _, path in ipairs(paths) do
			for k, v in pairs(path) do
				current = path[k]
				next = path[k+1]
				if current and next then
					love.graphics.line(current.x+x_offset, current.y+y_offset, next.x+x_offset, next.y+y_offset)
				end
			end
		end
		if start_is_defined == true then
			--love.graphics.circle( "fill", start.x+x_offset, start.y+y_offset, 7, 100 )
			for k, ennemy in ipairs(ennemies) do
				love.graphics.rectangle("fill", ennemy.node.x+x_offset-tilewidth/2, ennemy.node.y+y_offset-tileheight/2, tilewidth, tileheight)
			end
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
	--[[if mouse_pressed then
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
	end ]]
	if player_node and ennemies.number ~= 0 and (changed_start or changed_goal) then
		for k, ennemy in ipairs(ennemies) do
			paths[k] = a_star(graph, ennemy.node, player_node)
			paths.computed = true
		end
		changed_start = false
		changed_goal = false
	end
	if not joystick then return end
	local x = player.x
	local y = player.y
	if math.abs(joystick:getAxis(1)) > 0.2 then
		x = x + dt*joystick:getAxis(1)*player.velocity
	end
	if math.abs(joystick:getAxis(2)) > 0.2 then
		y = y + dt*joystick:getAxis(2)*player.velocity
	end
	if joystick:isGamepadDown("a") then
		player_attack()
	end
		
	--if(math.abs(joystick:getAxis(4)) > 0.2) then
	--	player.x = player.x + dt*joystick:getAxis(4)*player.velocity
	--end
	--if(math.abs(joystick:getAxis(3)) > 0.2) then
	--	player.y = player.y + dt*joystick:getAxis(3)*player.velocity
	--end
	is_node_valid = update_player_node(x, y)
	if is_node_valid == true then
		player.x = x
		player.y = y
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

function place_ennemies(number)
	for i=1, number do
		repeat
			index = math.random(#graph)
		until graph[index].type == " "
		local node = graph[index]
		x, y = node.x, node.y
		ennemies[i] = {}
		ennemies[i].life = 1
		ennemies[i].node = node
	end
	start_is_defined = true
	changed_start = true
	ennemies.number = number
end

function find_player()
	for _, node in pairs(graph) do
		if node.type == "b" then
			player_node = node
			--x_offset = -player.x/2
			--y_offset = -player.y/2
			break
		end
	end
	return player_node
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
	local old_player_node = player_node		
	local index = player_node.index
	local new_index = nil
	local w = #tiletable[1]
	local xoffset = 0
	local yoffset = 0
	if key == "left" then
		new_index = player_node.index - 1
		xoffset = 32
	elseif key == "right" then
		new_index = player_node.index + 1
		xoffset = -32
	elseif key == "down" then
		new_index = player_node.index + w
		yoffset = 32
	elseif key == "up" then		
		new_index = player_node.index - w
		yoffset = -32
	end
	if new_index then		
		neighbour = graph[new_index]
		if neighbour then
			if neighbour.type ~= "o" then
				player_node.type = player_node.old_type
				neighbour.old_type = neighbour.type
				neighbour.type = "b"
				player_node = neighbour
				--x_offset = x_offset + xoffset
				--y_offset = y_offset + yoffset
			end
		end
	end
	if old_player_node ~= player_node then
		changed_goal = true
	end
	neighbour = nil
end

function get_node_center(node)
	return node.x, node.y
end

function update_player_node(x, y)
	if x > player_node.x + tilewidth/2 or x < player_node.x - tilewidth/2 or 
	y > player_node.y + tileheight/2 or y < player_node.y - tileheight/2 then
		for _, node in pairs(graph) do
			if x < node.x + tilewidth/2 and x > node.x - tilewidth/2 and 
			y < node.y + tileheight/2 and y > node.y - tileheight/2 then
				if node.type == "o" then
					return false
				else
					player_node.type = player_node.old_type
					player_node = node
					player_node.type = "b"
					changed_goal = true
					return true
				end
			end
		end
	end
	return true
end

function player_attack()
	--print("attack")
	dead_ennemies = {}
	for k, ennemy in ipairs(ennemies) do
		if ennemy.node.x < player_node.x+50 and ennemy.node.x > player_node.x-50 and ennemy.node.y < player_node.y+50 and ennemy.node.y > player_node.y-50 then
			hurt_ennemy(ennemy, k)
		end
	end
	--table.sort(dead_ennemies)
	for k, v in pairs(dead_ennemies) do
		table.remove(ennemies, v)
		table.remove(paths, v)
		ennemies.number = ennemies.number -1
	end
	print(ennemies.number)
end

function hurt_ennemy(ennemy, k)
	--hurt_ennemy
	ennemy.life = ennemy.life-1
	if ennemy.life == 0 then
		kill_ennemy(ennemy, k, dead_ennemies)
	end
end

function kill_ennemy(ennemy, k, dead_ennemies)
	print("kill")
	dead_ennemies[#dead_ennemies+1] = k
	--table.remove(ennemies, k)
	--ennemies.number = ennemies.number - 1
end