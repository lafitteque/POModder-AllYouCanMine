extends Node2D


@export var change_calue : int = -15.0

func activate():
	Data.changeByInt("monsters.waveCooldown", change_calue)
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver["chaos_uses"]["wave_sooner"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().kill()
	
