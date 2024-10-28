extends Node2D#"res://content/map/tile/Tile.gd"

#var detonator = null #QLafitte Added

#func setType(type:String):
	#super.setType(type)
	#if type == DataForMod.TILE_ID_TO_STRING_MAP.get(DataForMod.TILE_DETONATOR): #QLafitte Added
		#res_sprite.texture = load("res://content/map/border/resources_sheet.png") #QLafitte Added
		#set_meta("destructable", true)#QLafitte Added
		#initResourceSprite(Vector2(5, 2))#QLafitte Added
		#detonator = load("res://mods-unpacked/POModder-MoreGuildMissions/content/detonator_tile/Detonator.tscn").instantiate()#QLafitte Added
		#print("Detonator placé")
		#detonator.position = position#QLafitte Added
		#get_parent().add_child(detonator)#QLafitte Added
		#
#func hit(dir:Vector2, dmg:float):
	#if type == DataForMod.TILE_ID_TO_STRING_MAP.get(DataForMod.TILE_DETONATOR) and !detonator.exploded:#QLafitte Added
		#detonator.explode()
	#super.hit(dir, dmg)
