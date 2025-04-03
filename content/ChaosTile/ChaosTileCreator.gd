extends Node2D

var  chaosTile
var tile_child_type = "chaos"
var used = false

func _ready():
	chaosTile = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/ChaosTile.tscn").instantiate()
	Level.map.add_child(chaosTile)
	chaosTile.global_position = global_position
	
func activate():
	if used : 
		return
	chaosTile.activate()
	used = true
