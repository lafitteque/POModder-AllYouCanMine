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

const TILE_ID_TO_STRING_MAP := {
	TILE_EMPTY: "",
	TILE_BORDER: CONST.BORDER,
	TILE_IRON: CONST.IRON,
	TILE_WATER: CONST.WATER,
	TILE_SAND: CONST.SAND,
	TILE_GADGET: CONST.GADGET,
	TILE_RELIC: CONST.RELIC,
	TILE_NEST: CONST.NEST,
	TILE_RELIC_SWITCH: CONST.RELICSWITCH,
	TILE_SUPPLEMENT: CONST.POWERCORE,
	TILE_DETONATOR :"detonator" 
} 

const DROP_FROM_TILES_SCENES := {
	CONST.IRON: preload("res://content/drop/iron/IronDrop.tscn"),
	CONST.WATER: preload("res://content/drop/water/WaterDrop.tscn"),
	CONST.SAND: preload("res://content/drop/sand/SandDrop.tscn"),
	"cavebomb" : preload("res://content/caves/bombcave/CaveBomb.tscn"),
	"nothing" : null
}

const APRIL_FOOLS_PROBABILITIES = [50.0, 5.0 , 2.0 , 1.0, 20.0]

func _ready():
	print("Map ready")
	super._ready()
	
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

	tile.type = TILE_ID_TO_STRING_MAP.get(typeId, "dirt")
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
		#print("shroom added")
	add_child(drop)		

