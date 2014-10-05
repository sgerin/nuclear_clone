function init_queue()
	queue = {}
	queue.heap_size = 0
end

function siftdown(i)
	if i > 0 and i <= queue.heap_size then
		n = queue[i]
		if left(i) <= queue.heap_size and queue[left(i)].f < n.f then 
			bigger = left(i)
		else
			bigger = i
		end
		if right(i) <= queue.heap_size and queue[right(i)].f < queue[bigger].f then
			bigger = right(i)
		end
		if bigger ~= i then
			swap(i, bigger)
			siftdown(bigger)
		end
	end
end

function siftup(i)
	if i > queue.heap_size then
		print("PROBLEM siftup\n")
		return
	end
	s1 = queue[i];
	while i > 1 and s1.f < queue[parent(i)].f do
		queue[i] = queue[parent(i)]
		queue[i].heap_index = i 
		i = parent(i)
	end
	queue[i] = s1
	queue[i].heap_index = i
end

function build_heap()
	for i=queue.heap_size/2, 1, -1 do
		siftdown(i)
	end
end
	
function heap_sort()
	build_heap()
	n = queue.heap_size
	while queue.heap_size >= 2 do
		swap(queue.heap_size, 1)
		queue.heap_size = queue.heap_size - 1
		siftdown(1)
	end
	i = 1
	j = n 
	queue.heap_size = n
	while i < j do
		swap(i, j);
		i = i + 1;
		j = j - 1;
	end
end

function extract_max()
	if queue.heap_size < 1 then
		return nil
	end
	max = queue[1]
	max.heap_index = nil
 	queue[1] = queue[queue.heap_size]
	queue[queue.heap_size] = nil
	queue.heap_size = queue.heap_size-1
	siftdown(1)
	return max
end
	
function get_max()
	if queue.heap_size < 1 then
		return nil
	end
	return queue[1]
end

function insert(node)
	queue.heap_size = queue.heap_size+1;
	i = queue.heap_size;
	queue[i] = node;
	node.heap_index = i; 
	siftup(i);
end

function swap(i, j)
	if i > 0 and j > 0 and i <= queue.heap_size and j <= queue.heap_size then
		queue[i], queue[j] = queue[j], queue[i]
		queue[i].heap_index, queue[j].heap_index = i, j
	end
end

function remove(node)
	index = node.heap_index
	if not index then 
		return
	end
	queue[index] = queue[queue.heap_size]
	queue[queue.heap_size] = nil
	queue.heap_size = queue.heap_size - 1
	node.heap_index = nil
	if index == 1 then
		siftdown(i)
	elseif queue[index].f < queue[parent(index)].f then
		siftup(i)
	elseif queue[index].f > queue[right(index)].f or queue[index].f > queue[right(index)].f then
		siftdown(i)
	end
end

function left(i)
	return i*2
end

function right(i)
	return i*2+1
end

function parent(i)
	return (i/2) - (i/2)%1;
end