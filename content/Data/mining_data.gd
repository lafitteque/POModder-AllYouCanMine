extends Node2D

var cooldown = 1.0
var tile_data : MapData
var data_mod

var debt_timer
var debt_cooldown
var debt 


func _ready():
	tile_data = StageManager.currentStage.MAP.tileData
	data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod 
	Data.apply("inventory.remainingtiles", 9000)
	Data.apply("inventory.remaining_core_eaters", 4)
	Data.apply("inventory.mined_fake_borders", 0)
	Data.apply("inventory.mega_iron_taken", 0)
	Data.apply("game.time", floor(GameWorld.runTime))
	
	debt = Data.ofOr("game.debt", 0) 
	debt_cooldown = Data.ofOr("game.debtcooldown", 99)
	debt_timer = debt_cooldown 
	if debt > 0:
		Data.listen(self, "inventory.iron")
	
	Data.listen(self, "game.over")
		
func _process(delta):
	if StageManager.currentStage.name != "LevelStage":
		queue_free()
	elif cooldown > 0.0:
		cooldown -= delta
	elif is_instance_valid(tile_data):
		cooldown += 1.0
		var count = tile_data.get_remaining_mineable_tile_count()
		Data.apply("inventory.remainingtiles", count)
		Data.apply("inventory.remaining_core_eaters", tile_data.get_resource_cells_by_id(data_mod.TILE_GLASS).size() )
		Data.apply("game.time", floor(GameWorld.runTime))
		if count == 0:
			queue_free()
	elif StageManager.currentStage.name == "LevelStage":
		tile_data = StageManager.currentStage.MAP.tileData
		
	if debt > 0 and !GameWorld.paused:
		debt_timer -= delta
		if debt_timer < 0.0 :
			debt_timer = debt_cooldown
			Data.changeByInt("inventory.iron", -debt)
	
func propertyChanged(property : String, old_value, new_value):
	if debt > 0 and property == "inventory.iron" and new_value <= 0:
		var assignments = StageManager.currentStage.find_child("Assignments",true,false)
		assignments.handlePropertyGoalGameEnd()
	if property == "game.over" and new_value in ["won", "lost"]:
		self.queue_free()
