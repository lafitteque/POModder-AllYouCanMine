extends Map


var data_mod 
var entrance_pos = null


func _ready():
	data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod
	super()
	
	


func revealTile(coord:Vector2):
	var typeId:int = tileData.get_resource(coord.x, coord.y)
	var invalids := []
	
	if tileRevealedListeners.has(coord):
		for listener in tileRevealedListeners[coord]:
			if is_instance_valid(listener):
				listener.tileRevealed(coord)
			else:
				invalids.append(listener)
		for invalid in invalids:
			tileRevealedListeners.erase(invalid)
	
	
	if typeId == Data.TILE_EMPTY:
		return

	if tiles.has(coord):
		return
	
	var tile = preload("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/Tile.tscn").instantiate()
	var biomeId:int = tileData.get_biome(coord.x, coord.y)
	tile.layer = biomeId
	tile.biome = biomes[tile.layer]
	tile.position = coord * GameWorld.TILE_SIZE
	tile.coord = coord
		
	tile.hardness = tileData.get_hardness(coord.x, coord.y)
	tile.type = data_mod.TILE_ID_TO_STRING_MAP.get(typeId, "dirt")

	match tile.type:
		CONST.IRON:
			tile.richness = Data.ofOr("map.ironrichness", 2)
			revealTileVisually(coord)
		CONST.SAND:
			tile.richness = Data.ofOr("map.cobaltrichness", 2)
			revealTileVisually(coord)
		CONST.WATER:
			tile.richness = Data.ofOr("map.waterrichness", 2.5)
			revealTileVisually(coord)
		"detonator":# QLafitte Added
			revealTileVisually(coord) # QLafitte Added
		"destroyer":# QLafitte Added
			revealTileVisually(coord) # QLafitte Added
		"mega_iron":# QLafitte Added
			tile.richness = Data.ofOr("map.ironrichness", 2)
			revealTileVisually(coord) # QLafitte Added
		"bad_relic":
			revealTileVisually(coord) # QLafitte Added
		"glass":
			revealTileVisually(coord) # QLafitte Added
		"chaos":
			revealTileVisually(coord) # QLafitte Added
				
	tiles[coord] = tile 
	
	if tilesByType.has(tile.type):
		tilesByType[tile.type].append(tile)
	tile.connect("destroyed", Callable(self, "destroyTile").bind(tile))
	
	tiles_node.add_child(tile)

	# Allow border tiles to fade correctly at edges of the map
	visibleTileCoords[coord] = typeId
	
	if Level.mode and Level.mode.name == "Assignment" and Data.ofOr("assignment.id","") == "aprilfools":
		if tile.type in [CONST.IRON, CONST.SAND, CONST.WATER,
		 "detonator", "destroyer" , "mega_iron"]: #Qlafitte Added
			var vec_list = [\
				Vector2(5, 0) , Vector2(randi_range(2, 6), 11) , \
				Vector2(2, 3) , Vector2(randi_range(2, 3), 7) , \
				Vector2(4, 1), Vector2(4, 1), Vector2(4, 2),\
				Vector2(4, 2), Vector2(5, 0)]
			var rand_index = randi_range(0,8) #Qlafitte Added
			tile.initResourceSprite(vec_list[rand_index]) #Qlafitte Added
	
func addDrop(drop):
	if Level.mode and Level.mode.name == "Assignment" and Data.ofOr("assignment.id","") == "aprilfools" and\
	("type" in drop) and drop.type in data_mod.ALL_DROP_NAMES and !(drop.global_position.y <= 0 or drop.carriedBy.size()>0 ): #QLafitte Added
		var old_position = drop.global_position #QLafitte Added
		drop = null #QLafitte Added
		var all_keys = data_mod.DROP_FROM_TILES_SCENES.keys() #QLafitte Added
		var rand_type = all_keys[data_mod.weighted_random(data_mod.APRIL_FOOLS_PROBABILITIES)] #QLafitte Added
		if rand_type == "nothing":
			return
		drop = data_mod.DROP_FROM_TILES_SCENES.get(rand_type).instantiate()#QLafitte Added
		drop.global_position = old_position #QLafitte Added
		if ("type" in drop) and drop.type in data_mod.ALL_DROP_NAMES :#QLafitte Added
			drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))#QLafitte Added
	
	if Level.mode and Level.mode.name == "Assignment" and Data.ofOr("assignment.id","") == "big" and("type" in drop) and \
	drop.type in data_mod.ALL_DROP_NAMES and !(drop.global_position.y <= 0 or drop.carriedBy.size()>0 ):
		add_child(drop)	
		Style.init(drop)
		for i in 10:
			await get_tree().create_timer(0.1).timeout
			for child in drop.get_children():
				if "scale" in child:
					child.scale = Vector2(1.1 + 0.1*i, 1.1 + 0.1*i)
		return
		
	add_child(drop)		
	Style.init(drop)
	

