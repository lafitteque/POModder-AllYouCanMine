extends "res://content/map/chamber/Chamber.gd"

func _ready():
	super._ready()
	var variant = randi() % 10
	$hint.frame = variant
	$hint.visible = false
	
func serialize()->Dictionary:
	var data = super.serialize()
	data["variant"] = $hint.frame
	return data
	
func deserialize(data: Dictionary):
	super.deserialize(data)
	var variant = data["variant"]

func onExcavated():
	$hint.visible = true


func getTileType() -> int:
	return Data.TILE_DIRT_START
