extends Node2D


@export var change_calue : int = 3

func activate():
	Data.changeByInt("inventory.iron", change_calue)
	
	get_node("/root/ModLoader/POModder-Dependency").saver.save_dict["chaos_uses"]["jackpot"] = true
	get_node("/root/ModLoader/POModder-Dependency").custom_achievements.update_chaos_achievement()
	
	get_parent().request_queue_free()
