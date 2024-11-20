extends Node2D


@export var change_calue : int = -15.0

func activate():
	var current_cooldown = Data.of("monsters.waveCooldown")
	Data.apply("monsters.waveCooldown", min(10, current_cooldown + change_calue))
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["wave_sooner"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().kill()
	
