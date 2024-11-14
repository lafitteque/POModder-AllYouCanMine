extends Node2D

var allowed_time = 15.0
var cooldown = 0.0
var id = "DOUBLE_TROUBLE"


# Called when the node enters the scene tree for the first time.
func _ready():
	Data.listen(self,"inventory.mega_iron_taken")


func PropertyChange(property : String , new_value, old_value):
	if property == "inventory.mega_iron_taken" and cooldown > 0:
		get_parent().unlockAchievement(id)
	elif  property == "inventory.mega_iron_taken":
		cooldown = allowed_time

func _physics_process(delta):
	if GameWorld.paused:
		return
	cooldown = max(-1,cooldown - delta)