func destroyTile(tile, withDropsAndSound := true):
	Data.changeByInt("map.tilesDestroyed", 1)
	Recorder.recordTileDestroyed(tile.coord)
	if withDropsAndSound:
		var sound
		match tile.type:
			CONST.IRON:
				sound = $TileDestroyedIron.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			CONST.WATER:
				sound = $TileDestroyedWater.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			CONST.SAND:
				sound = $TileDestroyedSand.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			CONST.GADGET:
				sound = $TileDestroyedChamber.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			CONST.POWERCORE:
				sound = $TileDestroyedChamber.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			CONST.RELIC:
				sound = $TileDestroyedChamber.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			"mega_iron":
				sound = $TileDestroyedIron.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			_:
				sound = $TileDestroyed.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		sound.setSimulatedPosition(tile.global_position)
		add_child(sound)
		sound.play()
		

		
		if tile.type == CONST.IRON or tile.type == CONST.SAND or tile.type == CONST.WATER:
			var goalRichness = tile.richness * Data.ofOr("resourcemodifiers.richness." + tile.type, 1.0)
			var drops = floor(goalRichness - 1 + (randi() % 3)) #tile richness is currently not seed based @TODO
			if tile.type == CONST.IRON:
				if isFirstDrop:
					#ensure first drop is constant
					isFirstDrop = false
					drops = 2
			var newDelta = dropDeltas.get(tile.type, 0) + drops - goalRichness
			if newDelta >= 3:
				drops -= 1
				newDelta -= 1
			elif newDelta <= -3:
				drops += 1
				newDelta += 1
			dropDeltas[tile.type] = newDelta
			
			if tile.type == CONST.SAND and drops < 3 and Level.loadout.modeId == CONST.MODE_RELICHUNT and Level.loadout.difficulty <= 0:
				# rubberbanding: chance for extra sand if low on health
				var sandWithFloating = Data.of("inventory.sand") + Data.of("inventory.floatingsand")
				if Data.of("dome.health") < 350 - 60 * sandWithFloating:
					drops += 1
			if drops < 3 and Level.difficulty() * 0.1 < -randf():
				drops += 1
			
			for _i in range(0, drops):
				var drop = Data.DROP_SCENES.get(tile.type).instantiate()
				drop.position = tile.global_position + 0.6 * Vector2(GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE, GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE)
				drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))
				call_deferred("addDrop", drop)
				GameWorld.incrementRunStat("resources_mined")
	
	if tile.type == CONST.IRON:
		currentIronCountByLayer[tile.layer] = currentIronCountByLayer[tile.layer] - 1
	
	if tile.hardness == 5:
		# border tile destroyed, make sure there are physical tiles around now
		buildBorderAroundTile(tile.coord, tileData.get_biomev(tile.coord))
	
	tiles.erase(tile.coord)
	for t in tilesByType.values():
		t.erase(tile)
	tilesByType.get(tile.type, {}).erase(tile)
	tile.queue_free()
	
	onTileRemoved(tile.coord)
#	for d in CONST.DIRECTIONS:
#		tileCoordsToReveal.append(tile.coord +" d)
	tileCoordsToReveal.append(tile.coord)
	floodRevealTiles()

	if withDropsAndSound and tile.type == "mega_iron":
		var sound = $TileDestroyedIron.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		sound.setSimulatedPosition(tile.global_position)
		add_child(sound)
		sound.play()
	if tile.type == "mega_iron":
		var drop = data_mod.DROP_FROM_TILES_SCENES.get(tile.type).instantiate()
		drop.position = tile.global_position + 0.6 * Vector2(GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE, GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE)
		drop.apply_central_impulse(Vector2(0, 10).rotated(randf() * TAU))
		call_deferred("addDrop", drop)
		GameWorld.incrementRunStat("resources_mined")

