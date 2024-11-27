extends MultiplayerLoadoutStage
class_name MultiplayerLoadoutStageMod

var saver_progress_relichunt_id = "keeper_and_dome_progress_relichunt"
var saver_progress_coresaver_id = "keeper_and_dome_progress_coresaver"

@onready var data_achievements = get_node("/root/ModLoader/POModder-AllYouCanMine").data_achievements
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements
@onready var saver = get_node("/root/ModLoader/POModder-AllYouCanMine").saver

var current_assignment_page = 1
var assignment_per_page = 16
@onready var max_page_assignment : int = floor( (Data.assignments.keys().size() - 1 )/assignment_per_page) + 1


var current_game_mode_page = 1
var game_mode_per_page = 3
@onready var max_page_game_mode : int = floor( (Data.loadoutGameModes.size() - 1) /game_mode_per_page) + 1


var current_custom_achievement_page = 1
var custom_achievement_per_page = 24
@onready var max_page_custom_achievement : int = floor( (data_achievements.CUSTOM_ACHIEVEMENTS.size() - 1) /custom_achievement_per_page) + 1 



func build(data:Array):
	super(data)
	fillDifficulties("BlockCoreSaverLoadout")
	fillMapSizes("BlockCoreSaverLoadout")
	
func createMapDataFor(requiremnts) -> MapData:
	var tileData = preload("res://content/map/MapData.tscn").instantiate()
	tileData.clear()
	tileData.stack(preload("res://mods-unpacked/POModder-AllYouCanMine/stages/TileDataStartArea.tscn").instantiate(), Vector2(0, 1))
	
	for x in requiremnts:
		match x:
			"relichunt":
				tileData.stack(preload("res://stages/loadout/TileDataModeRelicHunt.tscn").instantiate(), Vector2(-9, 2))
			"prestige":
				tileData.stack(preload("res://stages/loadout/TileDataModePrestige.tscn").instantiate(), Vector2(-9, 2))
			"assignments":
				tileData.stack(preload("res://stages/loadout/TileDataModeAssignments.tscn").instantiate(), Vector2(-9, 2))
			"dome-opening":
				tileData.stack(preload("res://stages/loadout/TileDataDomeOpening.tscn").instantiate(), Vector2(-1, 2))
			"guildrewards":
				tileData.stack(preload("res://stages/loadout/TileDataGuildRewards.tscn").instantiate(), Vector2(5, 13))
			"coresaver":
				tileData.stack(preload("res://stages/loadout/TileDataModeRelicHunt.tscn").instantiate(), Vector2(-9, 2))
	if "loadout" in requiremnts:
		tileData.stack(preload("res://mods-unpacked/POModder-AllYouCanMine/content/Loadout_Achievements/TileDataLoadoutAchievements.tscn").instantiate(), Vector2(4, 2))
	
	for coord in dugTileCoordinates:
		var res = tileData.get_resourcev(coord)
		if res >= 0 and res <= 10:
			tileData.clear_resource(coord)
	
	return tileData

