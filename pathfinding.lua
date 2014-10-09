require 'priority_queue'

function heuristic(node, goal)
	dx = math.abs(node.x - goal.x)
    dy = math.abs(node.y - goal.y)
	d = 1
	return d * (dx + dy) 
end

function a_star(graph, starting_node, goal)
	local closed = {}
	local open = {}
	init_queue()
	starting_node.g = 0
	insert(starting_node)
	open[starting_node] = true
	while get_max() ~= goal do
		local current = extract_max()
		if not current then
			return nil
		end
		closed[current.index] = true
		open[current.index] = false

		for k, v in pairs(current.adj) do
			local neighbour = graph[k]
			local cost = current.g + current.cost[k]
			if open[neighbour] == true and cost < neighbour.g then
				open[neighbour] = false
				remove(neighbour)
			end
			if closed[neighbour] == true and cost < neighbour.g then
				closed[neighbour] = false
			end
			if not closed[neighbour] and not open[neighbour] then
				neighbour.g = cost
				open[neighbour] = true
   				remove(neighbour)
				neighbour.f = neighbour.g + heuristic(neighbour, goal)
				insert(neighbour)
				neighbour.parent = current
			end
		end
	end
	local path = {}
	local current = goal
	i = 1
	while current ~= starting_node do
		path[i] = current
		--print(current.index)
		current = current.parent 
		i = i+1
	end
	path[i] = current
	
	closed = {}
	open = {}
	for _, node in pairs(graph) do
		node.g = nil
		node.f = nil
		node.heap_index = nil
	end
	
	return path
end