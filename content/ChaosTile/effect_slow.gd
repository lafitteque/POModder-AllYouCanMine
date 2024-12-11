extends Node2D


var activated : bool = false
var cooldown : float
var data_mod
var change_size_iterations = 10
@export var life_time : float = 40.0

	
func activate():
	cooldown = life_time
	activated = true
	Engine.time_scale = 0.75
	get_node("/root/ModLoader/POModder-Dependency").custom_achievements.update_chaos_achievement()
	
	
func _physics_process(delta):
	if !activated :
		return
	if !GameWorld.paused:
		cooldown -= delta
	if cooldown <= 0:
		Engine.time_scale = 1.0
		get_parent().request_queue_free()