func fillGameModes():
	saver.load_data()
	if !saver.save_dict.has("game_mode_page"):
		saver.save_dict["game_mode_page"]  = current_game_mode_page
		saver.save_dict["assignments_page"] = current_assignment_page  
		saver.save_dict["custom_achievements_page"] = current_custom_achievement_page
		saver.save_dict["game_mode_loadout"] = Level.loadout.modeId
		saver.save_data() 
	Level.loadout.modeId = saver.save_dict["game_mode_loadout"] 
	current_game_mode_page = saver.save_dict["game_mode_page"] 
	current_assignment_page = saver.save_dict["assignments_page"] 
	current_custom_achievement_page = saver.save_dict["custom_achievements_page"] 
	super.fillGameModes()
	
	update_game_modes()
	
	update_achievements()
	update_custom_achievements()
	
	update_keeper_progress()
	
	update_assignments()
	

	## Create arrows for assignment pages
	if max_page_assignment > 1:
		var arrow_containers_assignment = %AssignmentsContainer.get_parent().get_child(1)

		var left_arrow_assignment = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		left_arrow_assignment.find_child("Icon",true,false).flip_h = true
		left_arrow_assignment.connect("select", previous_page_assignment)
		arrow_containers_assignment.add_child(left_arrow_assignment)
		Style.init(arrow_containers_assignment)
		
		var right_arrow_assignment = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		arrow_containers_assignment.add_child(right_arrow_assignment)
		right_arrow_assignment.connect("select", next_page_assignment)
		Style.init(right_arrow_assignment)
		
	## Create arrows for game mode pages
	if max_page_game_mode > 1:
		var arrow_containers_game_mode = $UI/BlockGameMode/HBoxContainer/GameModeMarginContainer/VBoxContainer/HBoxContainer
		
		var left_arrow_game_mode = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		left_arrow_game_mode.find_child("Icon",true,false).flip_h = true
		left_arrow_game_mode.connect("select", previous_page_game_mode)
		arrow_containers_game_mode.add_child(left_arrow_game_mode)
		Style.init(arrow_containers_game_mode)
		
		var right_arrow_game_mode = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		arrow_containers_game_mode.add_child(right_arrow_game_mode)
		right_arrow_game_mode.connect("select", next_page_game_mode)
		Style.init(right_arrow_game_mode)
	
	## Create arrows for custom achievement pages
	if max_page_custom_achievement > 1:
		var arrow_containers_custom_achievement = $UI/BlockCustomAchievements/VBoxContainer/ArrowsContainer

		var left_arrow_custom_achievement = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		left_arrow_custom_achievement.find_child("Icon",true,false).flip_h = true
		left_arrow_custom_achievement.connect("select", previous_page_custom_achievement)
		arrow_containers_custom_achievement.add_child(left_arrow_custom_achievement)
		Style.init(arrow_containers_custom_achievement)
			
		var right_arrow_custom_achievement = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
		arrow_containers_custom_achievement.add_child(right_arrow_custom_achievement)
		right_arrow_custom_achievement.connect("select", next_page_custom_achievement)
		Style.init(right_arrow_custom_achievement)
			
	await get_tree().create_timer(0.2).timeout
	gameModeSelected(Level.loadout.modeId)
	
func update_game_modes():
	saver.save_dict["game_mode_page"] = current_game_mode_page
	saver.save_data()
	var container = find_child("GameModeContainers")
	
	for child in container.get_children():
		child.queue_free()
	
	for id in Data.loadoutGameModes.slice((current_game_mode_page-1)*game_mode_per_page,current_game_mode_page*game_mode_per_page):
		var image = load("res://content/icons/loadout_" + id + ".png")
		var e = preload("res://stages/loadout/LoadoutChoice.tscn").instantiate()
		if GameWorld.isUnlocked(id):
			e.setChoice("upgrades." + id + ".title", id, image, "upgrades." + id + ".desc")
		else:
			e.setChoice("upgrades." + id + ".title", id, image, "unlock.generic")
			e.set_enabled(false)
		container.add_child(e)
		e.connect("select", gameModeSelected.bind(id))
		e.connect("select", updateBlockVisibility)
	
		
func fillDifficulties(BlockDifficultyName : String = "BlockRelicHuntLoadout"):
	var pgc = $UI.find_child(BlockDifficultyName,true,false).find_child("DifficultyContainers",true,false)
	var difficulties := [-2, -1, 0, 2]
	for i in 4:
		var image = load("res://content/icons/loadout_diff" + str(i) + ".png")
		var e = preload("res://stages/loadout/LoadoutChoice.tscn").instantiate()
		e.loadoutScale = 2.0
		var diffName = CONST.difficultyStringByInt.get(difficulties[i])
		var desc:String
		if GameWorld.isUnlocked(CONST.difficultyIdByInt[difficulties[i]]):
			desc = diffName + ".description"
		else:
			desc = diffName.replace("loadout", "unlock")
			e.set_enabled(false)
		e.setChoice(diffName, str(difficulties[i]), image, desc)
		pgc.add_child(e)
		e.select.connect(difficultySelected.bind(difficulties[i]))
		e.connect("select", updateBlockVisibility)
	if Level.loadout.difficulty == null or  not(Level.loadout.difficulty in [-2,-1,0,2]):
			Level.loadout.difficulty = -2
	difficultySelected(Level.loadout.difficulty)

	
