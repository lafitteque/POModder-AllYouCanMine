extends Node2D

var cooldown = 1.0
var tile_data : MapData
var data_mod

func _ready():
	tile_data = StageManager.currentStage.MAP.tileData
	data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod 
	Data.apply("inventory.remainingtiles", 9000)
	Data.apply("inventory.remaining_core_eaters", 4)
	Data.apply("inventory.mined_fake_borders", 0)
	Data.apply("inventory.mega_iron_taken", 0)
	
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	elif is_instance_valid(tile_data):
		cooldown += 1.0
		var count = tile_data.get_remaining_mineable_tile_count()
		Data.apply("inventory.remainingtiles", count)
		Data.apply("inventory.remaining_core_eaters", tile_data.get_resource_cells_by_id(data_mod.TILE_GLASS).size() )
		if count == 0:
			queue_free()
	else :
		tile_data = StageManager.currentStage.MAP.tileData
