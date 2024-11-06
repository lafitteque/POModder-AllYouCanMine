extends "res://content/caves/Cave.gd"

func onRevealed():
	find_child("Amb").play()
	var heavy_rock = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/heavy_rock_cave/heavy_rock_drop.tscn").instantiate()
	StageManager.currentStage.MAP.add_child(heavy_rock)
	heavy_rock.global_position = $Marker2D.global_position
	
func serialize()->Dictionary:
	var data = super.serialize()
	return data
	
func deserialize(data: Dictionary):
	super.deserialize(data)

