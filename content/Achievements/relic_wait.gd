extends Node2D
###
# Wait 5 mins after revealing the relic in Hard mode 
###

var id = "RELIC_WAIT"
var wait_time = 0
var time_to_unlock = 300.0
var delta = 1
var timer : Timer

func _ready():
	print(Level.loadout.difficulty)
	if Level.loadout.difficulty< -1:
		return
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	if get_tree().get_nodes_in_group("relic").size()>=1 and !GameWorld.paused:
		wait_time+= delta 
		print(wait_time)
	if wait_time>=time_to_unlock:
		get_parent().unlockAchievement(id)
		timer.queue_free()
		print("GG")
