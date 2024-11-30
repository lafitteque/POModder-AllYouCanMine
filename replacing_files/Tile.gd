extends Tile 

var detonator = null #QLafitte Added
var destroyer = null
var chaos = null

@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod

func deserialize(data: Dictionary):
	super(data)
	
	if ! type in ["mega_iron", "detonator", "destroyer", "bad_relic", "glass", "fake_border", "secret_room", "chaos"]:
		return
	
	match type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(randi_range(0,1),1))
			$AnimatedSprite2D.queue_free()
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(detonator)#QLafitte Added
			detonator.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(1,0))
			$AnimatedSprite2D.queue_free()
		"destroyer":
			set_meta("destructable", true)
			destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(destroyer)#QLafitte Added
			destroyer.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,0))	
			$AnimatedSprite2D.queue_free()	
		"chaos": #QLafitte Added
			set_meta("destructable", true)
			chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(chaos)#QLafitte Added
			chaos.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,1))
			$AnimatedSprite2D.queue_free()
		"bad_relic":
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(3,randi_range(0,1)))
			$AnimatedSprite2D.queue_free()
		"glass":
			set_meta("destructable", true)
			play_animation()
		"fake_border":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			$AnimatedSprite2D.queue_free()
		"secret_room":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			$AnimatedSprite2D.queue_free()
		_ :
			$AnimatedSprite2D.queue_free()
	
func setType(type:String):
	if hardness == 7 and type == CONST.BORDER:
		set_meta("destructable", true)
		type = "fake_border"
		hardness = 5
	if Data.ofOr("assignment.id","") == "tinyplanet" :
		if hardness <= 4:
			hardness = 0
	super.setType(type)
	
	if ! type in ["mega_iron", "detonator", "destroyer", "bad_relic", "glass", "fake_border", "secret_room", "chaos"]:
		return
		
	var baseHealth:float = Data.of("map.tileBaseHealth")
	match type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(randi_range(0,1),1))
			baseHealth += Data.of("map.megaIronAdditionalHealth")
			$AnimatedSprite2D.queue_free()
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(detonator)#QLafitte Added
			detonator.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(1,0))
			$AnimatedSprite2D.queue_free()
		"destroyer":
			set_meta("destructable", true)
			destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(destroyer)#QLafitte Added
			destroyer.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,0))	
			$AnimatedSprite2D.queue_free()	
		"chaos": #QLafitte Added
			set_meta("destructable", true)
			chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(chaos)#QLafitte Added
			chaos.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,1))
			$AnimatedSprite2D.queue_free()
		"bad_relic":
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(3,randi_range(0,1)))
			baseHealth += Data.of("map.badRelicAdditionalHealth")
			$AnimatedSprite2D.queue_free()
		"glass":
			set_meta("destructable", true)
			play_animation()
			baseHealth += Data.of("map.glassAdditionalHealth")
		"fake_border":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			baseHealth += Data.of("map.fakeBorderAdditionalHealth")
			$AnimatedSprite2D.queue_free()
		"secret_room":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			baseHealth += Data.of("map.secretRoomAdditionalHealth")
			$AnimatedSprite2D.queue_free()
		_ :
			$AnimatedSprite2D.queue_free()
	
	var healthMultiplier = hardnessMultiplier
	healthMultiplier *= (pow(Data.of("map.tileHealthMultiplierPerLayer"), layer))
	
	max_health = max(1, round(healthMultiplier * baseHealth))
	health = max_health 
	
func play_animation():
	Style.init($AnimatedSprite2D)
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("main")
	res_sprite.hide()
	
	
func customInitResourceSprite(v : Vector2):
	res_sprite.hframes = 5
	res_sprite.vframes = 2
	res_sprite.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/mod_resource_sheet.png")
	res_sprite.set_frame_coords(v)
	Style.init(self)
	
func hit(dir:Vector2, dmg:float):
	if detonator and is_instance_valid(detonator) and  !detonator.exploded:#QLafitte Added
		detonator.explode()
	
	
	if health - dmg <= 0:
		if destroyer and is_instance_valid(destroyer) and!destroyer.exploded:#QLafitte Added
			destroyer.explode()
		
		if chaos and is_instance_valid(chaos) and !chaos.used:
			chaos.activate()
			
		if type == "fake_border":
			Data.changeByInt("inventory.mined_fake_borders", 1)
			
	super.hit(dir,dmg)