func update_keeper_progress():
	## Add progress for relichunt
	saver.load_data()
	if !saver.save_dict.has(saver_progress_relichunt_id): # if save_file is empty (first time)
		saver.save_dict[saver_progress_relichunt_id] = {}
		
	var save_progress = saver.save_dict[saver_progress_relichunt_id]
	var block_progress_relichunt = $UI/BlockProgress/relichunt
	add_mode_progress(block_progress_relichunt, save_progress)


	## Add progress for coresaver
	if !saver.save_dict.has(saver_progress_relichunt_id): # if save_file is empty (first time)
		saver.save_dict[saver_progress_relichunt_id] = {}
		
	save_progress = saver.save_dict[saver_progress_coresaver_id]
	var block_progress_coresaver = $UI/BlockProgress/coresaver
	add_mode_progress(block_progress_coresaver, save_progress)


func add_mode_progress(ui_vbox, save_progress):
	for child in ui_vbox.get_children():
		if child is Label :
			continue
		child.free()
		
	for keeper in Data.loadoutKeepers:
		var ui_dome_progress = preload("res://mods-unpacked/POModder-AllYouCanMine/content/dome_progress/UI_dome_progress.tscn").instantiate()
		ui_vbox.add_child(ui_dome_progress)
		ui_dome_progress.find_child("Label").text = tr("upgrades." + keeper + ".title")
		var keeper_image = ui_dome_progress.find_child("TextureRect")
		keeper_image.texture = load("res://content/icons/loadout_" + keeper + "-skin0.png")
		keeper_image.custom_minimum_size = keeper_image.get_minimum_size()*3
		
		
		if !save_progress.has(keeper): # if save_file is empty (first time)
			save_progress[keeper] = {}
		
		for dome in Data.loadoutDomes:
			var e  = preload("res://mods-unpacked/POModder-AllYouCanMine/content/dome_progress/dome_progress.tscn").instantiate()
			var dome_texture = e.find_child("Sprite2D")
			dome_texture.texture = load("res://content/icons/loadout_" + dome + ".png").duplicate()
			dome_texture.custom_minimum_size = dome_texture.get_minimum_size()*2
			
			if !save_progress[keeper].has(dome): # if save_file is empty (first time)
				save_progress[keeper][dome] = {}
				
			if save_progress[keeper][dome].keys().size() > 0: # if any game setup beaten
				dome_texture.self_modulate = Color(1.0,1.0,1.0,1)
				dome_texture.material = ShaderMaterial.new()
				dome_texture.material.set("shader", load("res://mods-unpacked/POModder-AllYouCanMine/content/dome_progress/dome_progress_shine.gdshader"))
				dome_texture.material.set_shader_parameter("line_width", 0.1)
				dome_texture.material.set_shader_parameter("angle", 1.2)
				dome_texture.material.set_shader_parameter("shine_color", Color(0.949, 0.631, 0.353))
			else :
				dome_texture.self_modulate = Color(0.2,0.2,0.2,1)
				
			var map_sizer = e.find_child("map_size",true,false)
			for child in map_sizer.get_children():
				child.self_modulate = Color(0.2,0.2,0.2,1)
					
			for mapsize in save_progress[keeper][dome].keys() :
				match mapsize:
					CONST.MAP_SMALL:
						map_sizer.set_map_size_to(CONST.MAP_SMALL, save_progress[keeper][dome][mapsize])
					CONST.MAP_MEDIUM:
						map_sizer.set_map_size_to(CONST.MAP_MEDIUM, save_progress[keeper][dome][mapsize])
					CONST.MAP_LARGE:
						map_sizer.set_map_size_to(CONST.MAP_LARGE, save_progress[keeper][dome][mapsize])
					CONST.MAP_HUGE:
						map_sizer.set_map_size_to(CONST.MAP_HUGE, save_progress[keeper][dome][mapsize])
			map_sizer.set_children_custom_size(2)
			ui_dome_progress.add_child(e)
			
	
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
			e.setChoice(title, achievementId, null, "")
			
	
	
