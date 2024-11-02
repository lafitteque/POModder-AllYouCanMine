extends  Drop

var iron_value = 5

func shrink():
	if absorbed:
		return
	
	if dropTargetRef:
		dropTargetPosition = dropTargetRef.dropTarget()
		dropTargetRef = null
	
	absorbed = true
	var outDuration := 0.6
	linear_damp = 13 #so drop won't move a lot while being shredded
	
	if shrinkTween:
		shrinkTween.kill()
	shrinkTween = create_tween()
	shrinkTween.set_parallel().tween_property($Sprite2D, "scale", Vector2.ZERO, outDuration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	shrinkTween.tween_property(self, "position", dropTargetPosition, outDuration - 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	shrinkTween.tween_callback(Data.changeByInt.bind("inventory." + type, iron_value)).set_delay(outDuration*0.6)
	shrinkTween.tween_callback(queue_free).set_delay(outDuration)
	Data.changeByInt("inventory.floating" + type, -1)
	
	if is_in_group("saveable"):
		remove_from_group("saveable")


func shred(addToInventory := true):
	if absorbed:
		return
	
	if dropTargetRef:
		dropTargetPosition = dropTargetRef.dropTarget()
		dropTargetRef = null
	
	absorbed = true
	var outDuration := 0.6
	var particle_lifetime = 0
	linear_damp = 13 #so drop won't move a lot while being shredded
	
	if shredTween:
		shredTween.kill()
	shredTween = create_tween()
	if has_node("ShredParticles"):
		for child in get_node("ShredParticles").get_children():
			particle_lifetime = max(particle_lifetime, child.lifetime)
			child.emitting = true
			shredTween.tween_callback(child.set_emitting.bind(false)).set_delay(outDuration)
		shredTween.set_parallel().tween_property($Sprite2D, "modulate:a", 0, outDuration)
	else:
		shredTween.set_parallel().tween_property($Sprite2D, "scale", Vector2.ZERO, outDuration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if addToInventory:
		shredTween.tween_callback(Data.changeByInt.bind("inventory." + type, iron_value)).set_delay(outDuration*0.6)
	Data.changeByInt("inventory.floating" + type, -1)
	
	# Adding particle_lifetime so the particles get time to finish their thing
	shredTween.tween_callback(queue_free).set_delay(outDuration + particle_lifetime)
	
	if is_in_group("saveable"):
		remove_from_group("saveable")

func _exit_tree():
	Data.apply("monsters.waveCooldown", 0)
	GameWorld.additionalRunWeight += 100
	get_parent().add_child(preload("res://mods-unpacked/POModder-AllYouCanMine/content/new_drops/mega_iron_difficulty_reserter.tscn").instantiate())
	
