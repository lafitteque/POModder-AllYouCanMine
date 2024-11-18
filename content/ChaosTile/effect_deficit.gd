extends Node2D


@export var change_calue : int = -2

func activate():
	if Data.ofOr("inventory.iron",0) >= -change_calue:
		Data.changeByInt("inventory.iron", change_calue)
	elif Data.ofOr("inventory.iron",0) <= -change_calue:
		Data.changeByInt("inventory.iron", Data.ofOr("inventory.iron",0))
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["deficit"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	
	get_parent().kill()
	

