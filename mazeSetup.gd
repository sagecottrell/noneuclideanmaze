class_name MazeSetup


static func setup(count: int, max_connections: int) -> Dictionary[int, Array]:
	var map: Dictionary[int, Array] = {}
	
	var groups: Array[Array] = []
	
	var can_connect = func(x): 
		return map[x].size() < max_connections
	
	var one_connection = func(x):
		return map[x].size() == 1
	
	for i in range(count):
		map[i] = []
		groups.append([i])
	
	while groups.size() > 1:
		var r1: Array = groups.pick_random()
		groups.erase(r1)
		var r2: Array = groups.pick_random()
		groups.erase(r2)
		
		# make sure there are enough nodes in the group that has enough spare connections
		var r1f = r1.filter(can_connect)
		var r2f = r2.filter(can_connect)
		
		if r1f.size() == 0 or r2f.size() == 0:
			if r2f.size() != 0:
				groups.append(r2)
			if r1f.size() != 0:
				groups.append(r1)
			continue
		
		var r1node = r1f.pick_random()
		var r2node = r2f.pick_random()
		
		map[r1node].append(r2node)
		map[r2node].append(r1node)
		r1f.append_array(r2f)
		groups.append(r1f)
	
	var dead_ends = map.keys().filter(one_connection)
	for i in range(dead_ends.size() / 2):
		var a = dead_ends[i * 2]
		var b = dead_ends[i * 2 + 1]
		map[a].append(b)
		map[b].append(a)
	
	return map
