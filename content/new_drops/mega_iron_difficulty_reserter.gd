extends Node2D

var cooldown = 30
var removed = false
var fight_modifier = 110

func _ready():
	GameWorld.additionalRunWeight += fight_modifier
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldown -= delta
	if cooldown <= 0:
		GameWorld.additionalRunWeight -= fight_modifier
		queue_free()
		removed = true
func _exit_tree():
	if ! removed :
		GameWorld.additionalRunWeight -= fight_modifier
