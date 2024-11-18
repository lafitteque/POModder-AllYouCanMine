extends Node2D

var allowed_time = 15.0
var cooldown = 0.0
var id = "DOUBLE_TROUBLE"


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().achievements_unlocked[id]:
		set_physics_process(false)
		return
		
	Data.listen(self,"inventory.mega_iron_taken")
	

func propertyChanged(property : String , old_value , new_value):
	if property == "inventory.mega_iron_taken" and cooldown > 0:
		get_parent().unlockAchievement(id)
		set_physics_process(false)
	elif  property == "inventory.mega_iron_taken":
		cooldown = allowed_time

func _physics_process(delta):
	if GameWorld.paused:
		return
	cooldown = max(-1,cooldown - delta)