func getSceneForTileType(tileType:int) -> PackedScene:
	if tileType == data_mod.TILE_BAD_RELIC:
		return preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/BadRelicChamber/BadRelicChamber.tscn")
	elif tileType == data_mod.TILE_FAKE_BORDER:
		return preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/hint_secret.tscn")
	return super(tileType)
#
	
func init(fromDeserialize := false, defaultState := true):
	super(fromDeserialize,defaultState)
	if not fromDeserialize:
		# tile data gets modified with creating chambers, so that should not be done on reload
		var clusterCenters = getResourceClusterTopLeft(data_mod.TILE_BAD_RELIC)
		for centerCoord in clusterCenters:
			addChamber(centerCoord, getSceneForTileType(data_mod.TILE_BAD_RELIC))
	
	

func generateCaves(minDistanceToCenter := 10):
	var rand = RandomNumberGenerator.new()
	rand.seed = Level.levelSeed
	var caveScenesById = Data.CAVE_SCENES.duplicate()

	var cavePackeScenes := []
	# SPECIAL CAVES
	if Level.loadout.modeId == CONST.MODE_RELICHUNT:
		if GameWorld.isPetUnlockable():
			cavePackeScenes.append(preload("res://content/map/chamber/nest/NestCave.tscn"))

	if GameWorld.useCustomCaveOrder and GameWorld.customCaveOrder and GameWorld.customCaveOrder.size() > 0:
		for caveId in GameWorld.customCaveOrder:
			if caveScenesById.has(caveId):
				cavePackeScenes.append(caveScenesById[caveId])
	else:
		for caveId in Data.CAVE_SCENES:
			if caveScenesById.has(caveId):
				cavePackeScenes.append(caveScenesById[caveId])
		Utils.shuffle(cavePackeScenes,rand)

	if Level.loadout.modeId == CONST.MODE_RELICHUNT:
		for keeper in Level.loadout.keepers:
			if keeper.keeperId == "keeper1":
				if GameWorld.isHalloween and Level.loadout.modeId == CONST.MODE_RELICHUNT:
					cavePackeScenes.insert(0, preload("res://content/caves/halloweencave/HalloweenSkeletonCave.tscn"))
					break
		if GameWorld.isLunarNewYear and not GameWorld.unlockedPets.has("pet8"):
			cavePackeScenes.insert(0, preload("res://content/caves/dragoncave/LunarNewYearDragonCave.tscn"))
		if shouldGenerateDrillbertCave():
			cavePackeScenes.insert(0, preload("res://content/caves/drillicave/DrillbertCave.tscn"))
	
	# Added vvvvvvvvv
	
	var coresaver_endings = data_mod.get_endings()
	
	var secret_room_tiles = tileData.get_resource_cells_by_id(data_mod.TILE_SECRET_ROOM)
	var coresaver_is_reloading = secret_room_tiles.size() == 0
	
	if !coresaver_is_reloading and  Level.loadout.modeId == "coresaver" and coresaver_endings.has("heavy_rock") :
		var heavy_rock_cave =  preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/heavy_rock_cave/HeavyRockCave.tscn").instantiate()
		var maxLayer = startingIronCountByLayer.size()
		addForcedCave(rand, heavy_rock_cave, maxLayer-1, 2)
		

	if !coresaver_is_reloading and Level.loadout.modeId == "coresaver" and coresaver_endings.has("secret") :
		for i in range(secret_room_tiles.size()-1,-1,-1):
			if tileData.get_biomev(secret_room_tiles[i]) >1:
				secret_room_tiles.pop_at(i)
			
		
		# Add cave
		var top_left = secret_room_tiles[0]
		for cell in secret_room_tiles:
			if cell.x <= top_left.x and cell.y <= top_left.y :
				top_left = cell
		var root_cave = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/RootCave/RootCave.tscn").instantiate()
		for coord in tileData.get_resource_cells_by_id(data_mod.TILE_SECRET_ROOM):
			tileData.set_resourcev(coord, Data.TILE_DIRT_START)
		root_cave.updateUsedTileCoords()
		addLandmark(top_left, root_cave)
		for c in root_cave.tileCoords:
			var absCoord = Vector2(top_left) + c
			tileData.clear_resource(absCoord)
		root_cave.visible = true
		
	## Added ^^^^^^^^
	
	var availableCaves:Array
	var caveCount := {}
	var maxLayer = startingIronCountByLayer.size()
	for layerIndex in maxLayer:
		if availableCaves.is_empty():
			availableCaves = cavePackeScenes.duplicate()
		for cavePackedScene in availableCaves:
			var cave = cavePackedScene.instantiate() # yeah this is shit, but probably not noticable
			var biomeFits = cave.biome == "" or biomes[layerIndex] == cave.biome 
			var minLayerFits = cave.minLayer <= layerIndex
			var relativeDepth = layerIndex / float(maxLayer)
			var minDepthFits = round(relativeDepth * cave.minRelativeDepth) <= layerIndex
			var maxDepthFits = layerIndex <= round(maxLayer * cave.maxRelativeDepth)
			var withinAllowedCount = caveCount.get(cavePackedScene, 0) < cave.maxCount
			if biomeFits and minLayerFits and minDepthFits and maxDepthFits and withinAllowedCount:
				addCave(rand, cave, layerIndex, minDistanceToCenter)
				availableCaves.erase(cavePackedScene)
				caveCount[cavePackedScene] = caveCount.get(cavePackedScene, 0) + 1
				break
			else:
				cave.queue_free()

	### Added vvvvvvvv	
	if !coresaver_is_reloading and Level.loadout.modeId == "coresaver" and coresaver_endings.has("glass") :
		spawn_glass()
		var core_eater_cave = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEaterCave.tscn").instantiate()
		addCaveStartAndDirection(rand, core_eater_cave, Vector2.ZERO, Vector2.DOWN)
	
	# Add hints for secrets
	for coord in tileData.get_hardness_cells_by_grade(7):
		for i in range(-2,3):
			for j in range(-1,2):	
				var new_coord = coord+Vector2i(i,j)
				if tileData.get_resourcev(new_coord) == Data.TILE_DIRT_START :
					addChamber(new_coord, preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/hint_secret.tscn"))

				
func addForcedCave(rand, cave, biomeIndex, minDistanceToCenter, accept_higher_layer = true):
	cave.updateUsedTileCoords()

	# try for a few times to find a suitable spot for the cave
	for _i in 50:
		var cells = tileData.get_biome_cells_by_index(biomeIndex)
		if cells.size() < cave.tileCoords.size():
			accept_higher_layer = true
			break
			
		var cell = cells[rand.randi() % cells.size()]
		if abs(cell.x) < minDistanceToCenter:
			continue
		
		var is_area_free = true
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			is_area_free = is_area_free and not (tileData.get_resourcev(absCoord) in [data_mod.TILE_BAD_RELIC ,  Data.TILE_EMPTY, data_mod.TILE_SECRET_ROOM])
		if not is_area_free:
			continue
		
		addLandmark(cell, cave)
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			tileData.clear_resource(absCoord)
		return
		
	if !accept_higher_layer:
		var cells = tileData.get_biome_cells_by_index(biomeIndex)
		var cell
		var can_spawn
		for _i in 30 :
			cell = cells[rand.randi() % cells.size()]
			can_spawn = true
			for c in cave.tileCoords:
				var absCoord = cell + c
				can_spawn = can_spawn and not (tileData.get_resourcev(absCoord) in [14, 15,-1])
			
			if can_spawn :
				break
		if can_spawn :
			for c in cave.tileCoords:
				var absCoord = Vector2(cell) + c
				tileData.clear_resource(absCoord)
			addLandmark(cell, cave)
			return
	
	for _i in 50:
		var cells = tileData.get_biome_cells_by_index(biomeIndex-1)
		if cells.size() < cave.tileCoords.size():
			return
		
		var cell = cells[rand.randi() % cells.size()]
		if abs(cell.x) < minDistanceToCenter:
			continue
		
		if not tileData.is_area_free(cell, cave.tileCoords):
			continue
		
		addLandmark(cell, cave)
		for c in cave.tileCoords:
			var absCoord = Vector2(cell) + c
			tileData.clear_resource(absCoord)
		return
		
		
func addCaveStartAndDirection(rand, cave, start, direction : Vector2):
	cave.updateUsedTileCoords()
	var maxLayer = startingIronCountByLayer.size()
	var max_y = 0
	for i in range(1000):
		var pos = Vector2(randi_range(-15,15),max_y+5)
		if not( $MapData.get_resourcev(pos) in [16, 17, 19]) and $MapData.get_biomev(pos) != -1:
			max_y +=2
			
	var cell
	var can_spawn = false
	var spawn_tries = 0
	while !can_spawn:
		cell = start
		
		# Look for a cell to start building the cave
		var k = 0
		while cell == start :
			cell = find_in_direction(start + (-1)**k * k * Vector2(direction.y , direction.x),direction,floor(max_y*1.5))
			k += 1

		if tileData.get_resourcev(cell + Vector2.DOWN) != 19:
			spawn_tries += 1
			start = start + (-1)**spawn_tries * spawn_tries * Vector2(direction.y , direction.x)
			continue
			
		can_spawn = true
		for c in cave.tileCoords:
			var absCoord = cell + c
			can_spawn = can_spawn and not (tileData.get_resourcev(absCoord) in [14, 15,-1])
		
		spawn_tries += 1
		start = start + (-1)**spawn_tries * spawn_tries * Vector2(direction.y , direction.x)
	for c in cave.tileCoords:
		var absCoord = Vector2(cell) + c
		tileData.clear_resource(absCoord)
	addLandmark(cell, cave)
	return
	
func spawn_glass():
	var possible_spawn_ranges = [[Vector2.LEFT, 0.48, 0.62] , 
		[Vector2.LEFT, 0.68, 0.82] ,
		[Vector2.LEFT, 0.88, 1.0] ,
		[Vector2.RIGHT, 0.45, 0.62] ,
		[Vector2.RIGHT, 0.68, 0.82] ,
		[Vector2.RIGHT, 0.88, 1.0] ,]
	possible_spawn_ranges.shuffle() 
	var chosen_positions = possible_spawn_ranges.slice(0,4)
	var maxLayer = startingIronCountByLayer.size()
	var max_y = 0
	for i in range(1000):
		var pos = Vector2(randi_range(-15,15),max_y+5)
		if not( $MapData.get_resourcev(pos) in [16, 17, 19]) and $MapData.get_biomev(pos) != -1:
			max_y +=2
			
	for c in chosen_positions:
		var direction = c[0]
		var start = Vector2(0,floor(max_y*randf_range(c[1],c[2]) ))
		var cell = start
		var k = 0
		while cell == start :
			direction *= -1
			cell = find_in_direction(start + k*Vector2.UP,direction)
			k += 1
		tileData.set_resourcev(cell, data_mod.TILE_GLASS)

func find_in_direction(start,direction,max_distance_from_start = 30):
	var moved = direction
	var last_available_position = start
	# Setting depth and then checking all tiles to the left / right to see where the glass can be placed
	while abs(moved.x)+abs(moved.y) < max_distance_from_start:
		if tileData.get_resourcev(start + moved ) == 10:
			last_available_position = start + moved
		moved += direction
		
	return last_available_position

func find_wall_in_direction(start,direction,max_distance_from_start = 100):
	var can_spawn = false
	var last_available_position
	while not can_spawn:
		var moved = direction
		var last_type = 19
		last_available_position = start
		# Setting depth and then checking all tiles to the left / right to see where the glass can be placed
		while abs(moved.x)+abs(moved.y) < max_distance_from_start:
			if tileData.get_resourcev(start + moved ) == 19 and not( last_type in [16, 17, 19]):
				last_available_position = start + moved
			last_type = tileData.get_resourcev(start + moved )
			moved += direction
		
		can_spawn = true
		for height in range(-3,4):
			for depth in range(1,5):
				can_spawn = can_spawn and tileData.get_resourcev(last_available_position) in [-1,19]
		start += Vector2.UP
		
	return last_available_position
