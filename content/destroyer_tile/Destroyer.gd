extends Node2D

var activated := false
var untilExplosion := 0.0
var maxUntilExplosion := 0.0
var exploded := false
#@export var explosion_scene : PackedScene

	
func explode():
	$ActivateSound.stop()
	exploded = true
	print(" Total iron : " , Data.of("inventory.floatingIron"))
	print(" Total water : " , Data.of("inventory.floatingWater"))
	print(" Total sand : " , Data.of("inventory.floatingSand"))
	await get_tree().create_timer(0.2).timeout
	for carryable in $Area2D.get_overlapping_bodies():
		if carryable is Drop and carryable.type in [CONST.IRON, CONST.SAND, CONST.WATER]:
			carryable.queue_free()
			print("destroyed one")

	print(" Total iron : " , Data.of("inventory.floatingIron"))
	print(" Total water : " , Data.of("inventory.floatingWater"))
	print(" Total sand : " , Data.of("inventory.floatingSand"))
	
	if Level.map:
		Level.map.damageTileCircleArea(global_position,  3, 100000)
	else :
		print("EXPLOSION mais pas de map")
	queue_free()

