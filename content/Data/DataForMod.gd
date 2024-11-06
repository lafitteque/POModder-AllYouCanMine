extends Node2D

class_name DataForMod

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
const TILE_DESTROYER = 12 # QLafitte Added
const TILE_MEGA_IRON = 13 # QLafitte Added
const TILE_BAD_RELIC = 14 #QLafitte Added
const TILE_GLASS = 15

const RESOURCES_ID = [TILE_IRON,TILE_WATER,TILE_SAND,TILE_MEGA_IRON]

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
	TILE_DETONATOR :"detonator" ,
	TILE_DESTROYER :"destroyer" ,
	TILE_MEGA_IRON :"mega_iron",
	TILE_BAD_RELIC : "bad_relic",
	TILE_GLASS : "glass"
} 

const DROP_FROM_TILES_SCENES := {
	CONST.IRON: preload("res://content/drop/iron/IronDrop.tscn"),
	CONST.WATER: preload("res://content/drop/water/WaterDrop.tscn"),
	CONST.SAND: preload("res://content/drop/sand/SandDrop.tscn"),
	"cavebomb" : preload("res://content/caves/bombcave/CaveBomb.tscn"),
	"nothing" : null
}

const APRIL_FOOLS_PROBABILITIES = [50.0, 5.0 , 2.0 , 1.0, 20.0]

var generation_data = {
	"detonator_rate":0,# from 00.00 to 99.99
	"mega_iron_rate":0,# from 00.00 to 99.99
	"drop_bearer_rate":0,# from 0.0000 to 0.9999
	"destroyer_rate":0 # from 00.00 to 99.99
}

func get_endings():
	#var endings = ["glass" , "heavy_rock", "secret"]
	#endings.remove_at(randi() % 3)
	var endings = ["glass" , "heavy_rock"]
	return endings
	
	
func update_generation_data(a : MapArchetype):
	### /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\   
	###  The changes here should also be done in the extension of TileDataGenerator.gd 
	###  So that the generation also takes into account thes changes.
	###  Unfortunately, TileDataGenerator.gd cannot access DataForMod ...
	### /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\   
	
	## 4th to 7th decimals are for detonator rate
	var detonator_rate = a.max_tile_count_deviation*10**(4-1) 
	detonator_rate -= int(detonator_rate)
	detonator_rate *= 100
	generation_data["detonator_rate"] = round(detonator_rate*100)/100
	
	## 8th to 11th decimals are for destroyer rate
	var destroyer_rate = detonator_rate*10**(4-1)
	destroyer_rate -= int(destroyer_rate)
	destroyer_rate *= 100
	generation_data["destroyer_rate"] = round(destroyer_rate*100)/100
	
	## 12th to 15th decimals are for mega iron rate
	var mega_iron_rate = destroyer_rate*10**(4-1)
	mega_iron_rate -= int(mega_iron_rate)
	mega_iron_rate *= 100
	generation_data["mega_iron_rate"] = round(mega_iron_rate*100)/100
	
	## 16th to 19th decimals are for mega drop_bearer spawn probability
	var drop_bearer_rate = mega_iron_rate*10**(4-1) 
	drop_bearer_rate -= int(mega_iron_rate)
	drop_bearer_rate *= 100
	generation_data["drop_bearer_rate"] = round(drop_bearer_rate*100)/10000
	
	
static func weighted_random(weights) -> int:
	var weights_sum := 0.0
	for weight in weights:
		weights_sum += weight
	
	var remaining_distance := randf() * weights_sum
	for i in weights.size():
		remaining_distance -= weights[i]
		if remaining_distance < 0:
			return i
	
	return 0

