extends Node2D

var activated := false
var untilExplosion := 0.0
var maxUntilExplosion := 0.0
var exploded := false
#@export var explosion_scene : PackedScene

	
func explode():
	$ActivateSound.stop()
	exploded = true
	for carryable in $Area2D.get_overlapping_bodies():
		if carryable is Drop and carryable.type in [CONST.IRON, CONST.SAND, CONST.WATER, CONST.PACK]:
			for carrier in carryable.carriedBy:
				carrier.dropCarry(carryable)
					
			if carryable.carriedBy.size() == 0:
				carryable.queue_free()
	await get_tree().create_timer(0.1).timeout
	if Level.map:
		Level.map.damageTileCircleArea(global_position,  3, 100000)
	queue_free()

