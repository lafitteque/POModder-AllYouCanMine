extends Node2D


# Called when the node enters the scene tree for the first time.
func deserialize(tile):
	
	match tile.type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			tile.customInitResourceSprite(Vector2(randi_range(0,1),1))
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			tile.mod_info["detonator"] = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["detonator"])#QLafitte Added
			tile.mod_info["detonator"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(1,0))
		"destroyer":
			set_meta("destructable", true)
			tile.mod_info["destroyer"] = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["destroyer"])#QLafitte Added
			tile.mod_info["destroyer"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(2,0))	
		"chaos": #QLafitte Added
			set_meta("destructable", true)
			tile.mod_info["chaos"] = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["chaos"])#QLafitte Added
			tile.mod_info["chaos"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(2,1))
		"bad_relic":
			set_meta("destructable", true)
			tile.customInitResourceSprite(Vector2(3,randi_range(0,1)))
		"glass":
			set_meta("destructable", true)
			var coreater_animation = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEater.tscn").instantiate()
			tile.add_child(coreater_animation)
			Style.init(coreater_animation)
			coreater_animation.show()
			coreater_animation.play("main")
			tile.res_sprite.hide()
		"fake_border":
			set_meta("destructable", true)
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null
		"secret_room":
			set_meta("destructable", true)
			tile.res_sprite.hide()
			tile.res_sprite.queue_free()
			tile.res_sprite = null

func setMetaDestructible(tile, type):
	match tile.type :
		"mega_iron": #QLafitte Added
			return true
		"detonator": #QLafitte Added
			return true
		"destroyer":
			return true
		"chaos": #QLafitte Added
			return true
		"bad_relic":
			return true
		"glass":
			return true
		"fake_border":
			return true
		"secret_room":
			return true
			
	return false

func setTypeBegin(tile, type) -> bool:
	if tile.hardness == 7 and type == CONST.BORDER:
		tile.type = "fake_border"
		tile.hardness = 5
		return true
		
	if Data.ofOr("assignment.id","") == "tinyplanet" :
		if tile.hardness <= 4:
			tile.hardness = 0
		return false
	return false
	
func setType(tile, type, baseHealth):
	match type :
		"mega_iron": #QLafitte Added
			tile.customInitResourceSprite(Vector2(randi_range(0,1),1))
			baseHealth += Data.of("map.megaIronAdditionalHealth")
		"detonator": #QLafitte Added
			tile.mod_info["detonator"] = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["detonator"])#QLafitte Added
			tile.mod_info["detonator"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(1,0))
		"destroyer":
			tile.mod_info["destroyer"] = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["destroyer"])#QLafitte Added
			tile.mod_info["destroyer"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(2,0))
		"chaos": #QLafitte Added
			tile.mod_info["chaos"] = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(tile.mod_info["chaos"])#QLafitte Added
			tile.mod_info["chaos"].global_position = global_position#QLafitte Added
			tile.customInitResourceSprite(Vector2(2,1))
		"bad_relic":
			tile.customInitResourceSprite(Vector2(3,randi_range(0,1)))
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
	var detonator = tile.mod_info["detonator"]
	var destroyer = tile.mod_info["destroyer"]
	
	if tile.mod_info.has("detonator"):
		detonator = tile.mod_info["detonator"]
	if tile.mod_info.has("destroyer"):
		destroyer = tile.mod_info["destroyer"]
		
	if detonator and is_instance_valid(detonator) and  !detonator.exploded:#QLafitte Added
		detonator.explode()
	
	if destroyer and is_instance_valid(destroyer) and!destroyer.exploded:#QLafitte Added
			destroyer.explode()
			
			
func tileBreak(tile, type, dir, dmg):
	var chaos
	if tile.mod_info.has("chaos"):
		chaos = tile.mod_info["chaos"]
	if chaos and is_instance_valid(chaos) and !chaos.used:
			chaos.activate()
			
	if type == "fake_border":
		Data.changeByInt("inventory.mined_fake_borders", 1)