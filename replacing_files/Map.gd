extends Map



const TILE_EMPTY := -1
const TILE_BORDER := 19
const TILE_IRON := 0
const TILE_WATER := 1
const TILE_SAND := 2
const TILE_GADGET := 3
const TILE_RELIC := 4
const TILE_NEST := 5
const TILE_RELIC_SWITCH := 6
const TILE_SUPPLEMENT := 7
const TILE_CAVE := 9
const TILE_DIRT_START := 10
const TILE_DETONATOR := 11 # QLafitte Added
const TILE_DESTROYER := 12 # QLafitte Added
const TILE_MEGA_IRON := 13 # QLafitte Added

var data_mod 

const DROP_FROM_TILES_SCENES := {
	CONST.IRON: preload("res://content/drop/iron/IronDrop.tscn"),
	CONST.WATER: preload("res://content/drop/water/WaterDrop.tscn"),
	CONST.SAND: preload("res://content/drop/sand/SandDrop.tscn"),
	"cavebomb" : preload("res://content/caves/bombcave/CaveBomb.tscn"),
	"mega_iron": preload("res://mods-unpacked/POModder-AllYouCanMine/content/new_drops/MegaIronDrop.tscn"),
	"nothing" : null
}

const APRIL_FOOLS_PROBABILITIES = [50.0, 5.0 , 2.0 , 1.0, 20.0]

func _ready():
	data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod
	super()
	
func weighted_random(weights) -> int:
	var weights_sum := 0.0
	for weight in weights:
		weights_sum += weight
	
	var remaining_distance := randf() * weights_sum
	for i in weights.size():
		remaining_distance -= weights[i]
		if remaining_distance < 0:
			return i
	
	return 0


func revealTile(coord:Vector2):
	print("reveal tile OK")
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
			print("Map : detonator")
			revealTileVisually(coord) # QLafitte Added
		"destroyer":# QLafitte Added
			print("Map : destroyer")
			revealTileVisually(coord) # QLafitte Added
		"mega_iron":# QLafitte Added
			print("Map : mega iron")
			tile.richness = Data.ofOr("map.ironrichness", 2)
			revealTileVisually(coord) # QLafitte Added
			
	
	
	
	tiles[coord] = tile 
	
	if tilesByType.has(tile.type):
		tilesByType[tile.type].append(tile)
	tile.connect("destroyed", Callable(self, "destroyTile").bind(tile))
	
	tiles_node.add_child(tile)

	# Allow border tiles to fade correctly at edges of the map
	visibleTileCoords[coord] = typeId
	
	if Data.ofOr("assignment.id","") == "aprilfools":
		if tile.type in [CONST.IRON, CONST.SAND, CONST.WATER, TILE_DETONATOR]: #Qlafitte Added
			var vec_list = [\
				Vector2(5, 0) , Vector2(randi_range(2, 6), 11) , \
				Vector2(2, 3) , Vector2(randi_range(2, 3), 7) , \
				Vector2(4, 1), Vector2(4, 1), Vector2(4, 2),\
				Vector2(4, 2), Vector2(5, 0)]
			var rand_index = randi_range(0,8) #Qlafitte Added
			tile.initResourceSprite(vec_list[rand_index]) #Qlafitte Added
	
func addDrop(drop):
	if Data.ofOr("assignment.id","") == "aprilfools" and\
	("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND]: #QLafitte Added
		var old_position = drop.global_position #QLafitte Added
		drop = null #QLafitte Added
		var all_keys = DROP_FROM_TILES_SCENES.keys() #QLafitte Added
		var rand_type = all_keys[weighted_random(APRIL_FOOLS_PROBABILITIES)] #QLafitte Added
		if rand_type == "nothing":
			return
		drop = DROP_FROM_TILES_SCENES.get(rand_type).instantiate()#QLafitte Added
		drop.global_position = old_position #QLafitte Added
		if ("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND] :#QLafitte Added
			drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))#QLafitte Added
	#elif Data.of("assignment.id") is String and Data.of("assignment.id") == "newmission4" and\
	#("type" in drop) and drop.type in [CONST.WATER, CONST.IRON,CONST.SAND]:#QLafitte Added
		#var dropbearer = preload("res://mods-unpacked/POModder-MoreGuildMissions/content/drop_bearer/DropBearer.tscn").instantiate()#QLafitte Added
		#dropbearer.global_position = drop.global_position#QLafitte Added
		#add_child(dropbearer)
	add_child(drop)		


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
#		tileCoordsToReveal.append(tile.coord + d)
	tileCoordsToReveal.append(tile.coord)
	floodRevealTiles()

	if withDropsAndSound and tile.type == "mega_iron":
		var sound = $TileDestroyedIron.duplicate(Node.DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		sound.setSimulatedPosition(tile.global_position)
		add_child(sound)
		sound.play()
	if tile.type == "mega_iron":
		var drop = DROP_FROM_TILES_SCENES.get(tile.type).instantiate()
		drop.position = tile.global_position + 0.6 * Vector2(GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE, GameWorld.HALF_TILE_SIZE - randf()*GameWorld.TILE_SIZE)
		drop.apply_central_impulse(Vector2(0, 10).rotated(randf() * TAU))
		call_deferred("addDrop", drop)
		GameWorld.incrementRunStat("resources_mined")
