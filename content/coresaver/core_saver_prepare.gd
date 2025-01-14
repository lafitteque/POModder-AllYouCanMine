extends Node2D

var props = []
var mod_main

func _ready():
	mod_main = get_node("/root/ModLoader/POModder-AllYouCanMine")
	
	
func prepareGameMode(modeId, levelStartData):
	print("Game mode prepare :" , modeId)
	
	if modeId != "prestige" and modeId != "assignments":
		for prop in mod_main.heatProperties:
			Data.applyPropertyChange(prop)
			print("Applied : ", prop.keyName, " with value " , prop.value)


	if modeId != "coresaver":
		return
		
	levelStartData.loadout.modeConfig[CONST.MODE_CONFIG_WORLDMODIFIERS] =  ["worldmodifiernorelic"]
	levelStartData.loadout.modeConfig["upgradelimits"] = ["hostile"]
	GameWorld.setUpgradeLimitAvailable("hostile")
	
	
	if not levelStartData.mapArchetype:
		var archetypeName:String = levelStartData.loadout.modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "regular-medium")
		archetypeName = "coresaver-"+archetypeName.rsplit("-")[1]	
		levelStartData.mapArchetype = load("res://mods-unpacked/POModder-AllYouCanMine/overwrites/" + archetypeName + ".tres").duplicate()
	levelStartData.mapArchetype.cobalt_rate *= 1.0 - 0.1 * levelStartData.loadout.difficulty

	if not levelStartData.loadout.worldId or levelStartData.loadout.worldId == "":
		levelStartData.loadout.worldId = GameWorld.getNextRandomWorldId()
		Data.apply("monsters.allowedtypes", Data.gameProperties.get("monstersbyworld." + levelStartData.loadout.worldId))
	
	for modifierId in levelStartData.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		if ! Data.worldModifiers.has(modifierId) :
			continue
		var modifier = Data.worldModifiers[modifierId]
		for propertyChange in modifier.get("propertychanges", {}):
			if levelStartData.mapArchetype and propertyChange.keyClass == "archetype":
				if propertyChange.value is String and  propertyChange.value.begins_with("res://"):
					levelStartData.mapArchetype.set(propertyChange.keyName, load(propertyChange.value))
				else:
					var oldValue =  levelStartData.mapArchetype.get(propertyChange.keyName)
					var newValue = propertyChange.getChangedValue(oldValue)
					levelStartData.mapArchetype.set(propertyChange.keyName, newValue)
			else:
				Data.applyPropertyChange(propertyChange)
		for slot in modifier.get("addslots", []):
			GameWorld.availableTechSlots.append(slot)
		for limit in modifier.get("upgradelimits", []):
			GameWorld.setUpgradeLimitAvailable(limit)
		for eraseLimit in modifier.get("eraseupgradelimits", []):
			GameWorld.removeAvailableUpgradeLimit(eraseLimit)
		var globalAreaOverrides = modifier.get("globalareaoverrides", {})
		for areaOverride in globalAreaOverrides:
			levelStartData.loadout.globalAreaOverrides[areaOverride] = globalAreaOverrides[areaOverride]
