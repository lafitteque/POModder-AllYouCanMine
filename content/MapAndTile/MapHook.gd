extends Node2D

@onready var data_mod = ModLoader.find_child("POModder-AllYouCanMine",true,false).data_mod

func revealTileVisually(map, tile, coord):
	if tile.type in ["detonator", "destroyer", "bad_relic", "glass", "chaos"]:
			map.revealTileVisually(coord) 
	elif tile.type ==  "mega_iron" :
			tile.richness = Data.ofOr("map.ironrichness", 2)
			map.revealTileVisually(coord) 
		
			
func addDrop(map, drop):	
	if "worldmodifieraprilfools" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []) and\
	drop is Drop and drop.type in data_mod.ALL_DROP_NAMES and drop.carriedBy.size() == 0:
		
		var rand_res = randf_range(0,1)
		if rand_res < 0.05 : 
			map.should_grow_count = 4
		elif rand_res < 0.1:
			map.should_be_small_count = 4
		elif rand_res < 0.15 : 
			map.should_grow_count = 1
		elif rand_res < 0.20:
			map.should_be_small_count = 1	
			
		if drop.global_position.y <= 20 :
			return true
		var old_position = drop.global_position 
		var all_keys = data_mod.DROP_FROM_TILES_SCENES.keys() 
		var rand_type = all_keys[data_mod.weighted_random(data_mod.APRIL_FOOLS_PROBABILITIES)]
		if rand_type == "nothing":
			return true
		drop = data_mod.DROP_FROM_TILES_SCENES.get(rand_type).instantiate()
		drop.global_position = old_position 
		if rand_res < 0.1 :
			return true
		map.add_child(drop)
		Style.init(drop)
		if ("type" in drop) and drop.type in data_mod.ALL_DROP_NAMES :
			drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))
		return true	
		
	return false

func modifyTileWhenRevealed(map,coord,typeId):
	if Data.ofOr("assignment.id","") == "speleologist" and typeId == Data.TILE_IRON:
		map.tileData.set_resourcev(Vector2(coord.x, coord.y), Data.TILE_DIRT_START) 
		map.tileData.set_hardnessv(Vector2(coord.x, coord.y), 1) 
	
func destroyTile(map, tile, withDropsAndSound):
	if withDropsAndSound and tile.type == "mega_iron":
		var sound = map.find_child("TileDestroyedIron",true,false).duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		sound.setSimulatedPosition(tile.global_position)
		map.add_child(sound)
		sound.play()
	if tile.type == "mega_iron":
		var drop = data_mod.DROP_FROM_TILES_SCENES.get(tile.type).instantiate()
		drop.position = tile.global_position + 0.6 * Vector2(GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE, GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE)
		drop.apply_central_impulse(Vector2(0, 10).rotated(randf() * TAU))
		map.addDrop(drop)
		GameWorld.incrementRunStat("resources_mined")
		
	
	var sound = null
	match tile.type:
		"mega_iron" :
			sound = map.find_child("TileDestroyedIron").duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		"glass":
			sound = map.find_child("TileDestroyedWater").duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		"fake_border":
			sound = map.find_child("TileDestroyedWater").duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		"chaos":
			sound = map.find_child("TileDestroyedWater").duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		
	if sound != null :	
		sound.setSimulatedPosition(tile.global_position)
		map.add_child(sound)
		sound.play()
		
		
func getSceneForTileType(tileType):
	if tileType == data_mod.TILE_BAD_RELIC:
		return preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/BadRelicChamber/BadRelicChamber.tscn")
	elif tileType == data_mod.TILE_FAKE_BORDER:
		return preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/hint_secret.tscn")

func init(map, fromDeserialize, defaultState):
	if not fromDeserialize:
		# tile data gets modified with creating chambers, so that should not be done on reload
		var clusterCenters = map.getResourceClusterTopLeft(data_mod.TILE_BAD_RELIC)
		for centerCoord in clusterCenters:
			map.addChamber(centerCoord, map.getSceneForTileType(data_mod.TILE_BAD_RELIC))
			
			
