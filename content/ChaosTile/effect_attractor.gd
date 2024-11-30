extends Area2D

var cooldown : float = 15.0


func _ready():
	set_physics_process(false)
	
	
func activate():
	for drop in get_tree().get_nodes_in_group("drops"):
			drop.apply_central_impulse(Vector2(0, 10).rotated(randf() * TAU))
	
	set_physics_process(true)
	
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["attractor"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
func _process(delta):
	if !GameWorld.paused:
		cooldown -= delta
	if cooldown <= 0:
		get_parent().kill()
	

