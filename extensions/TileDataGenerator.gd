extends "res://content/map/generation/TileDataGenerator.gd"

const TILE_DETONATOR = 11
const TILE_DESTROYER = 12
const TILE_MEGA_IRON = 13
const TILE_BAD_RELIC = 14 
const TILE_FAKE_BORDER = 16
const TILE_SECRET_ROOM = 17
const TILE_CHAOS = 18

var data_mod


const rate_list = [0 , 0.5 , 1 , 3 , 5 , 10 , 25 , 50 , 75 ]

func get_generation_data(a):
	## 4th decimal of max_tile_count_deviation for detonator rate
	var detonator_rate_index = a.max_tile_count_deviation*10**3
	detonator_rate_index -= floor(detonator_rate_index)
	detonator_rate_index *= 10
	detonator_rate_index = floor(detonator_rate_index)
	
	## 5th decimal of max_tile_count_deviation decimals for destroyer_rate_index
	var destroyer_rate_index = a.max_tile_count_deviation*10**4
	destroyer_rate_index -= floor(destroyer_rate_index)
	destroyer_rate_index *= 10
	destroyer_rate_index = floor(destroyer_rate_index)
	
	## 6th decimalsof max_tile_count_deviation for mega_iron_rate_index
	var mega_iron_rate_index = a.max_tile_count_deviation*10**5
	mega_iron_rate_index -= floor(mega_iron_rate_index)
	mega_iron_rate_index *= 10
	mega_iron_rate_index = floor(mega_iron_rate_index)
	
	## 3rd decimal of viability_thin_top_width for bad_relics
	var bad_relics = a.viability_thin_top_width*10**2
	bad_relics -= floor(bad_relics)
	bad_relics *= 10
	bad_relics = floor(bad_relics)
	
	## 4th decimal of viability_thin_top_width for secret_rooms
	var secret_rooms = a.viability_thin_top_width*10**3
	secret_rooms -= floor(secret_rooms)
	secret_rooms *= 10
	secret_rooms = floor(secret_rooms)
	
	## 3rd decimalsof viability_thin_top_length for chaos_rate
	var chaos_rate_index = a.viability_thin_top_length*10**2
	chaos_rate_index -= floor(chaos_rate_index)
	chaos_rate_index *= 10
	chaos_rate_index = floor(chaos_rate_index)
	
	var detonator_rate = rate_list[detonator_rate_index]
	var destroyer_rate = rate_list[destroyer_rate_index]
	var mega_iron_rate = rate_list[mega_iron_rate_index]
	var chaos_rate = rate_list[chaos_rate_index]
	
	
	#print("raw max_tile_count_deviation : ", a.max_tile_count_deviation)
	#print("raw viability_thin_top_width : ", a.viability_thin_top_width)
	#print("raw viability_thin_top_length : " , a.viability_thin_top_length)
	#print("computed detonator_rate " , detonator_rate)
	#print("computed destroyer_rate " , destroyer_rate)
	#print("computed mega_iron_rate " , mega_iron_rate)
	#print("computed bad_relics " , bad_relics)
	#print("computed secret_rooms " , secret_rooms)
	#print("computed chaos_rate " , chaos_rate)
	
	return [detonator_rate , mega_iron_rate , mega_iron_rate, bad_relics, secret_rooms,chaos_rate]
	
