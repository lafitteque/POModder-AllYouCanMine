extends Area2D


var cooldown = 15.0

func _ready():
	set_physics_process(false)

func activate():
	gravity_direction = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP][randi_range(0,2)]
	Data.changeByInt("chaos.gravity_changes", 1)
	for drop in get_tree().get_nodes_in_group("drops"):
		drop.apply_central_impulse(Vector2(0, 20).rotated(randf() * TAU))
			
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["gravity"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	set_physics_process(true)
	
	
func _process(delta):
	if !GameWorld.paused:
		cooldown -= delta
		
	if cooldown <= 0 :
		remove_effect()

func remove_effect():
	gravity_direction = Vector2.DOWN*200
	for drop in get_tree().get_nodes_in_group("drops"):
		drop.apply_central_impulse(Vector2(0, 20).rotated(randf() * TAU))
	get_parent().kill()
	

