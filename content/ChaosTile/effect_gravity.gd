extends Area2D

@export var life_time : float = 15.0

func activate():
	gravity_direction = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP][randi_range(0,2)]
	Data.changeByInt("chaos.gravity_changes", 1)
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["gravity"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	await get_tree().create_timer(life_time).timeout
	for drop in get_tree().get_nodes_in_group("drops"):
		drop.apply_central_impulse(Vector2(0, 20).rotated(randf() * TAU))
	get_parent().kill()
	