func generate_resources(rand):
	var data_from_mod = get_generation_data(a)
	var detonator_rate = data_from_mod[0]
	var destroyer_rate = data_from_mod[1]
	var mega_iron_rate = data_from_mod[2]
	var bad_relics = data_from_mod[3]
	var chaos_rate = data_from_mod[5]
	
	var original_cell_coords:Array = $MapData.get_used_biome_cells()
	var borderCells = findOutsideBorderCells()
	
	for cell in $MapData.get_used_biome_cells():
		if $MapData.get_resourcev(cell) < 0:
			$MapData.set_resourcev(cell, Data.TILE_DIRT_START)
	
	Utils.shuffle(original_cell_coords, rand)
	gen_stage = 4.1
	startTimer("generate_iron_clusters")
	generate_iron_clusters(original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.2
	startTimer("generate_gadget_chambers")
	generate_gadget_chambers()
	endTimer()
	gen_stage = 4.3
	startTimer("generate_power_cores")
	generate_power_cores()
	endTimer()
	gen_stage = 4.4
	if bad_relics == 0:
		startTimer("generate_relics")
		generate_relics()
	else :
		### Added vvvvvv
		startTimer("generate_bad_relics")
		generate_bad_relics(bad_relics)
		### Added ^^^^^^
		
	endTimer()
	gen_stage = 4.5
	startTimer("adjust_ore_amounts")
	adjust_ore_amounts()
	endTimer()
	gen_stage = 4.6
	startTimer("expand_iron_clusters")
	var ironClusterCenters = $MapData.get_resource_cells_by_id(Data.TILE_IRON).duplicate()
	expand_iron_clusters(ironClusterCenters)
	endTimer()
	gen_stage = 4.7
	startTimer("generate_water")
	generate_water(ironClusterCenters, original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.8
	startTimer("generate_cobalt")
	generate_cobalt(ironClusterCenters, original_cell_coords, borderCells)
	endTimer()
	gen_stage = 4.9
	startTimer("generate_holes")
	var averageCellCountInBiome = a.tileCount/(maxBiome+1)
	generate_holes(rand, averageCellCountInBiome)
	endTimer()
	
	### Added vvvvvv

	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,detonator_rate, TILE_DETONATOR)

	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,destroyer_rate, TILE_DESTROYER)
	
	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,mega_iron_rate, TILE_MEGA_IRON)

	generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells,chaos_rate, TILE_CHAOS)

