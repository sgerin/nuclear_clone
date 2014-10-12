local unpack = unpack or table.unpack

function build_graph(tiletable, tilewidth, tileheight)
	graph = {}
	local index = 1
	w = #tiletable[1]
	h = #tiletable
    for rowIndex,row in ipairs(tiletable) do
		for columnIndex,char in ipairs(row) do
			local node = {}
			graph[index] = node
			node.index = index
			node.x = (columnIndex-1)*tilewidth + tilewidth/2
			node.y = (rowIndex-1)*tileheight + tileheight/2
			node.adj = {}
			node.cost = {}
			node.type = char
			if char ~= "b" then
				node.old_type = char
			else
				node.old_type = " "
			end
			index = index+1
		end
	end
	
	index = 1
	for rowIndex,row in ipairs(tiletable) do
		for columnIndex,char in ipairs(row) do
			local node = graph[index]
			if node.type ~= "o" then
				--4 adjacent neighbours
				if columnIndex ~= 1 and graph[index-1].type ~= "o" then
					node.adj[index - 1] = true
				end
				if columnIndex ~= w and graph[index+1].type ~= "o" then
					node.adj[index + 1] = true
				end
				if rowIndex ~= 1 and graph[index-w].type ~= "o"  then
					node.adj[index - w] = true
				end
				if rowIndex ~= h and graph[index+w].type ~= "o"  then
					node.adj[index + w] = true
				end
				--8 adjacent remaining neighbours
				--[[if columnIndex ~= 1 and rowIndex ~= 1 and graph[index-w-1].type ~= "o" then
					node.adj[index - w - 1] = true
				end
				if columnIndex ~= w and rowIndex ~= 1 and graph[index-w+1].type ~= "o" then
					node.adj[index - w + 1] = true
				end
				if rowIndex ~= h and columnIndex ~= 1 and graph[index+w-1].type ~= "o"  then
					node.adj[index + w - 1] = true
				end
				if rowIndex ~= h and columnIndex ~= w and graph[index+w+1].type ~= "o"  then
					node.adj[index + w + 1] = true
				end]]--
			end
			for k, v in pairs(node.adj) do
				if graph[k].type == "r" and node.type == "r" then
					node.cost[k] = 10
				elseif graph[k].type == " " and node.type == "r" then
					node.cost[k] = 10
				elseif graph[k].type == "r" and node.type == " " then
					node.cost[k] = 10
				else
					node.cost[k] = 1
				end
			end
			index = index+1
		end
	end
	return graph
end

function print_graph(tiletable)
	string_map = ""
	for _, node in pairs(graph) do
		local string_info_node = "node: " .. node.index .. " x " .. node.x .. " y " .. node.y .. " adj: "
		for k, v in pairs(node.adj) do
			string_info_node = string_info_node .. k .. " "
		end
		print(string_info_node)
		string_map = string_map .. node.type
		if node.index%w == 0 then
			string_map = string_map .. "\n"
		end
	end
	print(string_map)
end