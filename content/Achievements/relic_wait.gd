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
	if get_parent().achievements_unlocked[id]:
		return
	if Level.loadout.difficulty< -1:
		return
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	var relic_chamber = StageManager.currentStage.find_child("RelicChamber",true,false)
	if relic_chamber and relic_chamber.currentState>=2 and !GameWorld.paused:
		wait_time+= delta 
		print("wait_time : " , wait_time)
	if wait_time>=time_to_unlock:
		get_parent().unlockAchievement(id)
		timer.queue_free()
