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


var blast_mining_assignment
var blast_suit_assignment

var pathToModYamlUpgrades : String

var heatProperties = []

func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	ext_dir = dir + "extensions/"
	
	# Add extensions
	for loc in ["en" , "es" , "fr"]:
		ModLoaderMod.add_translation(trans_dir + "translations." + loc + ".translation")
	ModLoaderMod.install_script_extension(ext_dir + "AssignmentDisplay.gd")
	ModLoaderMod.install_script_extension(ext_dir + "TileDataGenerator.gd")
	ModLoaderMod.install_script_extension(ext_dir + "laser_superhot.gd")
	
	
	
func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	add_to_group("mod_init")
		
func modInit():
	data_mod = get_node("/root/ModLoader/POModder-Dependency").data_mod
	data_achievements = get_node("/root/ModLoader/POModder-Dependency").data_achievements
	
	#GameWorld.devMode = true
	var pathToModYamlAssignments : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/assignments.yaml"
	var pathToModYamlProperties : String = "res://mods-unpacked/POModder-AllYouCanMine/yaml/properties.yaml"
	pathToModYamlUpgrades = "res://mods-unpacked/POModder-AllYouCanMine/yaml/upgrades.yaml"
	
	Data.parsePropertiesYaml(pathToModYamlProperties)
	Data.parseAssignmentYaml(pathToModYamlAssignments)
	Data.parseUpgradesYaml(pathToModYamlUpgrades)
	
	
	blast_mining_assignment = Data.upgrades["blastminingassignment"]
	blast_suit_assignment = Data.upgrades["suitblasterassignment"]
	
	Data.upgrades.erase("blastminingassignment")
	Data.upgrades.erase("suitblasterassignment")
	
	var stage_manager_extender = preload("res://mods-unpacked/POModder-AllYouCanMine/content/StageManagerExtender/StageManagerExtender.tscn").instantiate()
	StageManager.add_child(stage_manager_extender)

	StageManager.connect("level_ready", _on_level_ready)

	var coresaver_loadout = load("res://mods-unpacked/POModder-AllYouCanMine/content/loadout_gamemode/coresaver_loadout.tscn").instantiate()
	add_child(coresaver_loadout)
	
	Data.registerGameMode("coresaver")
	GameWorld.unlockElement("coresaver")

	var coreSaverPrepare = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_saver_prepare.tscn").instantiate()
	add_child(coreSaverPrepare)
	
	
	data_mod.add_drop_scene("mega_iron", preload("res://mods-unpacked/POModder-AllYouCanMine/content/new_drops/MegaIronDrop.tscn"),0.5)

	var map_hook = preload("res://mods-unpacked/POModder-AllYouCanMine/content/MapAndTile/MapHook.tscn").instantiate()
	add_child(map_hook)
	var tile_hook = preload("res://mods-unpacked/POModder-AllYouCanMine/content/MapAndTile/TileHook.tscn").instantiate()
	add_child(tile_hook)
	
	registerAchievenemnts()
	
	Data.registerKeeper("excavator")
	GameWorld.unlockElement("excavator")
	
	var modifiers = ["pyromaniac", "autonomous",
	"superhot", "speed", 
	"aprilfools", "smalldrops",
	"bigdrops"]
	for modifier in modifiers :
		GameWorld.unlockedRunModifiers.append(modifier)
		

	
