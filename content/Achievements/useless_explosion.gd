extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "USELESS_EXPLOSION"

var cave_bomb = null
var cave_bomb_pos 

var timer : Timer
var second_timer : Timer

var delta = 0.5
var max_kill_tiles = 1
var min_kill_tiles = 1
var previous_tile_count = 0

func _ready():
	if get_parent().isAchievementUnlocked(id):
		return
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = delta
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func _on_timer_timeout():
	for carryable in get_tree().get_nodes_in_group("carryable"):
		if !("untilExplosion" in carryable) :
			return
		if is_instance_valid(second_timer):
			return
		cave_bomb = carryable
		second_timer = Timer.new()
		second_timer.autostart = true
		second_timer.wait_time = 0.05
		second_timer.timeout.connect(verify_kill_count)
		add_child(second_timer)
		cave_bomb_pos = cave_bomb.global_position
		timer.stop()
		
		
func verify_kill_count():
	if is_instance_valid(cave_bomb) :
		cave_bomb_pos = cave_bomb.global_position
		previous_tile_count = StageManager.currentStage.MAP.tileData.get_remaining_mineable_tile_count()
		return
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(StageManager.currentStage.MAP):
		var kill_count = previous_tile_count - StageManager.currentStage.MAP.tileData.get_remaining_mineable_tile_count()
		if kill_count <= max_kill_tiles and kill_count >= min_kill_tiles:
			get_parent().unlockAchievement(id)
		else:
			timer.start()
			if is_instance_valid(second_timer):
				second_timer.queue_free()