func update_custom_achievements():
	saver.save_dict["custom_achievements_page"] = current_custom_achievement_page
	saver.save_data()
	var customAchievement_container = find_child("CustomAchievementsContainer")
	
	for child in customAchievement_container.get_children():
		child.free()
	
	for customAchievementId in data_achievements.CUSTOM_ACHIEVEMENTS.slice((current_custom_achievement_page-1)*custom_achievement_per_page,current_custom_achievement_page*custom_achievement_per_page):
		var e = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Loadout_Achievements/AchievementPanel.tscn").instantiate()
		var title = "achievement." + customAchievementId.to_lower() + ".title"
		var desc = "achievement." + customAchievementId.to_lower() + ".desc"
		var hint = "achievement." + customAchievementId.to_lower() + ".hint"
		customAchievement_container.add_child(e)
		if custom_achievements_manager.isAchievementUnlocked(customAchievementId):
			e.setChoice(title, customAchievementId, null, desc)
			e.completed()
		else :
			e.setChoice(title, customAchievementId, null, hint)

func preGenerateMap(requirements):
	var generated = load("res://mods-unpacked/POModder-AllYouCanMine/replacing_files/Map.tscn").instantiate()
	add_child(generated)
	generated.setTileData(createMapDataFor(requirements))
	generated.init(false, false)
	generated.revealInitialState(Vector2(0, 4))
	pregeneratedMaps[requirements] = generated
	remove_child(generated)
	return generated

func update_assignments():
	saver.save_dict["assignments_page"] = current_assignment_page
	saver.save_data()
	for child in %AssignmentsContainer.get_children():
		child.queue_free()
	for child in %AssignmentsContainer.get_parent().get_parent().get_children():
		if child is PanelContainer:
			child.queue_free()
	for assignmentId in Data.assignments.keys().slice((current_assignment_page-1)*assignment_per_page,current_assignment_page*assignment_per_page):
		var e = preload("res://stages/loadout/AssignmentChoice.tscn").instantiate()
		e.setAssignment(assignmentId)
		e.connect("select", assignmentSelected.bind(assignmentId))
		if assignmentId == "pyromaniac" :
			e.connect("select", pyromaniac_selected)
		else : 
			e.connect("select", pyromaniac_remove)
		e.connect("select", updateBlockVisibility)
		%AssignmentsContainer.add_child(e)
	
	if Level.loadout.modeId == CONST.MODE_ASSIGNMENTS and Level.loadout.modeConfig.has(CONST.MODE_CONFIG_ASSIGNMENT):
		assignmentSelected(Level.loadout.modeConfig.get(CONST.MODE_CONFIG_ASSIGNMENT))
		
		
func pyromaniac_selected():
	Data.parseUpgradesYaml("res://mods-unpacked/POModder-AllYouCanMine/yaml/upgrades.yaml")
	
func pyromaniac_remove():
	Data.gadgets.erase("blastminingassignment")
	Data.gadgets.erase("suitblasterassignment")


