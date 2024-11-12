extends Node

var drop_list = []
var timer_list = []
var drop_pos_list = []

var already_spawned_list = []
var wait_time_before_bearer_appears = 3.0
var cooldown_already_spawned = 40.0
var cooldown_list = []

var probability_spawn = 0.01
var data_mod 
var shroom_cap = 25

func _ready():
	data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod
	probability_spawn = data_mod.generation_data["drop_bearer_rate"]
	
func _on_timer_timeout():
	var count_to_pop = 0

	for i in range(already_spawned_list.size()):
		cooldown_list[i] -= 5
		if cooldown_list[i] <= 0:
			count_to_pop += 1
			
	for i in range(count_to_pop):
		already_spawned_list.pop_front()
		cooldown_list.pop_front()
		
	for drop  in get_tree().get_nodes_in_group("drops"):
		if !(drop in already_spawned_list or drop in drop_list):
			drop_list.append(drop)
			drop_pos_list.append(drop.position)
			var timer: Timer = Timer.new()
			timer_list.append(timer)
			# Add it to the scene as a child of this node
			add_child(timer)
			# Configure the timer
			timer.wait_time = wait_time_before_bearer_appears 
			timer.one_shot = false 
			timer.timeout.connect(_on_timer_immobile_timeout)
			timer.start()
		
	
func _on_timer_immobile_timeout():
	var drop_pos = drop_pos_list.pop_front()
	var drop = drop_list.pop_front()
	var timer = timer_list.pop_front()
	
	if !is_instance_valid(drop) :
		timer.queue_free()
		
	elif drop_pos == drop.position and randf_range(0,1)<probability_spawn and $dropbearers.get_children().size() < shroom_cap :
		var dropbearer = preload("res://mods-unpacked/POModder-AllYouCanMine/content/drop_bearer/DropBearer.tscn").instantiate()#QLafitte Added
		dropbearer.global_position = drop.global_position + Vector2.UP*2#QLafitte Added
		$dropbearers.add_child(dropbearer)
		timer.queue_free()
		already_spawned_list.append(drop)
		cooldown_list.append(cooldown_already_spawned)
	else : 
		drop_list.append(drop)
		drop_pos_list.append(drop.position)
		timer_list.append(timer)
		
