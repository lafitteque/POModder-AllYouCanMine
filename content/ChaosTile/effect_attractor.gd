extends Area2D

@export var life_time : float = 15.0

func activate():
	for drop in get_tree().get_nodes_in_group("drops"):
			drop.apply_central_impulse(Vector2(0, 10).rotated(randf() * TAU))
	await get_tree().create_timer(life_time).timeout
	
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["attractor"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	get_parent().kill()
	