func gameModeSelected(id:String):
	saver.save_dict["game_mode_loadout"] = id
	saver.save_data()
	if ensureDelayBetweenMajorActions():
		return
		
	var oldId = Level.loadout.modeId
	if oldId == CONST.MODE_PRESTIGE and Level.loadout.modeConfig.has(CONST.MODE_CONFIG_PRESTIGE_VARIANT):
		oldId = Level.loadout.modeConfig.get(CONST.MODE_CONFIG_PRESTIGE_VARIANT)
	GameWorld.lastLoadoutsByMode[oldId] = Level.loadout.duplicate()
	
	#clear any config that might bleed over to other gamemodes when it shouldn't
	Level.loadout.modeConfig.erase(CONST.MODE_CONFIG_ADDITIONAL_GADGETS)
	Level.loadout.modeConfig.erase(CONST.MODE_CONFIG_ASSIGNMENT)
	Level.loadout.modeConfig.erase(CONST.MODE_CONFIG_WORLDMODIFIERS)
	
	Level.loadout.modeId = id
	match id:
		CONST.MODE_RELICHUNT:
			if GameWorld.lastLoadoutsByMode.has(id):
				setLoadout(GameWorld.lastLoadoutsByMode.get(id))
		"coresaver":
			if GameWorld.lastLoadoutsByMode.has(id):
				var coresaver_loadout = GameWorld.lastLoadoutsByMode.get("relichunt").duplicate()
				coresaver_loadout.difficulty = 3
				coresaver_loadout.modeId = "coresaver"
				coresaver_loadout.worldId = GameWorld.getNextRandomWorldId()
				setLoadout(coresaver_loadout)
		CONST.MODE_PRESTIGE:
			var found = false
			for c in find_child("PrestigeModeVariantContainer").get_children():
				if not c is Label and c.selected:
					if GameWorld.lastLoadoutsByMode.has(c.id):
						setLoadout(GameWorld.lastLoadoutsByMode.get(c.id))
						found = true
						break
			if not found and GameWorld.lastLoadoutsByMode.has(id):
				setLoadout(GameWorld.lastLoadoutsByMode.get(id))
		CONST.MODE_ASSIGNMENTS:
			if GameWorld.lastLoadoutsByMode.has(id):
				setLoadout(GameWorld.lastLoadoutsByMode.get(id))
			%AssignmentLeaderboard.start()
			updateRewardStatus()
	
	for c in find_child("GameModeContainers").get_children():
		if not c is Label:
			c.selected = c.id == id
	
	updateAllHintContainers()

		