func generate():
	if not viability_large_noise:
		return
	
	rand = RandomNumberGenerator.new()
	rand.seed = gen_seed
	a.randomize_values(rand)
	
	$MapData.clear()
	
	reportLog("--- TILE DATA GENERATOR REPORT ---")
	reportLog("Width: " + str(a.width))
	reportLog("Depth: " + str(a.depth))
	reportLog("Target Tile Count: " + str(a.tileCount))
	reportLog("Noise Large: " + str(a.viability_large_noise.resource_path.get_file()))
	reportLog("Noise Small: " + str(a.viability_small_noise.resource_path.get_file()))
	reportLog("Seed:" + str(gen_seed))
	
	startTimer("total_generation")
	gen_stage = 1
	startTimer("base shape")
	finishedSuccessful = generate_base_shape()
	endTimer()
	if not finishedSuccessful:
		reportError("generate_base_shape failed.")
		terminate_generation()
		return
	
	gen_stage = 2
	startTimer("biomes")
	finishedSuccessful = generate_biomes()
	endTimer()
	if not finishedSuccessful:
		reportError("generate_biomes failed.")
		terminate_generation()
		return

	gen_stage = 3
	startTimer("hardness")
	generate_hardness()
	endTimer()
	
	#if GameWorld.devMode:
		#var aa = $MapData.duplicate()
		#aa.name = "MapAfterBiomeGeneration"
		#aa.visible = false
		#add_child(aa)

	gen_stage = 4
	startTimer("border-1")
	generate_border_prepass()
	endTimer()
	
	if a.generateResources:
		startTimer("resources")
		generate_resources(rand)
		endTimer()
	
	startTimer("border-2")
	generate_border()
	endTimer()
	
	gen_stage = 5
	generate_fixed_entrance()
	
	### Added vvvvvv
	var secret_rooms = get_generation_data(a)[4]
	if secret_rooms == 0 :
		return
		
	var max_y = 0
	for i in range(1000):
		var pos = Vector2(randi_range(-15,15),max_y+5)
		if $MapData.get_resourcev(pos) != 19 and $MapData.get_biomev(pos) != -1:
			max_y +=2
	var secret_ending_dir = [Vector2.LEFT,Vector2.RIGHT][randi_range(0,1)]
	var start = Vector2(randi_range(-20, 20), floor(randf_range(0.7*max_y , 0.9*max_y)))
	while $MapData.get_resourcev(start) != 10 :
		start = Vector2(randi_range(-20, 20), floor(randf_range(0.7*max_y , 0.9*max_y)))
	generate_secret_room(start , secret_ending_dir, Vector2(4,2),1)
	
	
	
	### Max 9 secret rooms
	secret_rooms = min(9,secret_rooms)
	var range_dir_dim = [ [Vector2.LEFT,0.05, 0.15, 2, 2],
		[Vector2.LEFT,0.2, 0.3, 2, 2],
		[Vector2.LEFT,0.35, 0.45, 3 , 3],
		[Vector2.LEFT,0.5, 0.65, 3 , 3],
		[Vector2.RIGHT,0.05, 0.15, 2, 2],
		[Vector2.RIGHT,0.2, 0.3, 2, 2],
		[Vector2.RIGHT,0.35, 0.45, 3 , 3],
		[Vector2.RIGHT,0.5, 0.65, 3 , 3],
		[-1*secret_ending_dir,0.7,0.9,4,3]
		]
	var choices_left = 8


	for i in range(0, secret_rooms):
		
		var choice = range_dir_dim.pop_at(randi_range(0,choices_left))
		start = Vector2.ZERO
		while $MapData.get_resourcev(start) != 10 or start == Vector2.ZERO :
			start = Vector2(randi_range(-20, 20),floor(randf_range(choice[1]*max_y , choice[2]*max_y)))
		
		generate_secret_room(start ,choice[0] , Vector2(choice[3],choice[4]), 2)
		choices_left -= 1
		
		
	### Fill secret rooms with resources
	var room_contents = [Data.TILE_IRON, Data.TILE_SAND, Data.TILE_WATER]
	var max_sand = 4
	var max_water = 7
	room_contents.shuffle()
	for pos in $MapData.get_resource_cells_by_id(TILE_SECRET_ROOM):
		if $MapData.get_biomev(pos) == 1:
			continue
		$MapData.set_hardnessv(pos, 1)
		match room_contents[randi_range(0,2)]:
			Data.TILE_SAND:
				max_sand -= 1
				if max_sand <= 0 :
					$MapData.set_resourcev(pos, Data.TILE_IRON)
					continue
				$MapData.set_resourcev(pos, Data.TILE_SAND)
			Data.TILE_WATER:
				max_water -= 1
				if max_water <= 0 :
					$MapData.set_resourcev(pos, Data.TILE_IRON)
					continue
				$MapData.set_resourcev(pos, Data.TILE_WATER)
	
	### Added ^^^^^^
	endTimer()
	terminate_generation()
	
	


func generate_secret_room(start : Vector2 , dir : Vector2 , dimensions : Vector2, biome : int):
	var entrance_pos = find_wall_in_direction(start,dir)
	var pos
	var x_direction : Vector2
	var y_direction : Vector2
	if dir.x !=0:
		x_direction = dir
		y_direction = Vector2.UP
	if dir.y != 0 :
		y_direction = dir
		x_direction = Vector2.RIGHT
	
	# Offset so that the secret room doesn't block the way 
	# (the generation will overwrite some breakable tiles)
	var offset = 2
	
	## Create tunnel entrance
	for x in range(offset) : 
		for y in range(-1,2):
			pos = entrance_pos+x * x_direction + y*y_direction
			if y == 0:
				$MapData.set_hardnessv(pos , 7)
			else :
				$MapData.set_hardnessv(pos , 5)
				
			$MapData.set_resourcev( pos,19)
			$MapData.set_biomev(pos, biome)
			
	### Prepare all the border tiles to carve the cave later
	for x in range(-abs(x_direction.x - dir.x),dimensions.x+2) : 
		for y in range(-abs(y_direction.y - dir.y),dimensions.y+2):
			pos = entrance_pos+(x + offset) * x_direction + y*y_direction
			$MapData.set_resourcev( pos, 19)
			$MapData.set_hardnessv(pos , 5)
			$MapData.set_biomev(pos, biome)
			
	$MapData.set_resourcev(entrance_pos, 19)
	$MapData.set_hardnessv(entrance_pos ,7)
	$MapData.set_biomev(entrance_pos, biome)

	$MapData.set_resourcev(entrance_pos + offset*x_direction, -1)
	$MapData.set_hardnessv(entrance_pos+ offset*x_direction ,1)
	$MapData.set_biomev(entrance_pos+ offset*x_direction, biome)
	
	### Carving the cave
	for x in range(abs(dir.x),dimensions.x+1) : 
		for y in range(abs(dir.y),dimensions.y+1):
			pos = entrance_pos + (x + offset)* x_direction + y*y_direction
			$MapData.set_resourcev( pos, TILE_SECRET_ROOM)
			$MapData.set_hardnessv(pos , 1)
			$MapData.set_biomev(pos, biome)
	
	
