extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "USELESS_EXPLOSION"

var cave_bomb = null
var cave_bomb_pos 

var timer : Timer
var second_timer 

var delta = 0.5
var max_kill_tiles = 0
var previous_tiles

@onready var map = StageManager.currentStage.MAP

func _ready():
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	print("Cherche une bombe")
	for saveable in get_tree().get_nodes_in_group("saveable"):
		if "untilExplosion" in saveable:
			cave_bomb = saveable
			var number_times 
			second_timer = Timer.new()
			second_timer.autostart = true
			second_timer.wait_time = 0.1
			second_timer.timeout.connect(verify_kill_count)
			add_child(second_timer)
			cave_bomb_pos = cave_bomb.global_position
			timer.stop()
			
func verify_kill_count():
	
	if is_instance_valid(cave_bomb) :
		cave_bomb_pos = cave_bomb.global_position
		previous_tiles = map.tileData
		return
	second_timer.queue_free()
	var kill_count = 0
	var pos = cave_bomb_pos
	for dir in [Vector2i.UP , Vector2i.RIGHT , Vector2i.DOWN , Vector2i.LEFT ]:
		var startCoord = Vector2(map.getTileCoord(pos) + dir)
		for i in range(0,30):
			var coord = startCoord + Vector2(dir * i)
			if previous_tiles.has(coord) and Data.isDestructable(previous_tiles.get(coord)):
				kill_count +=1
	if kill_count <= max_kill_tiles:
		get_parent().unlockAchievement(id)
		timer.queue_free()
	else : 
		timer.start()
	
