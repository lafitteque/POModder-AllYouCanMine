extends Node2D

func prepareGameMode(modeId, levelStartData):
	print("Game mode prepare :" , modeId)
	if modeId != "coresaver":
		return
		
	levelStartData.loadout.modeConfig[CONST.MODE_CONFIG_WORLDMODIFIERS] =  ["worldmodifiernorelic"]
	levelStartData.loadout.modeConfig["upgradelimits"] = ["hostile"]
	GameWorld.setUpgradeLimitAvailable("hostile")
	
	
	if not levelStartData.mapArchetype:
		var archetypeName:String = levelStartData.loadout.modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "regular-medium")
		archetypeName = "coresaver-"+archetypeName.rsplit("-")[1]	
		levelStartData.mapArchetype = load("res://mods-unpacked/POModder-AllYouCanMine/overwrites/" + archetypeName + ".tres").duplicate()
		print("loaded archetype for core saver : " , "res://mods-unpacked/POModder-AllYouCanMine/overwrites/" + archetypeName + ".tres")
	levelStartData.mapArchetype.cobalt_rate *= 1.0 - 0.1 * levelStartData.loadout.difficulty

	if not levelStartData.loadout.worldId or levelStartData.loadout.worldId == "":
		levelStartData.loadout.worldId = GameWorld.getNextRandomWorldId()
		Data.apply("monsters.allowedtypes", Data.gameProperties.get("monstersbyworld." + levelStartData.loadout.worldId))
	
	for modifierId in levelStartData.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
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
