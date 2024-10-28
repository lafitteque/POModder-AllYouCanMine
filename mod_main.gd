extends Node

const MYMODNAME_LOG = "POModder-AllYouCanMine"
const MYMODNAME_MOD_DIR = "POModder-AllYouCanMine/"


var cooldown : float = 1.0
var in_game = false
var map_node = null

var dir = "res://mods-unpacked/POModder-AllYouCanMine/"
var ext_dir = "res://mods-unpacked/POModder-AllYouCanMine/extentions/"
var trans_dir = "res://mods-unpacked/POModder-AllYouCanMine/translations/"

var achievements = {}

var data_achievements 
var data_mod 
var custom_achievements 

func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	for loc in ["en" , "es" , "fr"]:
		ModLoaderMod.add_translation(trans_dir + "translations." + loc + ".translation")

func _ready():
	data_achievements = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/DataForAchievements.tscn").instantiate()
	data_mod = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/DataForMod.tscn").instantiate()
	add_child(data_achievements)
	add_child(data_mod)
	
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	add_to_group("mod_init")
	
		
func modInit():
	ModLoaderMod.install_script_extension(ext_dir + "Achievement_MINE_ALL.gd")
	ModLoaderMod.install_script_extension(ext_dir + "AssignmentDisplay.gd")
	ModLoaderMod.install_script_extension(ext_dir + "TileDataGenerator.gd")
	var pathToModYaml : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/assignments.yaml"
	Data.parseAssignmentYaml(pathToModYaml)
	ModLoaderLog.info("Trying to parse YAML: %s" % pathToModYaml, MYMODNAME_LOG)
	
	manage_overwrites()
	
	custom_achievements = load("res://systems/achievements/CustomAchievements.tscn").instantiate()
	add_child(custom_achievements)
	
	StageManager.connect("level_ready", _on_level_ready)
	
	var stage_manager_extender = preload("res://mods-unpacked/POModder-AllYouCanMine/content/StageManagerExtender/StageManagerExtender.tscn").instantiate()
	get_tree().get_root().get_child(10).add_child(stage_manager_extender)

# Called when the node enters the scene tree for the first time.
func manage_overwrites():
	var new_archetype = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-detonators.tres")
	new_archetype.take_over_path("res://content/map/generation/archetypes/assignment-detonators.tres")

	var new_archetype2 = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-aprilfools.tres")
	new_archetype2.take_over_path("res://content/map/generation/archetypes/assignment-aprilfools.tres")
	
	var new_stage = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutModStage.tscn")
	new_stage.take_over_path("res://stages/loadout/multiplayerloadoutmodstage.tscn")

	var custom_achievements_resource = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/achievements_save.tres")
	custom_achievements_resource.take_over_path("res://systems/achievements/achievements_save.tres")
	
	var custom_achievements = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/CustomAchievements.tscn")
	custom_achievements.take_over_path("res://systems/achievements/CustomAchievements.tscn")
	
func _on_level_ready():
	if Data.of("assignment.id") is String and Data.of("assignment.id") == "thieves":
		var drop_bearer_manager = preload("res://mods-unpacked/POModder-AllYouCanMine/content/drop_bearer/drop_bearer_manager.tscn").instantiate()
		get_tree().get_root().get_child(13).map.add_child(drop_bearer_manager)
