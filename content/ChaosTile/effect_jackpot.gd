extends Node2D


@export var change_calue : int = 3

func activate():
	Data.changeByInt("inventory.iron", change_calue)
	
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver["chaos_uses"]["jackpot"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().kill()
