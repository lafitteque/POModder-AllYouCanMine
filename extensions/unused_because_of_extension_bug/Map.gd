extends #"res://content/map/Map.gd"


#const TILE_DETONATOR = 11# QLafitte Added

func revealTile(coord:Vector2):
	var invalids := []
	if tileRevealedListeners.has(coord):
		for listener in tileRevealedListeners[coord]:
			if is_instance_valid(listener):
				listener.tileRevealed(coord)
			else:
				invalids.append(listener)
		for invalid in invalids:
			tileRevealedListeners.erase(invalid)
	
	var typeId:int = tileData.get_resource(coord.x, coord.y)
	if typeId == Data.TILE_EMPTY:
		return
	
	if tiles.has(coord):
		return
	
	var tile = TILE_SCENE.instantiate()
	var biomeId:int = tileData.get_biome(coord.x, coord.y)
	tile.layer = biomeId
	tile.biome = biomes[tile.layer]
	tile.position = coord * GameWorld.TILE_SIZE
	tile.coord = coord
		
	tile.hardness = tileData.get_hardness(coord.x, coord.y)

	tile.type = DataForMod.TILE_ID_TO_STRING_MAP.get(typeId, "dirt")
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
		TILE_DETONATOR:# QLafitte Added
			revealTileVisually(coord) # QLafitte Added

	
	tiles[coord] = tile 
	
	if tilesByType.has(tile.type):
		tilesByType[tile.type].append(tile)
	tile.connect("destroyed", Callable(self, "destroyTile").bind(tile))
	
	tiles_node.add_child(tile)

	# Allow border tiles to fade correctly at edges of the map
	visibleTileCoords[coord] = typeId
	
	if Data.of("assignment.id") is String and Data.of("assignment.id") == "aprilfools":
		if tile.type in [CONST.IRON, CONST.SAND, CONST.WATER, TILE_DETONATOR]: #Qlafitte Added
			var vec_list = [\
				Vector2(5, 0) , Vector2(randi_range(2, 6), 11) , \
				Vector2(2, 3) , Vector2(randi_range(2, 3), 7) , \
				Vector2(4, 1), Vector2(4, 1), Vector2(4, 2),\
				Vector2(4, 2), Vector2(5, 0)]
			var rand_index = randi_range(0,8) #Qlafitte Added
			tile.initResourceSprite(vec_list[rand_index]) #Qlafitte Added
			
			
func addDrop(drop):
	if Data.of("assignment.id") is String and Data.of("assignment.id") == "aprilfools" and\
	("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND]: #QLafitte Added
		var old_position = drop.global_position #QLafitte Added
		drop = null #QLafitte Added
		var all_keys = DataForMod.DROP_FROM_TILES_SCENES.keys() #QLafitte Added
		var rand_type = all_keys[DataForMod.weighted_random(DataForMod.APRIL_FOOLS_PROBABILITIES)] #QLafitte Added
		if rand_type == DataForMod.DROP_FROM_TILES_SCENES["nothing"]:
			return
		drop = DataForMod.DROP_FROM_TILES_SCENES.get(rand_type).instantiate()#QLafitte Added
		drop.global_position = old_position #QLafitte Added
		if ("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND] :#QLafitte Added
			drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))#QLafitte Added
	#elif Data.of("assignment.id") is String and Data.of("assignment.id") == "newmission4" and\
	#("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND]:#QLafitte Added
		#var dropbearer = preload("res://mods-unpacked/POModder-MoreGuildMissions/content/drop_bearer/DropBearer.tscn").instantiate()#QLafitte Added
		#dropbearer.global_position = drop.global_position#QLafitte Added
		#add_child(dropbearer)
		#print("shroom added")
	add_child(drop)		
