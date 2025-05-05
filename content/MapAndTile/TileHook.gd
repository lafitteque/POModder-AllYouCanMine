extends Node2D

func serialize(tile):
	return
	
# Called when the node enters the scene tree for the first time.
func deserialize(tile):
	var set_meta_destructible = false
	match tile.type :
		"mega_iron": 
			set_meta_destructible = true
			customInitResourceSprite(tile,Vector2(randi_range(0,1),1))
		"detonator": 
			var detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()
			tile.add_child(detonator)
			detonator.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(1,0))
		"destroyer":
			var destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()
			tile.add_child(destroyer)
			destroyer.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(2,0))
		"chaos": 
			var chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()
			tile.add_child(chaos)
			chaos.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(2,1))
		"bad_relic":
			set_meta_destructible = true
			customInitResourceSprite(tile,Vector2(3,randi_range(0,1)))
		"glass":
			set_meta_destructible = true
			var coreater_animation = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEater.tscn").instantiate()
			tile.add_child(coreater_animation)
			Style.init(coreater_animation)
			coreater_animation.show()
			coreater_animation.play("main")
			tile.res_sprite.hide()
		"fake_border":
			set_meta_destructible = true
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null
		"secret_room":
			set_meta_destructible = true
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null
	return false
	
func set_meta_destructable(tile, type):
	if tile.hardness == 7 and type == CONST.BORDER:
		tile.type = "fake_border"
		tile.hardness = 3
		return true

	if tile.type in ["mega_iron", "detonator", "destroyer", "chaos", "bad_relic", "glass", "fake_border", "secret_room"]:
		return true
			
	return false

func setType(tile, type, baseHealth):
	
	match type :
		"mega_iron": 
			customInitResourceSprite(tile,Vector2(randi_range(0,1),1))
			baseHealth += Data.of("map.megaIronAdditionalHealth")
		"detonator": 
			var detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()
			tile.add_child(detonator)
			detonator.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(1,0))
		"destroyer":
			var destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()
			tile.add_child(destroyer)
			destroyer.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(2,0))
		"chaos": 
			var chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTileCreator.tscn").instantiate()
			tile.add_child(chaos)
			chaos.global_position = tile.global_position
			customInitResourceSprite(tile,Vector2(2,1))
		"bad_relic":
			customInitResourceSprite(tile,Vector2(3,randi_range(0,1)))
			baseHealth += Data.of("map.badRelicAdditionalHealth")
		"glass":
			var coreater_animation = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEater.tscn").instantiate()
			tile.add_child(coreater_animation)
			coreater_animation.show()
			coreater_animation.play("main")
			Style.init(coreater_animation)
			tile.res_sprite.hide()
			baseHealth += Data.of("map.glassAdditionalHealth")
		"fake_border":
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null
			baseHealth += Data.of("map.fakeBorderAdditionalHealth")
		"secret_room":
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null
			baseHealth += Data.of("map.secretRoomAdditionalHealth")
	
	
	if "worldmodifieraprilfools" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []) :
		if tile.type in [CONST.IRON, CONST.SAND, CONST.WATER,
		 "detonator", "destroyer" , "mega_iron"]: 
			var vec_list = [\
				Vector2(5, 0) , Vector2(randi_range(2, 6), 11) , \
				Vector2(2, 3) , Vector2(randi_range(2, 3), 7) , \
				Vector2(4, 1), Vector2(4, 1), Vector2(4, 2),\
				Vector2(4, 2), Vector2(5, 0)]
			var rand_index = randi_range(0,8) 
			tile.initResourceSprite(vec_list[rand_index]) 
			
	return baseHealth

func hit(tile, type, dir, dmg):
	var detonator
	var destroyer
	
	if tile.type == "detonator":
		for child in tile.get_children():
			if "tile_child_type" in child and child.tile_child_type == "detonator":
				detonator = child
		
	if tile.type == "destroyer":
		for child in tile.get_children():
			if "tile_child_type" in child and child.tile_child_type == "destroyer":
				destroyer = child
		
		
	if detonator and is_instance_valid(detonator) and  !detonator.exploded:
		detonator.explode()
	
	if destroyer and is_instance_valid(destroyer) and !destroyer.exploded:
		destroyer.explode()
			
			
func tileBreak(tile, type, dir, dmg):
	var chaos
	if tile.type == "chaos":
		for child in tile.get_children():
			if "tile_child_type" in child and child.tile_child_type == "chaos":
				chaos = child
		
	if chaos and is_instance_valid(chaos) and !chaos.used:
			chaos.activate()
			
	if type == "fake_border":
		Data.changeByInt("inventory.mined_fake_borders", 1)

func customInitResourceSprite(main_node, v : Vector2, h_frames = 4 , v_frames = 2, path : String = "res://mods-unpacked/POModder-AllYouCanMine/images/mod_resource_sheet.png"):
	main_node.res_sprite.hframes = h_frames
	main_node.res_sprite.vframes = v_frames
	main_node.res_sprite.texture = load(path)
	main_node.res_sprite.set_frame_coords(v)
	Style.init(main_node.res_sprite)