func find_wall_in_direction(start,direction,max_distance_from_start = 100):
	var last_available_position = start

	var moved = direction
	var last_type = 10
	# Setting depth and then checking all tiles to the left / right to see where the glass can be placed
	while abs(moved.x)+abs(moved.y) < max_distance_from_start:
		if $MapData.get_resourcev(start + moved ) == 19 and last_type <= 18 \
		and last_type >= 0 :
			last_available_position = start + moved
		last_type = $MapData.get_resourcev(start + moved )
		moved += direction
		
	return last_available_position
	
func generate_bad_relics(badRelics):
# ADD RELIC CHAMBERS
	var remainingBadRelics = badRelics
	var failsafe = 100
	
	var currentRelicStep := 1
	while remainingBadRelics > 0:
		var xLeft = rand.randf_range(a.width * -0.5, a.width * -0.2)
		var xRight = rand.randf_range(a.width * 0.2, a.width * 0.5)
		var offsetY = currentRelicStep * a.relic_depth_step + 2 * max(currentRelicStep - 1, 0) * a.relic_depth_step
		var goalLeft = Vector2(resourceX + xLeft, a.depth - offsetY)
		var goalRight = Vector2(resourceX + xRight, a.depth - offsetY)
		
		failsafe -= 1
		if failsafe <= 0:
			reportError("Failsafe reached: failed to generate relic chamber")
			break
		var ironTiles = $MapData.get_resource_cells_by_id(Data.TILE_IRON)
		var bestCell:Vector2
		var bestD := 999999
		for cell in ironTiles:
			var left = goalLeft - Vector2(cell)
			var right = goalRight - Vector2(cell)
			var best = left if left.length() < right.length() else right
			var d = best.length()
			if d < bestD:
				bestD = d
				bestCell = cell
		
		var placed = tryPlace(TILE_BAD_RELIC, [bestCell, 
		bestCell + Vector2(-1,0),
		bestCell + Vector2(-1,1),
		bestCell + Vector2(0,-1),
		bestCell + Vector2(1,-1),
		bestCell + Vector2(0,1),
		bestCell + Vector2(1,0),
		bestCell + Vector2(1,1),
		bestCell + Vector2(2,0),
		bestCell + Vector2(2,1),
		bestCell + Vector2(0,2),
		bestCell + Vector2(1,2)])
		if placed:
			remainingBadRelics -= 1
			currentRelicStep += 1
			resourceMinY = resourceMinY + a.gadget_depth_step
			var deltaWidth = sign(bestCell.x) * a.width * 0.2 - bestCell.x
			resourceX = -bestCell.x - deltaWidth
			
	
	if remainingBadRelics != 0:
		reportError("Relic generation failed. Failed to place %s relics" % remainingBadRelics)
		
		
func generate_curstom_tiles(ironClusterCenters, original_cell_coords, borderCells, type_rate,typeId):
	var typeAmount = round(type_rate * 0.001 * original_cell_coords.size())
	var availableCells = $MapData.get_resource_cells_by_id(Data.TILE_DIRT_START)
	Utils.shuffle(availableCells,rand)
	var freeTileIndex = 0
	for _j in typeAmount:
		$MapData.set_resourcev(availableCells[freeTileIndex], typeId)
		freeTileIndex += 1
	var iterations = 100
	var totalMove = Vector2()
	var averagedLastTotalMoves = Vector2()
	var zeroMoves = 0
	
