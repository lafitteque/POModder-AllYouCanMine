extends Node2D

var id = "ALL_ASSIGNMENTS"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("assignments completed : " , GameWorld.assignmentProgress.values().filter(func(x) : return x>0).size())
	if GameWorld.assignmentProgress.values().filter(func(x) : return x>0).size() >= 25:
		get_parent().unlockAchievement(id)