func _on_level_ready():
	### Erase the upgrades that are specific to certain worldmodifiers
	
	print("Debug Worldmodifiers :", Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS))
	
	if Data.worldModifiers.has("worldmodifierpyromaniac") and \
	! ("worldmodifierpyromaniac" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []) ):
		Data.gadgets.erase("blastminingassignment")
		Data.gadgets.erase("suitblasterassignment")
	elif !Data.worldModifiers.has("worldmodifierpyromaniac") and \
	"worldmodifierpyromaniac" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		Data.parseUpgradesYaml("res://mods-unpacked/POModder-AllYouCanMine/yaml/upgrades.yaml")

	Data.changeByInt("inventory.iron", 500)

	var mining_data = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/mining_data.tscn").instantiate()
	add_child(mining_data)
	
	
	await get_tree().create_timer(0.5).timeout
	var bb = Level.loadout
	if "worldmodifierthieves" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		var drop_bearer_manager = preload("res://mods-unpacked/POModder-AllYouCanMine/content/drop_bearer/drop_bearer_manager.tscn").instantiate()
		StageManager.currentStage.MAP.add_child(drop_bearer_manager)
	
		
	if "worldmodifierspeed" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		Engine.time_scale = 2
		# back to 1 in StageManager.gd
	if Level.loadout.modeId == CONST.MODE_ASSIGNMENTS:
		for modifierId in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
			var modifier = Data.worldModifiers[modifierId]
			for gadgetId in modifier.get("gadgets", {}):
				if Data.gadgets.has(gadgetId) and !GameWorld.upgrades.has(gadgetId):
					GameWorld.addUpgrade(gadgetId)
			for upgradeId in modifier.get("upgrades", {}):
				if Data.upgrades.has(upgradeId):
					GameWorld.addUpgrade(upgradeId)
	
	if "worldmodifierautonomous" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		var condenser_property_changed = PropertyChange.new()
		condenser_property_changed.key = "condenser.growthtime"
		condenser_property_changed.keyClass = "condenser"
		condenser_property_changed.keyName = "growthtimex"
		condenser_property_changed.value = 0.3
		Data.applyPropertyChange(condenser_property_changed)
		
		
		var conv_prop2 = PropertyChange.new()
		conv_prop2.key = "converter.ironwatertime"
		conv_prop2.keyClass = "converter"
		conv_prop2.keyName = "ironwatertime"
		conv_prop2.value = 0.3
		Data.applyPropertyChange(conv_prop2)
		
	if Data.ofOr("assignment.id", "") == "superhot" :
		var prop = PropertyChange.new()
		prop.key = "laser.dps"
		prop.keyClass = "laser"
		prop.keyName = "dps"
		prop.value = 500.0
		Data.applyPropertyChange(prop)

func registerAchievenemnts():
	print("test assignments : ", Data.assignments.keys())
	var CUSTOM_ACHIEVEMENTS = [
		"ALL_DOMES_ASSESSOR",
		"ALL_DOMES_ENGINEER",
		"ALL_DOMES_ASSESSOR2",
		"ALL_DOMES_ENGINEER2",
		"SECRET_ENDING",
		"HEAVY_ROCK_ENDING",
		"CORE_EATER_ENDING",
		"DROP_BEARER_STOLEN",
		"ALL_CHAOS"
	]
	
	var info_achievements = [
		["MultiplayerLoadoutStage", "MINE_LOADOUT"],
		["LevelStage", "USELESS_EXPLOSION"],
		["LevelStage", "FAST_WHY"],
		["Relichunt", "RELIC_WAIT"],
		["Coresaver", "SECRET_ROOM"],
		["MultiplayerLoadoutStage", "ALL_ASSIGNMENTS"],
		["Coresaver", "WAKA_WAKA"],
		["Coresaver", "DOUBLE_TROUBLE"]
	]
	var data_achievements = get_node("/root/ModLoader/POModder-Dependency").data_achievements
	for achievement in CUSTOM_ACHIEVEMENTS:
		var a = load("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/" + achievement.to_lower()+ ".tscn")
		data_achievements.add_achievement(achievement,"")
		
	for achievement in info_achievements:
		var a = load("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/" + achievement[1].to_lower()+ ".tscn")
		a.take_over_path("res://mods-unpacked/POModder-Dependency/content/Achievements/" + achievement[1].to_lower()+ ".tscn")
		data_achievements.add_achievement(achievement[1], achievement[0])


