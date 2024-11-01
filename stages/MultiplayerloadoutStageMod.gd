extends MultiplayerLoadoutStage
class_name MultiplayerLoadoutStageMod

var saver_progress_id = "keeper_and_dome_progress"

@onready var data_achievements = get_node("/root/ModLoader/POModder-AllYouCanMine").data_achievements
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements
@onready var saver = get_node("/root/ModLoader/POModder-AllYouCanMine").saver

var current_assignment_page = 1
var assignments_per_page = 16
@onready var max_page : int = int(Data.assignments.keys().size()/assignments_per_page) + 1


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
	
	update_keeper_progress()
	
	update_assignments()
	

	var arrow_containers = %AssignmentsContainer.get_parent().get_child(1)
	
	var left_arrow = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
	left_arrow.find_child("Icon",true,false).flip_h = true
	left_arrow.connect("select", previous_page)
	arrow_containers.add_child(left_arrow)
	
	var right_arrow = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/page_choice.tscn").instantiate()
	arrow_containers.add_child(right_arrow)
	right_arrow.connect("select", next_page)

	
func update_keeper_progress():
	## save_dict[saver_progress_id] is {"keeper}" : {"dome" : true , ...} , "keeper2" : ... }
	saver.load_data()
	if !saver.save_dict.has(saver_progress_id): # if save_file is empty (first time)
		saver.save_dict[saver_progress_id] = {}
		
	var keeper_container = find_child("BlockProgress")
	
	for child in keeper_container.get_children():
		child.free()
		
	for keeper in Data.loadoutKeepers:
		var ui_dome_progress = preload("res://mods-unpacked/POModder-AllYouCanMine/content/dome_progress/UI_dome_progress.tscn").instantiate()
		keeper_container.add_child(ui_dome_progress)
		ui_dome_progress.find_child("Label").text = tr("upgrades." + keeper + ".title")
		var keeper_image = ui_dome_progress.find_child("TextureRect")
		keeper_image.texture = load("res://content/icons/loadout_" + keeper + "-skin0.png")
		keeper_image.custom_minimum_size = keeper_image.get_minimum_size()*3
		
		var save_progress = saver.save_dict[saver_progress_id]
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
		var hint = "achievement." + achievementId.to_lower() + ".hint"
		achievement_container.add_child(e)
		if Steam.getAchievement(achievementId)["achieved"]:
			e.setChoice(title, achievementId, null, desc)
			e.completed()
		else :
			e.setChoice(title, achievementId, null, hint)
			
	
	
func update_custom_achievements():
	var customAchievement_container = find_child("CustomAchievementsContainer")
	
	for child in customAchievement_container.get_children():
		child.free()
	
	for customAchievementId in data_achievements.CUSTOM_ACHIEVEMENTS:
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
	for child in %AssignmentsContainer.get_children():
		child.queue_free()
	for child in %AssignmentsContainer.get_parent().get_parent().get_children():
		if child is PanelContainer:
			child.queue_free()
	for assignmentId in Data.assignments.keys().slice((current_assignment_page-1)*16,current_assignment_page*16):
		var e = preload("res://stages/loadout/AssignmentChoice.tscn").instantiate()
		e.setAssignment(assignmentId)
		e.connect("select", assignmentSelected.bind(assignmentId))
		e.connect("select", updateBlockVisibility)
		%AssignmentsContainer.add_child(e)
	

		
func next_page():
	current_assignment_page = min(max_page,current_assignment_page+1)
	update_assignments()
	print(current_assignment_page)
	
func previous_page():
	current_assignment_page = max(1,current_assignment_page-1)
	update_assignments()
	print(current_assignment_page)
