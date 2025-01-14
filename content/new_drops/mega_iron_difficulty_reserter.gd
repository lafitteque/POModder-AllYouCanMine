extends Node2D

var fight_modifier = 130
var activated = false


func _ready():
	# if not in battle, apply effect 
	if ! Data.ofOr("monsters.wavebattle", false):
		GameWorld.additionalRunWeight += fight_modifier
		activated = true
	Data.listen(self,"monsters.wavebattle")
	Data.listen(self,"game.over")
		
func propertyChanged(property : String, old_value, new_value):
	if property == "monsters.wavebattle":
		# if battle ended, use effect for next battle
		if !new_value and !activated:
			GameWorld.additionalRunWeight += fight_modifier
			activated = true

		elif !new_value and activated:
			GameWorld.additionalRunWeight -= fight_modifier
			queue_free()
	elif property == "game.over":
		GameWorld.additionalRunWeight -= fight_modifier
		queue_free()
		
