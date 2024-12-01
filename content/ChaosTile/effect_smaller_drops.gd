extends Node2D


var activated : bool = false
var cooldown : float
var data_mod
var change_size_iterations = 10
@export var life_time : float = 40.0

	
func activate():
	cooldown = life_time
	activated = true
	for drop in get_tree().get_nodes_in_group("drops"):
		 #and drop.type in data_mod.ALL_DROP_NAMES :#QLafitte Added
		for child in drop.get_children():
			if "scale" in child:
				child.scale = Vector2(0.5,0.5)
		drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["smaller_drops"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	
func _physics_process(delta):
	if !activated :
		return
	if !GameWorld.paused:
		cooldown -= delta
	if cooldown <= 0:
		for drop in get_tree().get_nodes_in_group("drops"):
			#if drop.get_colliding_bodies().filter(func(x): return x is Drop).size()>0:
				#continue
			for child in drop.get_children():
				if "scale" in child:
					child.scale.x = min(0.1+ child.scale.x , 1)
					child.scale.y = child.scale.x
		change_size_iterations -= 1
		if change_size_iterations < 0:
			await get_tree().create_timer(0.1).timeout
			for drop in get_tree().get_nodes_in_group("drops"):
				drop.apply_central_impulse(Vector2(0, 40).rotated(randf() * TAU))
			get_parent().request_queue_free()
