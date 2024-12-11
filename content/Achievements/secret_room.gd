extends Node2D
###
# Break all the resources tiles from the loadout
###
var id = "SECRET_ROOM"


func _ready():
	Data.apply("inventory.mined_fake_borders",0)
	if get_parent().isAchievementUnlocked(id):
		return
	Data.listen(self,"inventory.mined_fake_borders")
	
func propertyChanged(property : String , old_value , new_value):
	if property == "inventory.mined_fake_borders" and new_value > 0:
		get_parent().unlockAchievement(id)
