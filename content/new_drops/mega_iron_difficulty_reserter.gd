extends Node2D

var cooldown = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldown -= delta
	if cooldown <= 0:
		GameWorld.additionalRunWeight -= 100
		queue_free()
