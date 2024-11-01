extends Node2D

var game_mode :String
var difficulty : int
var game_duration : float
var inventory : Dictionary
var relic_retrieved : bool


func clear():
	game_mode = ""
	game_duration = 0.0
	inventory = {"iron" : 0,"water" : 0 ,"sand" : 0, "remaining_tiles" : 9999}
	




func _on_timer_timeout():
	game_mode = Level.mode.name
	difficulty = Level.difficulty()
	game_duration = Level.dura
	
	
