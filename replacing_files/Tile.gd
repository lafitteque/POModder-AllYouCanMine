extends Tile 

var detonator = null #QLafitte Added


func setType(type:String):
	super.setType(type)
	
	if type == DataForMod.TILE_ID_TO_STRING_MAP.get(DataForMod.TILE_DETONATOR): #QLafitte Added
		res_sprite.hide()
		set_meta("destructable", true)
		initResourceSprite(Vector2(5, 0))
		detonator = load("res://mods-unpacked/POModder-MoreGuildMissions/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
		detonator.position = position#QLafitte Added
		get_parent().add_child(detonator)#QLafitte Added
	


func hit(dir:Vector2, dmg:float):
	if type == DataForMod.TILE_ID_TO_STRING_MAP.get(DataForMod.TILE_DETONATOR) and !detonator.exploded:#QLafitte Added
		detonator.explode()
	super.hit(dir,dmg)
