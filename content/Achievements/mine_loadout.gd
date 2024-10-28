extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "MINE_LOADOUT"
var tile_data : MapData
var timer : Timer
var delta = 1

func _ready():
	tile_data = StageManager.currentStage.find_child("MapData",true,false)
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	if !tile_data :
		tile_data = StageManager.currentStage.find_child("MapData",true,false)
		return
	if tile_data.get_resource_cells_by_id(0).size() +\
	tile_data.get_resource_cells_by_id(1).size()+\
	tile_data.get_resource_cells_by_id(2).size() ==0  :
		get_parent().unlockAchievement(id)
		timer.queue_free()
