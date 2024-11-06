extends Node

const MYMODNAME_LOG = "POModder-AllYouCanMine"
const MYMODNAME_MOD_DIR = "POModder-AllYouCanMine/"

var dir = ""
var ext_dir = ""
var cooldown : float = 1.0
var in_game = false
var map_node = null

var trans_dir = "res://mods-unpacked/POModder-AllYouCanMine/translations/"

var achievements = {}
var data_achievements 
var data_mod 
var custom_achievements 
var saver

func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	ext_dir = dir + "extensions/"
	
	# Add extensions
	for loc in ["en" , "es" , "fr"]:
		ModLoaderMod.add_translation(trans_dir + "translations." + loc + ".translation")
	ModLoaderMod.install_script_extension(ext_dir + "AssignmentDisplay.gd")
	ModLoaderMod.install_script_extension(ext_dir + "TileDataGenerator.gd")

	
func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	add_to_group("mod_init")

		
func modInit():
	var pathToModYamlAssignments : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/assignments.yaml"
	var pathToModYamlUpgrades : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/upgrades.yaml"
	#var pathToModYamlAssignments : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/assignments.yaml"
	Data.parseAssignmentYaml(pathToModYamlAssignments)
	#Data.parseUpgradesYaml(pathToModYamlUpgrades)

	ModLoaderLog.info("Trying to parse YAML: %s" % pathToModYamlAssignments, MYMODNAME_LOG)
	ModLoaderLog.info("Trying to parse YAML: %s" % pathToModYamlUpgrades, MYMODNAME_LOG)
	
	data_achievements = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/DataForAchievements.tscn").instantiate()
	data_mod = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/DataForMod.tscn").instantiate()
	add_child(data_achievements)
	add_child(data_mod)
	
	manage_overwrites()
	
	saver = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Save/Saver.tscn").instantiate()
	add_child(saver)
	custom_achievements = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/CustomAchievements.tscn").instantiate()
	add_child(custom_achievements)
	var stage_manager_extender = preload("res://mods-unpacked/POModder-AllYouCanMine/content/StageManagerExtender/StageManagerExtender.tscn").instantiate()
	StageManager.add_child(stage_manager_extender)

	StageManager.connect("level_ready", _on_level_ready)

	Data.registerGameMode("coresaver")
	GameWorld.unlockElement("coresaver")

	var coreSaverPrepare = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_saver_prepare.tscn").instantiate()
	add_child(coreSaverPrepare)
	
# Called when the node enters the scene tree for the first time.
func manage_overwrites():
	var new_archetype_detonators = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-detonators.tres")
	new_archetype_detonators.take_over_path("res://content/map/generation/archetypes/assignment-detonators.tres")

	var new_archetype_aprilfools = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-aprilfools.tres")
	new_archetype_aprilfools.take_over_path("res://content/map/generation/archetypes/assignment-aprilfools.tres")
	
	var new_archetype_thieves = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-thieves.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/assignment-thieves.tres")
	
	var new_archetype_huge_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-huge.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/coresaver-huge.tres")
	
	var new_archetype_large_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-large.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/coresaver-large.tres")
	
	var new_archetype_medium_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-medium.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/coresaver-medium.tres")
	
	var new_archetype_small_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-small.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/coresaver-small.tres")
	
	var new_stage = load("res://mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutModStage.tscn")
	new_stage.take_over_path("res://stages/loadout/multiplayerloadoutmodstage.tscn")

	var custom_achievements = load("res://mods-unpacked/POModder-AllYouCanMine/content/Data/CustomAchievements.tscn")
	custom_achievements.take_over_path("res://systems/achievements/CustomAchievements.tscn")
	
		
	var tile = preload("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/Tile.tscn")
	tile.take_over_path("res://content/map/tile/Tile.tscn")
	
	var map = preload("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/Map.tscn")
	map.take_over_path("res://content/map/Map.tscn")
	
	var level_stage = preload("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/LevelStage.tscn")
	level_stage.take_over_path("res://stages/level/LevelStage.tscn")
	
	var coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/Coresaver.tscn")
	coresaver.take_over_path("res://content/gamemode/coresaver/Coresaver.tscn")
	
	
	
func _on_level_ready():
	if Data.ofOr("assignment.id","") == "mineall":
		var mine_all_data = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/mine_all_data.tscn").instantiate()
		add_child(mine_all_data)
		
	## Actions that need an action from StageManagerExtender
	await get_tree().create_timer(0.5).timeout
	if data_mod.generation_data["drop_bearer_rate"] > 0:
		var drop_bearer_manager = preload("res://mods-unpacked/POModder-AllYouCanMine/content/drop_bearer/drop_bearer_manager.tscn").instantiate()
		StageManager.currentStage.MAP.add_child(drop_bearer_manager)