func updateBlockVisibility(forceRebuild := false):
	if not initialized:
		return
		
	var stackedTileDataIds := []
	if GameWorld.figuredOutMovementInLoadout:
		var blockRelicHunt = find_child("BlockRelicHuntLoadout") 
		blockRelicHunt.visible = Level.loadout.modeId == CONST.MODE_RELICHUNT
		if blockRelicHunt.visible:
			stackedTileDataIds.append("relichunt")
		
		var blockPrestige = find_child("BlockPrestigeLoadout") 
		blockPrestige.visible = Level.loadout.modeId == CONST.MODE_PRESTIGE
		if blockPrestige.visible:
			stackedTileDataIds.append("prestige")
		
		var blockAssignments = find_child("BlockAssignmentsLoadout") 
		blockAssignments.visible = Level.loadout.modeId == CONST.MODE_ASSIGNMENTS
		if blockAssignments.visible:
			stackedTileDataIds.append("assignments")
		else:
			%AdditionalGadgetContainers.visible = false
		
		var blockCoreSaver = find_child("BlockCoreSaverLoadout") 
		blockCoreSaver.visible = Level.loadout.modeId == "coresaver"
		if blockCoreSaver.visible:
			stackedTileDataIds.append("coresaver")
				
		var blockLoadout = find_child("BlockDomeLoadout") 
		blockLoadout.visible = (blockRelicHunt.visible and Level.loadout.modeConfig.has(CONST.MODE_CONFIG_MAP_ARCHETYPE))\
		or (blockPrestige.visible and Level.loadout.modeConfig.get(CONST.MODE_CONFIG_PRESTIGE_VARIANT, "") != "")\
		or (blockAssignments.visible and Level.loadout.modeConfig.get(CONST.MODE_CONFIG_ASSIGNMENT, "") != "")\
		or (blockCoreSaver.visible)
		if blockLoadout.visible:
			stackedTileDataIds.append("loadout")
			blockLoadout.size.x = 0
		
		%BlockGuildReward.visible = GameWorld.isUnlocked(CONST.MODE_ASSIGNMENTS) and blockLoadout.visible
		if %BlockGuildReward.visible:
			updateRewardStatus()
			stackedTileDataIds.append("guildrewards")
		
		if Level.dome:
			stackedTileDataIds.append("dome-opening")
	
	updateStartRunButton()
	
	var rebuildMap := false
	for id in lastStackedTileData:
		if not stackedTileDataIds.has(id):
			rebuildMap = true
			break
	for id in stackedTileDataIds:
		if not lastStackedTileData.has(id):
			rebuildMap = true
			break
	
	if rebuildMap or forceRebuild:
		var drops := []
		for drop in get_tree().get_nodes_in_group("drops"):
			drops.append(drop)
			drop.get_parent().remove_child(drop)
		
		var map
		if pregeneratedMaps.has(stackedTileDataIds):
			map = pregeneratedMaps[stackedTileDataIds]
		else:
			map = preGenerateMap(stackedTileDataIds)
		
		remove_child(MAP)
		add_child(map)
		MAP = map
		Level.map = map
		runDecoration()
		
		ensure_player_in_bounds()
		create_tween().tween_callback(ensure_player_in_bounds).set_delay(0.1)
		
		for drop in drops:
			MAP.addDrop(drop)
			
		for coord in MAP.tileData.get_mineable_tile_coords():
			MAP.addTileDestroyedListener(self, coord)
		
		if GameWorld.devMode:
			var packedTileData = MAP.tileData.pack()
			ResourceSaver.save(packedTileData, "res://stages/loadout/TileDataLoadoutResultDebug.tscn")
		
		if visibilityTween:
			visibilityTween.kill()
			
		for c in $VisibilityChecker.get_children():
			c.queue_free()
			
		#recreave visibility over multiple frames to avoid lagspike
		var tw = create_tween()
		var revealed = MAP.getTileData().getRevealedCells()
		#spawn higher ones first to stop the camera from moving up again
		revealed.sort_custom(func(x,y): return x.y < y.y)
		for coord in ceil(revealed.size()/20.0):
			tw.tween_callback(addVisibilitiyTileArr.bind(revealed.slice(coord*20,coord*20+20))).set_delay(0.05)
	
	lastStackedTileData = stackedTileDataIds
	
	# update available loadout
	for c in find_child("PrimaryGadgetContainers").get_children():
		if not c is Label:
			if Level.loadout.modeId == CONST.MODE_PRESTIGE and \
			 Level.loadout.modeConfig.get(CONST.MODE_CONFIG_PRESTIGE_VARIANT, "") == CONST.MODE_PRESTIGE_MINER:
				c.visible = not Data.gadgets.get(c.id).get("limit", []).has("hostile")
			else:
				c.visible = true
				
func fillMapSizes(BlockDifficultyName : String = "BlockRelicHuntLoadout"):
	var pgc = $UI.find_child(BlockDifficultyName,true,false).find_child("MapsizeContainers",true,false)
	var mapsizes := []
	for ms in [CONST.MAP_SMALL, CONST.MAP_MEDIUM, CONST.MAP_LARGE, CONST.MAP_HUGE]:
		if GameWorld.isUnlocked(ms):
			mapsizes.append(ms)
	for ms in [CONST.MAP_SMALL, CONST.MAP_MEDIUM, CONST.MAP_LARGE, CONST.MAP_HUGE]:
		var e = preload("res://stages/loadout/LoadoutChoice.tscn").instantiate()
		e.loadoutScale = 2.0
		var desc:String
		if GameWorld.isUnlocked(ms):
			desc = CONST.mapSizesStringsById.get(ms) + ".description"
		else:
			desc = "unlock.mapsize." + ms.replace("regular-", "")
			e.set_enabled(false)
		var title = CONST.mapSizesStringsById.get(ms)
		e.setChoice(title, ms, null, desc)
		pgc.add_child(e)
		e.connect("select", mapSizeSelected.bind(ms))
		e.connect("select", updateBlockVisibility)
		if GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION and ms != CONST.MAP_SMALL:
			e.disable()
	
	if GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION:
		mapSizeSelected(CONST.MAP_SMALL)
	else:
		var conf = Level.loadout.modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE)
		if conf == null or conf == "":
			conf = CONST.MAP_SMALL
		if not [CONST.MAP_SMALL, CONST.MAP_MEDIUM, CONST.MAP_LARGE, CONST.MAP_HUGE].has(conf):
			conf = CONST.MAP_SMALL
		mapSizeSelected(conf)			
		
