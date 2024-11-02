extends Node2D

var activated := false
var untilExplosion := 0.0
var maxUntilExplosion := 0.0
var exploded := false
#@export var explosion_scene : PackedScene


func explode():
	$ActivateSound.stop()
	exploded = true
	print("passe par explode")
	if Level.map:
		Level.map.damageTileCircleArea(global_position,  3, 100000)

	else :
		print("EXPLOSION mais pas de map")
	queue_free()
	

