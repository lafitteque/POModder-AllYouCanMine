extends Node2D

var cooldown = 1.5
@onready var tile_data = StageManager.currentStage.MAP.tileData

func _ready():
	Data.apply("inventory.remainingtiles", 9000)
	
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	elif is_instance_valid(tile_data):
		cooldown += 1.0
		var count = tile_data.get_remaining_mineable_tile_count()
		Data.apply("inventory.remainingtiles", count)
		if count == 0:
			queue_free()