func mapSizeSelected(id):
	resetPersistMetaCooldown()
	Audio.sound("gui_select")
	Level.loadout.modeConfig[CONST.MODE_CONFIG_MAP_ARCHETYPE] = id
	
	var blocks  = []
	blocks.append(find_child("BlockRelicHuntLoadout",true,false))
	blocks.append(find_child("BlockCoreSaverLoadout",true,false))
		
	for b in blocks :
		for c in b.find_child("MapsizeContainers").get_children():
			if not c is Label:
				c.selected = c.id == id
	GameWorld.getNextRandomWorldId()

			
func difficultySelected(d):
	resetPersistMetaCooldown()
	Audio.sound("gui_select")
	Level.loadout.difficulty = d
	
	var blocks = []
	blocks.append( $UI.find_child("BlockRelicHuntLoadout",true,false) )
	blocks.append($UI.find_child("BlockCoreSaverLoadout",true,false))
		
	for b in blocks :
		for c in b.find_child("DifficultyContainers").get_children():
			if not c is Label:
				c.selected = c.id == str(d)

			
func startRun():
	var a = Level.loadout.modeConfig
	if a.has("assignment") and a["assignment"] == "superhot":
		domeSelected("dome1")
	
	%StartRunChoice.set_enabled(false)
	
	Audio.sound("gui_loadout_startrun")
	for loadoutKeeper in Level.loadout.keepers:
		if loadoutKeeper.keeper == null:
			return
		loadoutKeeper.playerId = loadoutKeeper.keeper.playerId
		
		#override ost-source to the last player
		GameWorld.ostKeeperId = loadoutKeeper.keeperId
	
	match Level.loadout.modeId:
		CONST.MODE_PRESTIGE:
			if Level.loadout.modeConfig.get(CONST.MODE_CONFIG_PRESTIGE_FRIENDLY_MODE, false):
				Level.loadout.difficulty = -2
			else:
				Level.loadout.difficulty = 0
		CONST.MODE_ASSIGNMENTS:
			if Level.loadout.modeConfig.get(CONST.MODE_CONFIG_ASSIGNMENT_CHALLENGE_MODE, false):
				Level.loadout.difficulty = 0
			else:
				Level.loadout.difficulty = 0
	
	var startData = LevelStartData.new()
	startData.loadout = Level.loadout.asLoadout()
	if get_tree().get_nodes_in_group("keeper").size() > 1:
		Level.loadout.additionalGadgets = ["autocannon"]
	
	if GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION:
		startData.tileDataPresetId = "Exhibition"
	
	GameWorld.lastLoadoutsByMode["last"] = Level.loadout.duplicate()
	Level.randomizeSeed()
	
	Audio.stopMusic()
	
	StageManager.startStage("stages/landing/landing", [startData])



func next_page_assignment():
	current_assignment_page = min(max_page_assignment,current_assignment_page+1)
	update_assignments()
	
func previous_page_assignment():
	current_assignment_page = max(1,current_assignment_page-1)
	update_assignments()
	
	
	
func next_page_game_mode():
	current_game_mode_page = min(max_page_game_mode,current_game_mode_page+1)
	update_game_modes()
	
func previous_page_game_mode():
	current_game_mode_page = max(1,current_game_mode_page-1)
	update_game_modes()
	
	
	
func next_page_custom_achievement():
	current_custom_achievement_page = min(max_page_custom_achievement,current_custom_achievement_page+1)
	update_custom_achievements()
	
func previous_page_custom_achievement():
	current_custom_achievement_page = max(1,current_custom_achievement_page-1)
	update_custom_achievements()


	
