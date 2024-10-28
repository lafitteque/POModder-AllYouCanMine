extends Node

var drop_list = []
var timer_list = []
var drop_pos_list = []

var already_spawned_list = []
var wait_time_before_bearer_appears = 3.0
var cooldown_already_spawned = 50.0
var cooldown_list = []

var probability_spawn = 0.01

func _ready():
	
	if Data.of("assignment.id") is String and Data.of("assignment.id") == "newmission4":
		probability_spawn = 1
	print("proba :" ,probability_spawn)
	
func _on_timer_timeout():
	var count_to_pop = 0

	for i in range(already_spawned_list.size()):
		cooldown_list[i] -= 5
		if cooldown_list[i] <= 0:
			count_to_pop += 1
			
	for i in range(count_to_pop):
		already_spawned_list.pop_front()
		cooldown_list.pop_front(
			
		)
	for drop  in get_tree().get_nodes_in_group("drops"):
		if !(drop in already_spawned_list or drop in drop_list):
			drop_list.append(drop)
			drop_pos_list.append(drop.position)
			var timer: Timer = Timer.new()
			timer_list.append(timer)
			# Add it to the scene as a child of this node
			add_child(timer)
			# Configure the timer
			timer.wait_time = wait_time_before_bearer_appears # How long we're waiting
			timer.one_shot = false # trigger once or multiple times
			# Connect its timeout signal to a function we want called
			timer.timeout.connect(_on_timer_immobile_timeout)
			# Start the timer
			timer.start()
		
	
func _on_timer_immobile_timeout():
	if !is_instance_valid(drop_list[0]) :
		drop_pos_list.pop_front()
		var drop = drop_list.pop_front()
		timer_list[0].queue_free()
		timer_list.pop_front()
	elif drop_pos_list[0] == drop_list[0].position and randf_range(0,1)<probability_spawn:
		var dropbearer = preload("res://mods-unpacked/POModder-MoreGuildMissions/content/drop_bearer/DropBearer.tscn").instantiate()#QLafitte Added
		dropbearer.global_position = drop_list[0].global_position + Vector2.UP*2#QLafitte Added
		add_child(dropbearer)
		
		drop_pos_list.pop_front()
		var drop = drop_list.pop_front()
		timer_list[0].queue_free()
		timer_list.pop_front()
		already_spawned_list.append(drop)
		cooldown_list.append(cooldown_already_spawned)
	else : 
		drop_pos_list[0] = drop_list[0].position
		drop_list.append(drop_list.pop_front())
		drop_pos_list.append(drop_pos_list.pop_front())
		timer_list.append(timer_list.pop_front())
		
