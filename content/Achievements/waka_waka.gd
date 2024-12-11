extends Node2D
###
# Wait 5 mins after revealing the relic in Hard mode 
###

var id = "WAKA_WAKA"

func _ready():
	Data.apply("chaos.gravity_changes", 0)
	if get_parent().isAchievementUnlocked(id):
		return
	Data.listen(self,"chaos.gravity_changes")
	
func propertyChanged(property : String, old_value, new_value):
	if property == "chaos.gravity_changes" and new_value >= 2:
		get_parent().unlockAchievement(id)
		Data.unlisten(self, "chaos.gravity_changes")
