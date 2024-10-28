extends "res://content/achievements/Achievement_MINE_ALL.gd"

func _ready():
	Data.apply("inventory.remainingtiles", 9000)

func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		cooldown += 1.0
		var count = get_parent().tileData.get_remaining_mineable_tile_count()
		Data.apply("inventory.remainingtiles", count)
		if count == 0:
			Achievements.triggerIfOpen(id)
			queue_free()
