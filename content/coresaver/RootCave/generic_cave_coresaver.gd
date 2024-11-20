extends "res://content/caves/Cave.gd"

	
func onRevealed():
	find_child("Amb").play()
	visible = true 
	$Sprites.visible = true
func serialize()->Dictionary:
	var data = super.serialize()
	return data
	
func deserialize(data: Dictionary):
	super.deserialize(data)

