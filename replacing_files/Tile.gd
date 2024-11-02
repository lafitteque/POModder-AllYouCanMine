extends Tile 

var detonator = null #QLafitte Added
var destroyer = null

@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod

func setType(type:String):
	super.setType(type)
	match type :
		"mega_iron": #QLafitte Added
			set_meta("destructable", true)
			print("Tile : added ", "mega_iron")
			#customInitResourceSprite(Vector2(5, 0))
			customInitResourceSprite(Vector2(randi_range(0,1),1))
			
		"detonator": #QLafitte Added
			set_meta("destructable", true)
			print("Tile : added ", "detonator")
			#customInitResourceSprite(Vector2(5, 0))
			detonator = preload("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(detonator)#QLafitte Added
			detonator.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(1,0))
		
		"destroyer":
			set_meta("destructable", true)
			print("Tile : added ", "destroyer")
			#customInitResourceSprite(Vector2(5, 0))
			destroyer = load("res://mods-unpacked/POModder-AllYouCanMine/content/destroyer_tile/Destroyer.tscn").instantiate()#QLafitte Added
			StageManager.currentStage.MAP.add_child(destroyer)#QLafitte Added
			destroyer.global_position = global_position#QLafitte Added
			customInitResourceSprite(Vector2(2,0))		
		
		
func customInitResourceSprite(v : Vector2):
	res_sprite.hframes = 3
	res_sprite.vframes = 2
	res_sprite.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/mod_resource_sheet.png")
	res_sprite.set_frame_coords(v)
	Style.init(self)
	
func hit(dir:Vector2, dmg:float):
	if type == "detonator" and !detonator.exploded:#QLafitte Added
		detonator.explode()
	if type == "destroyer" and !destroyer.exploded:#QLafitte Added
		destroyer.explode()
	super.hit(dir,dmg)
