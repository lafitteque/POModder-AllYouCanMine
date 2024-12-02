extends Tile 

var detonator = null #QLafitte Added
var destroyer = null
var chaos = null

var mod_info = {}

@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod
@onready var tile_mods = get_tree().get_nodes_in_group("tile-mods")


func serialize():
	super()
	for mod in tile_mods :
		mod.serialize(self)
	
func deserialize(data: Dictionary):
	super(data)
	
	for mod in tile_mods :
		mod.deserialize(self)
		
	if ! type in ["mega_iron", "detonator", "destroyer", "bad_relic", "glass", "fake_border", "secret_room", "chaos"]:
		return
	
	match type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(randi_range(0,1),1))
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(detonator)#QLafitte Added
			detonator.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(1,0))
		"destroyer":
			set_meta("destructable", true)
			destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(destroyer)#QLafitte Added
			destroyer.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,0))	
		"chaos": #QLafitte Added
			set_meta("destructable", true)
			chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(chaos)#QLafitte Added
			chaos.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,1))
		"bad_relic":
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(3,randi_range(0,1)))
		"glass":
			set_meta("destructable", true)
			var coreater_animation = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEater.tscn").instantiate()
			add_child(coreater_animation)
			Style.init(coreater_animation)
			coreater_animation.show()
			coreater_animation.play("main")
			res_sprite.hide()
		"fake_border":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
		"secret_room":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
	
func setType(type:String):
	if hardness == 7 and type == CONST.BORDER:
		set_meta("destructable", true)
		type = "fake_border"
		hardness = 5
	if Data.ofOr("assignment.id","") == "tinyplanet" :
		if hardness <= 4:
			hardness = 0
		
	if type in ["fake_iron","fake_water","fake_sand"]:
		print("hook")
	for mod in tile_mods :
		mod.setTypeBegin(self,type)
		
	super.setType(type)
	
	if ! (type in data_mod.TILE_ID_TO_STRING_MAP.values()):
		return
		
	var baseHealth:float = Data.of("map.tileBaseHealth")
	match type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(randi_range(0,1),1))
			baseHealth += Data.of("map.megaIronAdditionalHealth")
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(detonator)#QLafitte Added
			detonator.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(1,0))
		"destroyer":
			set_meta("destructable", true)
			destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(destroyer)#QLafitte Added
			destroyer.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,0))
		"chaos": #QLafitte Added
			set_meta("destructable", true)
			chaos = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(chaos)#QLafitte Added
			chaos.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,1))
		"bad_relic":
			set_meta("destructable", true)
			customInitResourceSprite(Vector2(3,randi_range(0,1)))
			baseHealth += Data.of("map.badRelicAdditionalHealth")
		"glass":
			set_meta("destructable", true)
			var coreater_animation = load("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/core_eater_cave/CoreEater.tscn").instantiate()
			add_child(coreater_animation)
			coreater_animation.show()
			coreater_animation.play("main")
			Style.init(coreater_animation)
			res_sprite.hide()
			baseHealth += Data.of("map.glassAdditionalHealth")
		"fake_border":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			baseHealth += Data.of("map.fakeBorderAdditionalHealth")
		"secret_room":
			set_meta("destructable", true)
			res_sprite.hide()
			res_sprite.queue_free()
			res_sprite = null
			baseHealth += Data.of("map.secretRoomAdditionalHealth")
		_ :
			for mod in tile_mods :
				baseHealth = mod.setType(self,type, baseHealth)
				if mod.set_meta_destructable(self,type) :
					set_meta("destructable", true)
	var healthMultiplier = hardnessMultiplier
	healthMultiplier *= (pow(Data.of("map.tileHealthMultiplierPerLayer"), layer))
	
	max_health = max(1, round(healthMultiplier * baseHealth))
	health = max_health 
	
	
func customInitResourceSprite(v : Vector2, h_frames = 5 , v_frames = 2, path : String = "res://mods-unpacked/POModder-AllYouCanMine/images/mod_resource_sheet.png"):
	res_sprite.hframes = h_frames
	res_sprite.vframes = v_frames
	res_sprite.texture = load(path)
	res_sprite.set_frame_coords(v)
	Style.init(self)
	
func hit(dir:Vector2, dmg:float):
	for mod in tile_mods :
		mod.hit(self,type,dir,dmg)
		
	if detonator and is_instance_valid(detonator) and  !detonator.exploded:#QLafitte Added
		detonator.explode()
	
	
	if health - dmg <= 0:
		for mod in tile_mods :
			mod.tileBreak(self,type,dir,dmg)
			
		if destroyer and is_instance_valid(destroyer) and!destroyer.exploded:#QLafitte Added
			destroyer.explode()
		
		if chaos and is_instance_valid(chaos) and !chaos.used:
			chaos.activate()
			
		if type == "fake_border":
			Data.changeByInt("inventory.mined_fake_borders", 1)
			
	super.hit(dir,dmg)
