extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "SECRET_ROOM"


func _ready():
	Data.listen(self,"inventory.mined_fake_borders")
	
func propertyChanged(property, oldValue, newValue):
	if property == "inventory.mined_fake_borders" and newValue > 0:
		get_parent().unlockAchievement(id)
