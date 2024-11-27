extends Node2D


@export var change_value : int = -15.0

func activate():
	var current_cooldown = Data.of("monsters.waveCooldown")
	
	print("avant : ", current_cooldown )
	var new_time = current_cooldown + change_value
	if current_cooldown <= 20 and current_cooldown >= 10 :
		new_time = 10
	elif current_cooldown < 10:
		new_time = current_cooldown
		
	Data.apply("monsters.waveCooldown", new_time)
	
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["wave_sooner"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().kill()
	
