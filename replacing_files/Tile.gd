extends Tile 

var detonator = null #QLafitte Added
@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod

func setType(type:String):
	super.setType(type)
	print(type)
	if type == data_mod.TILE_ID_TO_STRING_MAP.get(data_mod.TILE_DETONATOR): #QLafitte Added
		res_sprite.hide()
		set_meta("destructable", true)
		initResourceSprite(Vector2(5, 0))
		detonator = load("res://mods-unpacked/POModder-AllYouCanMine/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
		detonator.position = position#QLafitte Added
		get_parent().add_child(detonator)#QLafitte Added
		print("detonator découvert")
	


func hit(dir:Vector2, dmg:float):
	if type == DataForMod.TILE_ID_TO_STRING_MAP.get(DataForMod.TILE_DETONATOR) and !detonator.exploded:#QLafitte Added
		detonator.explode()
	super.hit(dir,dmg)
