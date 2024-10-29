extends MultiplayerLoadoutStage
class_name MultiplayerLoadoutStageMod

@onready var data_achievements = get_node("/root/ModLoader/POModder-AllYouCanMine").data_achievements
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements

func createMapDataFor(requiremnts) -> MapData:
	var tileData = preload("res://content/map/MapData.tscn").instantiate()
	tileData.clear()
	tileData.stack(preload("res://stages/loadout/TileDataStartArea.tscn").instantiate(), Vector2(0, 1))
	
	for x in requiremnts:
		match x:
			"relichunt":
				tileData.stack(preload("res://stages/loadout/TileDataModeRelicHunt.tscn").instantiate(), Vector2(-9, 2))
			"prestige":
				tileData.stack(preload("res://stages/loadout/TileDataModePrestige.tscn").instantiate(), Vector2(-9, 2))
			"assignments":
				tileData.stack(preload("res://stages/loadout/TileDataModeAssignments.tscn").instantiate(), Vector2(-9, 2))
			"loadout":
				tileData.stack(preload("res://mods-unpacked/POModder-AllYouCanMine/content/Loadout_Achievements/TileDataLoadoutAchievements.tscn").instantiate(), Vector2(4, 2))
			"dome-opening":
				tileData.stack(preload("res://stages/loadout/TileDataDomeOpening.tscn").instantiate(), Vector2(-1, 2))
			"guildrewards":
				tileData.stack(preload("res://stages/loadout/TileDataGuildRewards.tscn").instantiate(), Vector2(5, 13))
	
	for coord in dugTileCoordinates:
		var res = tileData.get_resourcev(coord)
		if res >= 0 and res <= 10:
			tileData.clear_resource(coord)
	
	return tileData

func fillGameModes():
	super.fillGameModes()
	
	update_achievements()
	update_custom_achievements()
	
	
func update_achievements():
	var achievement_container = find_child("AchievementsContainer")
	
	for child in achievement_container.get_children():
		child.free()
	
	for achievementId in data_achievements.ACHIEVEMENTS:
		var e = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Loadout_Achievements/AchievementPanel.tscn").instantiate()
		var title = "achievement." + achievementId.to_lower() + ".title"
		var desc = "achievement." + achievementId.to_lower() + ".desc"
		achievement_container.add_child(e)
		if Steam.getAchievement(achievementId)["achieved"]:
			e.setChoice(title, achievementId, null, desc)
			e.completed()
		else :
			e.setChoice(title, achievementId, null, desc)
			
	
	
func update_custom_achievements():
	var customAchievement_container = find_child("CustomAchievementsContainer")
	
	for child in customAchievement_container.get_children():
		child.free()
	
	for customAchievementId in data_achievements.CUSTOM_ACHIEVEMENTS:
		var e = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Loadout_Achievements/AchievementPanel.tscn").instantiate()
		var title = "achievement." + customAchievementId.to_lower() + ".title"
		var desc = "achievement." + customAchievementId.to_lower() + ".desc"
		customAchievement_container.add_child(e)
		if custom_achievements_manager.isAchievementUnlocked(customAchievementId):
			e.setChoice(title, customAchievementId, null, desc)
			e.completed()
		else :
			e.setChoice(title, customAchievementId, null, desc)

func preGenerateMap(requirements):
	var generated = load("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/Map.tscn").instantiate()
	add_child(generated)
	generated.setTileData(createMapDataFor(requirements))
	generated.init(false, false)
	generated.revealInitialState(Vector2(0, 4))
	pregeneratedMaps[requirements] = generated
	remove_child(generated)
	return generated