func beforeCaveGeneration(map, cavePackeScenes, minDistanceToCenter,rand):
	
	# Added : Coresaver + Speleologist vvvvvvvvv
	var coresaver_endings = data_mod.get_endings()
	
	var secret_room_tiles = map.tileData.get_resource_cells_by_id(data_mod.TILE_SECRET_ROOM)
	var coresaver_is_reloading = secret_room_tiles.size() == 0
	
	if !coresaver_is_reloading and  Level.loadout.modeId == "coresaver" and coresaver_endings.has("heavy_rock") :
		var heavy_rock_cave =  preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/heavy_rock_cave/HeavyRockCave.tscn").instantiate()
		var maxLayer = map.startingIronCountByLayer.size()
		addForcedCave(map, rand, heavy_rock_cave, maxLayer-1, 2,false)
		

	if !coresaver_is_reloading and Level.loadout.modeId == "coresaver" and coresaver_endings.has("secret") :
		for i in range(secret_room_tiles.size()-1,-1,-1):
			if map.tileData.get_biomev(secret_room_tiles[i]) >1:
				secret_room_tiles.pop_at(i)
			
		
		# Add cave
		var top_left = secret_room_tiles[0]
		for cell in secret_room_tiles:
			if cell.x <= top_left.x and cell.y <= top_left.y :
				top_left = cell
		var root_cave = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/RootCave/RootCave.tscn").instantiate()
		for coord in map.tileData.get_resource_cells_by_id(data_mod.TILE_SECRET_ROOM):
			map.tileData.set_resourcev(coord, Data.TILE_DIRT_START)
		root_cave.updateUsedTileCoords()
		map.addLandmark(top_left, root_cave)
		for c in root_cave.tileCoords:
			var absCoord = Vector2(top_left) + c
			map.tileData.clear_resource(absCoord)
		root_cave.visible = true
		
	if Data.ofOr("assignment.id","") == "speleologist":
		cavePackeScenes = []
		for cave in cavePackeScenes:
			print(cave.instantiate().name)
		var caves = [preload("res://content/caves/treecave/IronTreeCave.tscn"),
			preload("res://content/caves/cobaltcave/CobaltCave.tscn"),
			preload("res://content/caves/watercave/WaterCave.tscn")]
			
		var availableCaves:Array
		var caveCount := {}
		var maxLayer = map.startingIronCountByLayer.size()
		
		for cave in caves:
			for i in maxLayer:
				cavePackeScenes.insert(0, cave)

		for layerIndex in maxLayer+1:
			if availableCaves.is_empty():
				availableCaves = cavePackeScenes.duplicate()
			for cavePackedScene in availableCaves:
				var cave = cavePackedScene.instantiate() # yeah this is shit, but probably not noticable
				addForcedCave(map, rand, cave, layerIndex, 3,false)
				availableCaves.erase(cavePackedScene)
		return

