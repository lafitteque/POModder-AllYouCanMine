extends Node2D


@export var change_calue : int = 20.0

func activate():
	Data.changeByInt("monsters.waveCooldown", change_calue)
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["wave_later"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().request_queue_free()
