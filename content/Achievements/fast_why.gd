extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "FAST_WHY"
var keeper
var delta = 0.5

var distance_to_win = 1000.0
var max_speed = 30.0
var min_speed = 0.5

var total_distance = 0
var timer : Timer


func _ready():
	keeper = StageManager.currentStage.find_child("Keeper",true,false)
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	if !keeper :
		return
	var speed = keeper.velocity.length()
	if min_speed < speed and speed < max_speed and !GameWorld.pause:
		total_distance += speed*delta
	elif GameWorld.pause:
		return
	else :
		total_distance = 0
	
	if total_distance >= distance_to_win:
		get_parent().unlockAchievement(id)
		timer.queue_free()
