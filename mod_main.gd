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
	
	manage_overwrites()
	
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
	
	
	var modifiers = ["pyromaniac", "autonomous",
	"superhot", "speed", 
	"aprilfools", "smalldrops",
	"bigdrops"]
	for modifier in modifiers :
		GameWorld.unlockedRunModifiers.append(modifier)
		
# Called when the node enters the scene tree for the first time.
func manage_overwrites():
	### Adding new map archetypes for assignments
	var new_archetype_mineall = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-mineall.tres")
	new_archetype_mineall.take_over_path("res://content/map/generation/archetypes/assignment-mineall.tres")

	var new_archetype_detonators = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-detonators.tres")
	new_archetype_detonators.take_over_path("res://content/map/generation/archetypes/assignment-detonators.tres")

	var new_archetype_destroyer = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-destroyer.tres")
	new_archetype_destroyer.take_over_path("res://content/map/generation/archetypes/assignment-destroyer.tres")

	var new_archetype_aprilfools = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-aprilfools.tres")
	new_archetype_aprilfools.take_over_path("res://content/map/generation/archetypes/assignment-aprilfools.tres")
	
	var new_archetype_thieves = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-thieves.tres")
	new_archetype_thieves.take_over_path("res://content/map/generation/archetypes/assignment-thieves.tres")
	
	var new_archetype_secrets = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-secrets.tres")
	new_archetype_secrets.take_over_path("res://content/map/generation/archetypes/assignment-secrets.tres")
	
	var new_archetype_megairon = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-megairon.tres")
	new_archetype_megairon.take_over_path("res://content/map/generation/archetypes/assignment-megairon.tres")
	
	var new_archetype_chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-chaos.tres")
	new_archetype_chaos.take_over_path("res://content/map/generation/archetypes/assignment-chaos.tres")
	
	var new_archetype_tiny = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-tinyplanet.tres")
	new_archetype_tiny.take_over_path("res://content/map/generation/archetypes/assignment-tinyplanet.tres")
	
	var new_archetype_pyromaniac = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-pyromaniac.tres")
	new_archetype_pyromaniac.take_over_path("res://content/map/generation/archetypes/assignment-pyromaniac.tres")
	
	var new_archetype_speleologist = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-speleologist.tres")
	new_archetype_speleologist.take_over_path("res://content/map/generation/archetypes/assignment-speleologist.tres")
	
	var new_archetype_autonomous = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-autonomous.tres")
	new_archetype_autonomous.take_over_path("res://content/map/generation/archetypes/assignment-autonomous.tres")
	
	var new_archetype_superhot = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-superhot.tres")
	new_archetype_superhot.take_over_path("res://content/map/generation/archetypes/assignment-superhot.tres")
	
	var new_archetype_debt = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/assignment-debt.tres")
	new_archetype_debt.take_over_path("res://content/map/generation/archetypes/assignment-debt.tres")
	
	### Adding new map archetypes for custom Game Mode
	
	var new_archetype_huge_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-huge.tres")
	new_archetype_huge_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-huge.tres")
	
	var new_archetype_large_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-large.tres")
	new_archetype_large_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-large.tres")
	
	var new_archetype_medium_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-medium.tres")
	new_archetype_medium_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-medium.tres")
	
	var new_archetype_small_coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/overwrites/coresaver-small.tres")
	new_archetype_small_coresaver.take_over_path("res://content/map/generation/archetypes/coresaver-small.tres")



	### Custom Game Mode (simply a copy of relichunt) :
	
	var coresaver = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/gamemode.tscn")
	coresaver.take_over_path("res://content/gamemode/coresaver/Coresaver.tscn")
	
	### Coresaver Icon
	
	var coresaver_icon = preload("res://mods-unpacked/POModder-AllYouCanMine/images/coresaver.png")
	coresaver_icon.take_over_path("res://content/icons/loadout_coresaver.png")
	
	
	### Blist Miner (pyromaniac) Icons (copy from vanilla game)
	
	var blastmining = preload("res://content/icons/blastmining.png")
	blastmining.take_over_path("res://content/icons/blastminingassignment.png")


	var blastminingblast1 = preload("res://content/icons/blastminingblast1.png")
	blastminingblast1.take_over_path("res://content/icons/blastminingblastassignment1.png")
	
	var blastminingblast2 = preload("res://content/icons/blastminingblast2.png")
	blastminingblast2.take_over_path("res://content/icons/blastminingblastassignment2.png")
	
	var blastminingblast3 = preload("res://content/icons/blastminingblast3.png")
	blastminingblast3.take_over_path("res://content/icons/blastminingblastassignment3.png")
	
	var blast_time = preload("res://content/icons/blastminingproductiontime1.png")
	blast_time.take_over_path("res://content/icons/blastminingproductiontimeassignment1.png")
	
	var blast_sticky = preload("res://content/icons/blastminingstickycharge.png")
	blast_sticky.take_over_path("res://content/icons/blastminingstickychargeassignment.png")		
		
	var blast_impact = preload("res://content/icons/blastminingimpactdetonation.png")
	blast_impact.take_over_path("res://content/icons/blastminingimpactdetonationassignment.png")		
		
		
	### Same for Suit Blaster (pyromaniac)
	var suitblaster = preload("res://content/icons/suitblaster.png")
	suitblaster.take_over_path("res://content/icons/suitblasterassignment.png")
	
	var suitblaster_radius = preload("res://content/icons/suitblasterradius1.png")
	suitblaster_radius.take_over_path("res://content/icons/suitblasterradiusassignment.png")
	
	var suitblaster_max_charge = preload("res://content/icons/suitblastermaxcharge.png")
	suitblaster_max_charge.take_over_path("res://content/icons/suitblastermaxchargeassignment.png")
	
	var suitblaster_speed = preload("res://content/icons/suitblasterspeed1.png")
	suitblaster_speed.take_over_path("res://content/icons/suitblasterspeedassignment1.png")
	
	
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

	var mining_data = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Data/mining_data.tscn").instantiate()
	add_child(mining_data)
	## Actions that need an action from StageManagerExtender
	await get_tree().create_timer(0.5).timeout
	var bb = Level.loadout
	if data_mod.generation_data["drop_bearer_rate"] > 0:
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