func afterCaveGeneration(map, rand):
	var coresaver_endings = data_mod.get_endings()
	var secret_room_tiles = map.tileData.get_resource_cells_by_id(data_mod.TILE_SECRET_ROOM)
	var coresaver_is_reloading = secret_room_tiles.size() == 0
	
	if !coresaver_is_reloading and Level.loadout.modeId == "coresaver" and coresaver_endings.has("glass") :
		spawn_glass(map)
		var core_eater_cave = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEaterCave.tscn").instantiate()
		addCaveStartAndDirection(map, rand, core_eater_cave, Vector2.ZERO, Vector2.DOWN)
	
	# Add hints for secrets
	for coord in map.tileData.get_hardness_cells_by_grade(7):
		for i in range(-2,3):
			for j in range(-1,2):	
				var new_coord = coord+Vector2i(i,j)
				if map.tileData.get_resourcev(new_coord) == Data.TILE_DIRT_START :
					map.addChamber(new_coord, preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/hint_secret.tscn"))
	
	
	#### Section for assignment tiny planet
	if Data.ofOr("assignment.id","") == "tinyplanet":
		while map.tileData.get_remaining_mineable_tile_count() > 420 :
			var pos = map.tileData.get_resource_cells_by_id(Data.TILE_DIRT_START)[randi_range(0,map.tileData.get_resource_cells_by_id(Data.TILE_DIRT_START).size()-1)]
			map.tileData.set_resourcev(pos, -1)
			
func modmodifyTileWhenRevealed(map,coord,typeId):
	if Data.ofOr("assignment.id","") == "tinyplanet" :
		if map.tileData.get_hardnessv(coord) <= 4:
			map.tileData.set_hardnessv(coord, 0)
	return


func addForcedCave(main_node, rand, cave, biomeIndex, minDistanceToCenter, accept_higher_layer = true):
	var data_mod = main_node.get_node("/root/ModLoader/POModder-Dependency").data_mod
	var map_mods = main_node.get_tree().get_nodes_in_group("map-mods")
	
	cave.updateUsedTileCoords()

	# try for a few times to find a suitable spot for the cave
	for _i in 150:
		var cells = main_node.tileData.get_biome_cells_by_index(biomeIndex)
		if cells.size() < cave.tileCoords.size():
			accept_higher_layer = true
			break
			
		var cell = cells[rand.randi() % cells.size()]
		if abs(cell.x) < minDistanceToCenter:
			continue
		
		var is_area_free = true
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			is_area_free = is_area_free and not (main_node.tileData.get_resourcev(absCoord) in [data_mod.TILE_BAD_RELIC ,  Data.TILE_EMPTY, data_mod.TILE_SECRET_ROOM])
		if not is_area_free:
			continue
		
		main_node.addLandmark(cell, cave)
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			main_node.tileData.clear_resource(absCoord)
		return
		
	if !accept_higher_layer:
		var cells = main_node.tileData.get_biome_cells_by_index(biomeIndex)
		var cell
		var can_spawn
		for _i in 30 :
			cell = cells[rand.randi() % cells.size()]
			can_spawn = true
			for c in cave.tileCoords:
				var absCoord = cell + c
				can_spawn = can_spawn and not (main_node.tileData.get_resourcev(absCoord) in [14, 15,-1])
			
			if can_spawn :
				break
		if can_spawn :
			for c in cave.tileCoords:
				var absCoord = Vector2(cell) + c
				main_node.tileData.clear_resource(absCoord)
			main_node.addLandmark(cell, cave)
			return
	
	for _i in 50:
		var cells = main_node.tileData.get_biome_cells_by_index(biomeIndex-1)
		if cells.size() < cave.tileCoords.size():
			return
		
		var cell = cells[rand.randi() % cells.size()]
		if abs(cell.x) < minDistanceToCenter:
			continue
		
		if not main_node.tileData.is_area_free(cell, cave.tileCoords):
			continue
		
		main_node.addLandmark(cell, cave)
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			main_node.tileData.clear_resource(absCoord)
		return
		
		
func addCaveStartAndDirection(main_node, rand, cave, start, direction : Vector2):
	var map_data = main_node.find_child("MapData", true, false)
	
	cave.updateUsedTileCoords()
	var maxLayer = main_node.startingIronCountByLayer.size()
	var max_y = 0
	for i in range(1000):
		var pos = Vector2(randi_range(-15,15),max_y+5)
		if not( main_node.tileData.get_resourcev(pos) in [16, 17, 19]) and main_node.tileData.get_biomev(pos) != -1:
			max_y +=2
			
	var cell
	var can_spawn = false
	var spawn_tries = 0
	while !can_spawn:
		cell = start
		
		# Look for a cell to start building the cave
		var k = 0
		while cell == start :
			cell = find_in_direction(main_node, start + (-1)**k * k * Vector2(direction.y , direction.x),direction,floor(max_y*1.5))
			k += 1

		if main_node.tileData.get_resourcev(cell + Vector2.DOWN) != 19:
			spawn_tries += 1
			start = start + (-1)**spawn_tries * spawn_tries * Vector2(direction.y , direction.x)
			continue
			
		can_spawn = true
		for c in cave.tileCoords:
			var absCoord = cell + c
			can_spawn = can_spawn and not (main_node.tileData.get_resourcev(absCoord) in [14, 15,-1])
		
		spawn_tries += 1
		start = start + (-1)**spawn_tries * spawn_tries * Vector2(direction.y , direction.x)
	for c in cave.tileCoords:
		var absCoord = Vector2(cell) + c
		main_node.tileData.clear_resource(absCoord)
	main_node.addLandmark(cell, cave)
	return
	
func spawn_glass(main_node):
	var data_mod = main_node.get_node("/root/ModLoader/POModder-Dependency").data_mod
	
	var possible_spawn_ranges = [[Vector2.LEFT, 0.48, 0.62] , 
		[Vector2.LEFT, 0.68, 0.82] ,
		[Vector2.LEFT, 0.88, 1.0] ,
		[Vector2.RIGHT, 0.45, 0.62] ,
		[Vector2.RIGHT, 0.68, 0.82] ,
		[Vector2.RIGHT, 0.88, 1.0] ,]
	possible_spawn_ranges.shuffle() 
	var chosen_positions = possible_spawn_ranges.slice(0,4)
	var maxLayer = main_node.startingIronCountByLayer.size()
	var max_y = 0
	for i in range(1000):
		var pos = Vector2(randi_range(-15,15),max_y+5)
		if not( main_node.tileData.get_resourcev(pos) in [16, 17, 19]) and main_node.tileData.get_biomev(pos) != -1:
			max_y +=2
			
	for c in chosen_positions:
		var direction = c[0]
		var start = Vector2(0,floor(max_y*randf_range(c[1],c[2]) ))
		var cell = start
		var k = 0
		while cell == start :
			direction *= -1
			cell = find_in_direction(main_node, start + k*Vector2.UP,direction)
			k += 1
		main_node.tileData.set_resourcev(cell, data_mod.TILE_GLASS)

func find_in_direction(main_node, start,direction,max_distance_from_start = 30):
	var moved = direction
	var last_available_position = start
	# Setting depth and then checking all tiles to the left / right to see where the glass can be placed
	while abs(moved.x)+abs(moved.y) < max_distance_from_start:
		if main_node.tileData.get_resourcev(start + moved ) == 10:
			last_available_position = start + moved
		moved += direction
		
	return last_available_position


