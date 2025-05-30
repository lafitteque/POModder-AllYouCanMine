extends Node2D

var id = "coresaver"

var saver_progress_relichunt_id = "keeper_and_dome_progress_relichunt"
var saver_progress_coresaver_id = "keeper_and_dome_progress_coresaver"

@onready var saver = get_node("/root/ModLoader/POModder-Dependency").saver

var current_rh_page = 1
var progress_per_page = 2
var max_page_progress : int 

var current_coresaver_page = 1

var loadout

func initialize_from_loadout(loadout_scene):
	loadout = loadout_scene
	
	var block = preload("res://mods-unpacked/POModder-AllYouCanMine/content/dome_progress/block_progress.tscn").instantiate()
	loadout_scene.find_child("UI").add_child(block)

	var heatDisplay = preload("res://mods-unpacked/POModder-AllYouCanMine/content/HeatRoom/HeatDisplay.tscn").instantiate()
	heatDisplay.global_position = Vector2(-1150,-100)
	loadout_scene.find_child("UI").add_child(heatDisplay)
	
	var arrow = preload("res://mods-unpacked/POModder-Dependency/stages/page_choice.tscn")
	
	var rh = loadout_scene.find_child("BlockProgress", true, false).find_child("ArrowsRelichunt", true, false)
	var coresaver = loadout_scene.find_child("BlockProgress", true, false).find_child("ArrowsCoresaver", true, false)
	
	## Create arrows for progress Relic Hunt
	
	var left_arrow = arrow.instantiate()
	left_arrow.find_child("Icon",true,false).flip_h = true
	left_arrow.connect("select", previous_page_rh_progress)
	rh.add_child(left_arrow)
	Style.init(rh)
	
	var right_arrow = arrow.instantiate()
	rh.add_child(right_arrow)
	right_arrow.connect("select", next_page_rh_progress)
	Style.init(right_arrow)
	
	## Create arrows for progress Coresaver
	left_arrow = arrow.instantiate()
	left_arrow.find_child("Icon",true,false).flip_h = true
	left_arrow.connect("select", previous_page_coresaver_progress)
	coresaver.add_child(left_arrow)
	Style.init(rh)
	
	right_arrow = arrow.instantiate()
	coresaver.add_child(right_arrow)
	right_arrow.connect("select", next_page_coresaver_progress)
	Style.init(right_arrow)
	
	
func generate_ui_block(loadout_scene):
	return preload("res://mods-unpacked/POModder-AllYouCanMine/content/loadout_gamemode/block_core_saver_loadout.tscn").instantiate()
	
func has_difficulties():
	return true

func has_map_sizes():
	return true
	
func get_block_ui_name():
	return "BlockCoreSaverLoadout"

func has_tiledata():
	return true

func get_loadout_tiledata(tileData, requirements):
	var stack_list = [] 
	if "coresaver" in requirements:
		stack_list.append([preload("res://stages/loadout/TileDataModeRelicHunt.tscn").instantiate() , Vector2(-9, 2)])		
	if "coresaver" in requirements or "relichunt" in requirements or "assignments" in requirements :
		stack_list.append([preload("res://mods-unpacked/POModder-AllYouCanMine/content/HeatRoom/TileDataHeatRoom.tscn").instantiate() , Vector2(-9, 2)])
	return stack_list	
	
	
func set_gamemode_loadout(loadout_scene):
	var coresaver_loadout = GameWorld.lastLoadoutsByMode.get("relichunt").duplicate()
	coresaver_loadout.difficulty = 3
	coresaver_loadout.modeId = id
	coresaver_loadout.worldId = GameWorld.getNextRandomWorldId()
	loadout_scene.setLoadout(coresaver_loadout)

func fillGameModes(loadout):
	## Add progress for relichunt
	saver.load_data()
	if !saver.save_dict.has(saver_progress_relichunt_id): # if save_file is empty (first time)
		saver.save_dict[saver_progress_relichunt_id] = {}
		
	var block_progress = loadout.find_child("BlockProgress",true,false)
	var save_progress = saver.save_dict[saver_progress_relichunt_id]
	var block_progress_relichunt = block_progress.find_child("relichunt")
	add_mode_progress(block_progress_relichunt, save_progress, current_rh_page)


	## Add progress for coresaver
	if !saver.save_dict.has(saver_progress_relichunt_id): # if save_file is empty (first time)
		saver.save_dict[saver_progress_relichunt_id] = {}
		
	save_progress = saver.save_dict[saver_progress_coresaver_id]
	var block_progress_coresaver = block_progress.find_child("coresaver")
	add_mode_progress(block_progress_coresaver, save_progress, current_coresaver_page)


func add_mode_progress(ui_vbox, save_progress, current_progress_page):
	for child in ui_vbox.get_children():
		child.free()
		
	for keeper in Data.loadoutKeepers.slice((current_progress_page-1)*progress_per_page,current_progress_page*progress_per_page):
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
				
			var map_size = e.find_child("map_size",true,false)
			for child in map_size.get_children():
				child.self_modulate = Color(0.2,0.2,0.2,1)
				child.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/progress_map1.png")
			
			for mapsize in save_progress[keeper][dome].keys() :
				match mapsize:
					CONST.MAP_SMALL:
						map_size.set_map_size_to(CONST.MAP_SMALL, save_progress[keeper][dome][mapsize])
					CONST.MAP_MEDIUM:
						map_size.set_map_size_to(CONST.MAP_MEDIUM, save_progress[keeper][dome][mapsize])
					CONST.MAP_LARGE:
						map_size.set_map_size_to(CONST.MAP_LARGE, save_progress[keeper][dome][mapsize])
					CONST.MAP_HUGE:
						map_size.set_map_size_to(CONST.MAP_HUGE, save_progress[keeper][dome][mapsize])
			
			map_size.set_children_custom_size(2)
			ui_dome_progress.add_child(e)
			

func update_progress_coresaver():
		
	var block_progress = loadout.find_child("BlockProgress",true,false)
	var save_progress = saver.save_dict[saver_progress_coresaver_id]
	var block_progress_coresaver = block_progress.find_child("coresaver")
	add_mode_progress(block_progress_coresaver, save_progress, current_coresaver_page)

func update_progress_rh():
	var block_progress = loadout.find_child("BlockProgress",true,false)
	var save_progress = saver.save_dict[saver_progress_relichunt_id]
	var block_progress_rh = block_progress.find_child("relichunt")
	add_mode_progress(block_progress_rh, save_progress, current_rh_page)


func next_page_rh_progress():
	
	var max_page_progress = floor( (Data.loadoutKeepers.size() - 1 )/progress_per_page + 0.05) + 1

	current_rh_page = min(max_page_progress,current_rh_page+1)
	update_progress_rh()
	
func previous_page_rh_progress():
	var max_page_progress = floor( (Data.loadoutKeepers.size() - 1 )/progress_per_page + 0.05) + 1

	current_rh_page = max(1,current_rh_page-1)
	update_progress_rh()


func next_page_coresaver_progress():
	var max_page_progress = floor( (Data.loadoutKeepers.size() - 1 )/progress_per_page + 0.05) + 1

	current_coresaver_page = min(max_page_progress,current_coresaver_page+1)
	update_progress_coresaver()
	
func previous_page_coresaver_progress():
	var max_page_progress = floor( (Data.loadoutKeepers.size() - 1 )/progress_per_page + 0.05) + 1

	current_coresaver_page = max(1,current_coresaver_page-1)
	update_progress_coresaver()
	
