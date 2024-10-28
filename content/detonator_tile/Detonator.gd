extends Node2D

var activated := false
var untilExplosion := 0.0
var maxUntilExplosion := 0.0
var exploded := false
#@export var explosion_scene : PackedScene

func _ready():
	Style.init($Sprite2D)
#func _physics_process(delta):
	#if untilExplosion > 0.0:
		#untilExplosion -= delta
		#$CountdownSound.play()
	#else:
		#explode()

func explode():
	$ActivateSound.stop()
	exploded = true
	if Level.map:
		print("EXPLOSION")		
		Level.map.damageTileCircleArea(global_position,  3, 100000)
		#var ex = explosion_scene.instantiate()
		#ex.position = position + dir * GameWorld.TILE_SIZE * 0.75
		#get_parent().add_child(ex)
	else :
		print("EXPLOSION mais pas de map :(")
	queue_free()
	
#func load_scene(path, parent : Node) -> Node:
	#var result : Node = null
	#if ResourceLoader.exists(path) :
		#result = ResourceLoader.load(path).instance()
	#if result :
		#parent.add_child(result)
	#return result
