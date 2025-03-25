extends Node2D

var cooldown := 0.0

var countResources : float = 0.0 
var keeperId : String
var dead = false

var maxResources : float = 40.0 # Mod Added

func _ready():
	find_child("Amb").play()
	$Sprite.play("idle")
	Data.apply(keeperId + ".excavator.fillRatio", 0.0)
	Style.init(self)

func _physics_process(delta: float) -> void:
	if dead : 
		return
		
	if GameWorld.paused:
		return
	
	if cooldown > 0.0:
		cooldown -= delta
		return
	
	if countResources >= maxResources :
		die()
		return
		
	var bods:Array = $TeleportArea.get_overlapping_bodies()
	if bods.size() > 0:
		var drop = bods.pick_random()
		if not drop.deactivated:
			countResources += 1
			Data.apply(keeperId + ".excavator.fillRatio", countResources/maxResources)
		$Sprite.play("crush")
		drop.floatToDropTarget(self)
		drop.deactivate()
		drop.noCollisions()
		drop.shrink()
		cooldown = 0.2
		
		
func die():
	dead = true
	Data.changeByInt(keeperId + ".excavator.crusherCount", 1)
	Data.apply(keeperId + ".excavator.fillRatio", 1.0)
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_sprite_animation_finished() -> void:
	if $Sprite.animation == "crush":
		$Sprite.play("idle")

func dropTarget():
	return $GravityArea.global_position

func arrived(drop):
	pass
