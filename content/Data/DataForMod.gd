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
const TILE_DETONATOR := 11 
const TILE_DESTROYER = 12 
const TILE_MEGA_IRON = 13 
const TILE_BAD_RELIC = 14 
const TILE_GLASS = 15
const TILE_FAKE_BORDER = 16
const TILE_SECRET_ROOM = 17

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
	TILE_GLASS : "glass",
	TILE_FAKE_BORDER : "fake_border",
	TILE_SECRET_ROOM : "secret_room"
} 

const DROP_FROM_TILES_SCENES := {
	CONST.IRON: preload("res://content/drop/iron/IronDrop.tscn"),
	CONST.WATER: preload("res://content/drop/water/WaterDrop.tscn"),
	CONST.SAND: preload("res://content/drop/sand/SandDrop.tscn"),
	"cavebomb" : preload("res://content/caves/bombcave/CaveBomb.tscn"),
	"mega_iron": preload("res://mods-unpacked/POModder-AllYouCanMine/content/new_drops/MegaIronDrop.tscn"),
	"nothing" : null
}

const APRIL_FOOLS_PROBABILITIES = [40.0, 8.0 , 3.0 , 0.5, 1.0 ,20.0]

var generation_data = {
	"detonator_rate":0,# from 0.0 to 99.99
	"mega_iron_rate":0,# from 0.0 to 99.99
	"drop_bearer_rate":0,# from 0 to 1.0
	"destroyer_rate":0 # from 0.0 to 99.99
}

const rate_list = [0 , 0.1 , 0.5 , 1 , 5 , 10 , 25 , 50 , 75 ]
const probability_list = [0 , 0.001 , 0.005 , 0.01 , 0.05 , 0.10 , 0.25 , 0.50, 1 ]


func get_endings():
	#var endings = ["glass" , "heavy_rock", "secret"]
	#endings.remove_at(randi() % 3)
	var endings = ["heavy_rock" , "secret"]
	return endings
	
	
func update_generation_data(a : MapArchetype):
	### /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\   
	###  The changes here should also be done in the extension of TileDataGenerator.gd 
	###  So that the generation also takes into account thes changes.
	###  Unfortunately, TileDataGenerator.gd cannot access DataForMod ...
	### /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\   
	
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
	
	## 7th decimalsof max_tile_count_deviation for mega_iron_rate_index
	var drop_bearer_rate_index = a.max_tile_count_deviation*10**6
	drop_bearer_rate_index -= floor(drop_bearer_rate_index)
	drop_bearer_rate_index *= 10
	drop_bearer_rate_index = floor(drop_bearer_rate_index)
	
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
	
	
	var detonator_rate = rate_list[detonator_rate_index]
	var destroyer_rate = rate_list[destroyer_rate_index]
	var mega_iron_rate = rate_list[mega_iron_rate_index]
	var drop_bearer_rate = probability_list[drop_bearer_rate_index]
	
	generation_data["detonator_rate"] = detonator_rate
	generation_data["destroyer_rate"] = destroyer_rate
	generation_data["mega_iron_rate"] = mega_iron_rate
	generation_data["bad_relics"] = bad_relics
	generation_data["drop_bearer_rate"] = drop_bearer_rate
	generation_data["secret_rooms"] = secret_rooms
	
	print("data : raw data , " , a.max_tile_count_deviation)
	print("data : detonator_rate , " , detonator_rate)
	print("data : destroyer_rate , " , destroyer_rate)
	print("data : mega_iron_rate , " , mega_iron_rate)
	print("data : bad_relics , " , bad_relics)
	print("data : drop_bearer_rate , " , drop_bearer_rate)
	print("data : secret_rooms , " , secret_rooms)
	
	
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

