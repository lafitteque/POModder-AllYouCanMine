extends Node2D

var activated : bool = false
var cooldown : float
var data_mod

@export var life_time : float = 25.0

func _ready():
	$Timer.start()
	$Timer.autostart = true
	
func activate():
	cooldown = life_time
	activated = true
		
	get_node("/root/ModLoader/POModder-Dependency").saver.save_dict["chaos_uses"]["earthquake"] = true
	get_node("/root/ModLoader/POModder-Dependency").custom_achievements.update_chaos_achievement()
	
	
func _physics_process(delta):
	if !activated :
		return
	
	if !GameWorld.paused:
		cooldown -= delta
	if cooldown <= 0:
		for drop in get_tree().get_nodes_in_group("drops"):
			drop.apply_central_impulse(Vector2(0, 20).rotated(randf() * TAU))
		get_parent().request_queue_free()


func _on_timer_timeout():
	if GameWorld.paused:
		return
	for drop in get_tree().get_nodes_in_group("drops"):
		drop.apply_central_impulse(Vector2(0, 120).rotated(randf() * TAU))#QLafitte Added
