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
		
	get_node("/root/ModLoader/POModder-AllYouCanMine").saver.save_dict["chaos_uses"]["earthquake"] = true
	get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.update_chaos_achievement()
	
	
func _physics_process(delta):
	if !activated :
		return
	
	cooldown -= delta
	if cooldown <= 0:
		get_parent().kill()


func _on_timer_timeout():
	for drop in get_tree().get_nodes_in_group("drops"):
		drop.apply_central_impulse(Vector2(0, 120).rotated(randf() * TAU))#QLafitte Added
