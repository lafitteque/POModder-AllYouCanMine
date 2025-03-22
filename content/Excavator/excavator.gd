extends Keeper

signal tileHit

@onready var DrillSprite = $DrillSprite
@onready var DrillHitTestRay = $DrillHitTestRay
@onready var BoomHitTestRay = $BoomHitTestRay

@export var simulatedCarrySlowdown := false

var knockbackDirection := Vector2()
var moveSlowdown := 0.0
var hitCooldown := 0.0
var spriteLockDuration := 0.0
var moveStopSoundPlayBuffer := 0.0 # we don't want the jetpack on(off sounds to play too much, so wait a few frames before playing them
var moveStartSoundPlayBuffer := 0.0
const maxCarryLineLength := 150.0

var carryLines := {}

var action_hint_drop :=-1
var action_hint_pickup :=-1
var action_hint_cancel_disable := -1
var action_hint_interact := -1


### Modded variables
var falling := false
var fallingDistance := 0.0
var boomCooldown = 0.0

func init():
	super.init()
	Data.listen(self, playerId + ".excavator.jetpackStage")
	
	$Sprite2D.frame = 0
	focussedUsable = null
	focussedCarryable = null
	hitCooldown = 0.0
	boomCooldown = 0.0
	
	$DrillHit.frame = 4
	
	Style.init(self)

	await StageManager.stage_started


var speedLabel : Label
func _ready():
	speedLabel = Label.new()
	add_child(speedLabel)
	speedLabel.position += Vector2.UP*20
	
	

func _physics_process(delta):
	
	
	super._physics_process(delta)
	for t in carryLines:
		var line = carryLines[t]
		line.set_point_position(0, global_position)
		line.set_point_position(1, t.global_position)
	
	update_action_hints()
	
	if isInsideStation or GameWorld.paused or disabled:
		$MoveSound.stop()
		$CarryLoadSound.stop()
		pullCarry()
		return
	
	moveSlowdown *= 1.0 - delta * Data.of(playerId + ".excavator.slowdownRecovery")  * 1.0
	
	
	
	var baseAcceleration : Vector2 = Vector2.ZERO
	var boost = Data.ofOr(playerId + ".keeper.speedBuff", 0) * (moveDirectionInput.normalized())
	
	baseAcceleration.x  = Data.of(playerId + ".excavator.maxSpeed")
	baseAcceleration.x += boost.x
	
	if moveDirectionInput.y <= 0 :
		baseAcceleration.y = -Data.of(playerId + ".excavator.maxUpSpeed") 
	else:
		baseAcceleration.y = Data.of(playerId + ".excavator.maxDownSpeed")
		
	var yMove = move.normalized().y
	baseAcceleration.y += Data.ofOr(playerId + ".keeper.additionalupwardsspeed", 0) * abs(yMove)
	
	var acceleration:Vector2 = Vector2(moveDirectionInput.x * baseAcceleration.x , abs(moveDirectionInput.y) * baseAcceleration.y)
	
	speedLabel.text = str(acceleration)
	
	# Falling
	acceleration.y += Data.of(playerId + ".excavator.gravity") 
	
	# Limit horizontal inertia
	if sign(move.x) != sign(moveDirectionInput.x): 
		move.x = max(-80.0 , min(move.x , 80.0))
			
	# Boost when high down speed
	elif move.y >= 50.0 and moveDirectionInput.y <= 0:
		acceleration.y -= Data.of(playerId + ".excavator.boostupIntensity")
	
	speedLabel.text = speedLabel.text + str(acceleration)
	# If an axis is way greater than the other one, re-align with this axis
	if abs(moveDirectionInput.x) < 0.1 and abs(moveDirectionInput.y) > 0.9:
		move.x *= 1 - delta * Data.of(playerId + ".excavator.deceleration")
	if abs(moveDirectionInput.y) < 0.1 and abs(moveDirectionInput.x) > 0.9:
		move.y *= 1 - delta *  Data.of(playerId + ".excavator.deceleration")
	
	var speedChange = acceleration * delta 
	move +=  speedChange
	
	updateCarry()
	pullCarry()
	
	if externallyMoved:
		move *= 0
		moveDirectionInput *= 0
	
	
	
	#move.y = min(max(move.y, -Data.of(playerId + ".excavator.maxUpSpeed")), Data.of(playerId + ".excavator.maxDownSpeed"))
	#move.x = min(max(move.x, -Data.of(playerId + ".excavator.maxSpeed")), Data.of(playerId + ".excavator.maxSpeed"))
	
	if $CollisionDown.is_colliding():
		move.y = min(20, move.y)
	elif $CollisionUp.is_colliding():
		move.y = max(-20.0, move.y)	
	
	var actualMove = position 
	set_velocity(move)
	#fix for gd4 changes to move and slide
	move_and_slide_custom()
	actualMove = position - actualMove
		
	
	
	GameWorld.travelledDistance += actualMove.length()

	# reduce the hit cooldown
	if hitCooldown > 0:
		hitCooldown = max(hitCooldown - delta, 0)
	if boomCooldown > 0:
		boomCooldown = max(boomCooldown - delta, 0)
	
	# if the keeper is moving and the hit cooldown is at 0, check for possible hits
	if abs(move.y) < Data.of(playerId + ".excavator.minBoomSpeed") and hitCooldown <= 0:
		drill_check()
	elif boomCooldown <= 0 :
		boom_check()
		
	if $CarryLoadSound.playing:
		$CarryLoadSound.volume_db = min(-2, -30 + carriedCarryables.size()*50)
	
	var speedBuff = Data.of(playerId + ".keeper.speedBuff")
	var drillBuff = Data.of(playerId + ".keeper.drillBuff")
	if speedBuff > 0 or drillBuff > 0:
		animationSuffix = "_buffed" if playerId == "player1" else ""
	else:
		animationSuffix = "_buffed" if playerId == "player2" else ""
	
	$Trail.emitting = moveDirectionInput.length() > 0 and hitCooldown <= 0.0 and spriteLockDuration <= 0.0
	$Trail.direction = -moveDirectionInput
	
	if spriteLockDuration > 0.0:
		spriteLockDuration -= delta
	else:
		var combinedMove = moveDirectionInput
		if actualMove.length() > 0.15:
			combinedMove += actualMove
		$DrillSprite.hide()
		$DrillSprite.stop()
		if combinedMove.length() < 0.35:
			$Sprite2D.play("default"+animationSuffix)
		else:
			if abs(combinedMove.x) > abs(combinedMove.y) * 0.95:
				$Sprite2D.play("left"+animationSuffix if combinedMove.x < 0 else "right"+animationSuffix)
			else:
				$Sprite2D.play("up"+animationSuffix if combinedMove.y < 0 else "down"+animationSuffix)
		if moveDirectionInput.length() == 0:
			moveStartSoundPlayBuffer = 0
			if $MoveSound.shouldPlay:
				moveStopSoundPlayBuffer += delta
				if moveStopSoundPlayBuffer >= 0.2:
					$MoveSound.stop()
					$CarryLoadSound.stop()
					$MoveStopSound.play()
					$StillSound.play()
					moveStopSoundPlayBuffer = 0
		else:
			moveStopSoundPlayBuffer = 0
			if not $MoveSound.shouldPlay:
				moveStartSoundPlayBuffer += delta
				if moveStartSoundPlayBuffer >= 0.1:
					$MoveSound.play()
					$CarryLoadSound.play()
					$MoveStartSound.play()
					$StillSound.stop()
					moveStartSoundPlayBuffer = 0
	
	# because there is no notification about usables becoming focussable, this runs every loop
	# otherwise there would be problems with drops and stations, like in the cellar
	updateInteractables()

func update_action_hints():
	pass
	
func updateCarry():
	var longest = 0
	for c in carriedCarryables.duplicate():
		if c.independent:
			dropCarry(c)
		else:
			var d = (position - c.position).length()
			if d > longest:
				longest = d
			if d > maxCarryLineLength:
				dropCarry(c)
				$CarryLineBreak.play()

	var breakThreshold = 0.7
	if longest > breakThreshold * maxCarryLineLength:
		if not $CarryLineStretch.playing:
			$CarryLineStretch.play()
		var pitch = (longest - breakThreshold * maxCarryLineLength) / ((1.0-breakThreshold) * maxCarryLineLength)
		$CarryLineStretch.pitch_scale = 1 + ease(pitch, 0.6)
	else:
		$CarryLineStretch.stop()

func pullCarry():
	var strength := 0.27
	for c in carriedCarryables:
		var dist = position - c.position
		# keep a minimal distance
		if dist.length() < 12.0:
			dist *= 0.0
		else:
			dist -= dist.normalized() * 12
		if dist.y < 0:
			dist.y -= 2.0 * pow(1.0 + dist.length() / maxCarryLineLength, 4)
		
		var factor := 1.0
		var off = dist.length() - 0.15 * maxCarryLineLength
		if off > 0:
			var fill = abs(off / (0.8 * maxCarryLineLength))
			if randf() < fill:
				factor = 10.0 * fill
		var impulse = (dist * strength * factor).limit_length(100)
		c.apply_central_impulse(impulse)
		strength = max(strength * 0.90, 0.005)

func attachCarry(body):
	if carriedCarryables.has(body):
		Logger.error("Tried to attach carryable " + body.name + "although it's already carried ")
		return
	elif carriedCarryables.size() >= Data.of(playerId + ".excavator.maxCarry"):
		return
		
	body.unfocusCarry(self)
	body.dissolveCarryInfluence()
	var po = CarryablePhysicsOverride.new(self)
	po.linear_damp = 2
	po.angular_damp = 2
	body.addPhysicsOverride(po)
	carriedCarryables.append(body)
	body.setCarriedBy(self)
	$Pickup.play()
	
	var carryLine = preload("res://content/keeper/Carryline.tscn").instantiate()
	carryLine.add_point(position)
	carryLine.add_point(body.position)
	get_parent().add_child(carryLine)
	carryLines[body] = carryLine
	Style.init(carryLine)
	
	if not $CarryLine.playing:
		$CarryLine.play()

func dropCarry(body):
	if not carriedCarryables.has(body):
		Logger.error("keeper wants to drop carryable that isn't carried", "Keeper.dropCarry", {"carryable":body.name, "carry":str(carriedCarryables)})
		return
	carriedCarryables.erase(body)
	body.freeCarry(self)
	$Drop.play()
	
	# Break carryline
	var brk = Data.CARRYLINE_BREAK.instantiate()
	brk.global_position = global_position
	brk.target = body.global_position
	get_parent().add_child(brk)
	
	# Delete the carryline
	carryLines[body].queue_free()
	carryLines.erase(body)

	if carryLines.size() == 0:
		$CarryLine.stop()

func updateCarryables():
	if not is_instance_valid(focussedCarryable):
		focussedCarryable = null
	
	if focussedCarryable:
		if not focussedCarryable.canFocusCarry()\
			or not carryables.has(focussedCarryable)\
			or carriedCarryables.has(focussedCarryable)\
			or (focussedCarryable.is_in_group("usables") and not usables.has(focussedCarryable.get_meta("usable"))):
			focussedCarryable.unfocusCarry(self)
			focussedCarryable = null
	
	# set new carryable. First collect the ones that can be carried
	var potentialCarryables := []
	for carryable in carryables:
		if not is_instance_valid(carryable):
			continue
		
		if not carriedCarryables.has(carryable)\
			and carryable.canFocusCarry()\
			and (pickupType == "" or pickupType == carryable.carryableType)\
			and (not carryable.is_in_group("usables") or usables.has(carryable.get_meta("usable"))):
				# carry radius is larger, but usables shouldn't switch mode so secretive
				potentialCarryables.append(carryable)
	
	potentialCarryables.sort_custom(Callable(self, "sortByDistance"))
	
	# prioritize carryables that are not already being moved (lift, drones, ...)
	for carryable in potentialCarryables:
		if focussedCarryable == carryable:
			return
		else:
			if focussedCarryable:
				focussedCarryable.unfocusCarry(self)
			focussedCarryable = carryable
			focussedCarryable.focusCarry(self)
		return

func pickupHit():
	if isInsideStation or disabled:
		return false
	
	updateCarryables()
	if focussedCarryable:
		pickup(focussedCarryable)

func pickupHold():
	if isInsideStation or disabled:
		return false
	
	updateCarryables()
	if focussedCarryable:
		pickup(focussedCarryable)
		pickupType = focussedCarryable.carryableType

func pickupHoldStopped():
	pickupType = ""

func dropHit():
	if isInsideStation or disabled:
		return
	
	var farthestDrop
	var distance := 0.0
	for c in carriedCarryables:
		var dist = (c.global_position - global_position).length()
		if dist > distance:
			distance = dist
			farthestDrop = c
	if farthestDrop:
		dropCarry(farthestDrop)
		return true

func dropHold():
	if isInsideStation or disabled:
		return

	if carriedCarryables.size() > 0:
		var drop = carriedCarryables.front()
		dropCarry(drop)

func pickup(drop):
	attachCarry(drop)

func currentSpeed() -> float:
	var s = Data.of(playerId + ".excavator.maxSpeed")
	s += Data.ofOr(playerId + ".keeper.speedBuff", 0)
	var yMove = move.normalized().y
	s += Data.ofOr(playerId + ".keeper.additionalupwardsspeed", 0) * abs(yMove)
	return s

func drill_check()->void:
	DrillHitTestRay.target_position = sign(moveDirectionInput.x) * Vector2(11,0)
#	force raycast update, as otherwise we might get a drill collision while already moving in an other direction
	DrillHitTestRay.force_raycast_update()
	var tile = DrillHitTestRay.get_collider()
	
	if not tile or not tile.has_meta("destructable"):
		return
	if not tile.get_meta("destructable"):
		if Data.of(playerId + ".excavator.destroyindestructibletiles"):
			if not Level.map.isWithinBounds(tile.coord):
				return 
		else:
			return
	
	var dir = global_position - tile.global_position
	var drillStrength = Data.of(playerId + ".excavator.drillStrength")
	if tile.hardness >= 3:
		var tilehardnessmodifier = Data.ofOr(playerId + ".excavator.hardtilesmodifier", 1.0)
		drillStrength *= tilehardnessmodifier
	tile.hit(dir, drillStrength)
	emit_signal("mined", 0.1)
	
	if Options.shakeDrill:
		InputSystem.shakeTarget(self, 20, 0.2, 8)

	var knockback = Data.of("excavator.acceleration") * Data.of("excavator.tileKnockback")
	hitCooldown = Data.of("excavator.tileHitCooldown")
	moveSlowdown = 0.25 + currentSpeed() * 0.01
	spriteLockDuration = hitCooldown
	var drillbuff = 1.0 - float(Data.of(playerId+".keeper.drillBuff"))
	if drillbuff < 1.0:
		hitCooldown = max(hitCooldown * drillbuff, 0.017)
		knockback *= drillbuff
		spriteLockDuration *= drillbuff
	if abs(dir.x) > abs(dir.y):
		move.x = sign(dir.x) * knockback
		move.y *=  0.1
	else:
		move.y = sign(dir.y) * knockback
		move.x *=  0.1

	$TileHitSounds.hit(tile, drillbuff < 1.0, true)

	DrillSprite.show()
	DrillSprite.frame = 0
	var infix  = "_big" if Data.of("excavator.destroyindestructibletiles") else ""
	DrillSprite.play("drill" + infix + animationSuffix)
	DrillSprite.rotation = DrillHitTestRay.rotation + PI

	var anim_name = ""
	if abs(move.x) > abs(move.y):
		anim_name = "drill_right" if move.x < 0 else "drill_left"
	else:
		anim_name = "down" if move.y < 0 else "up"

	$Sprite2D.play(anim_name + animationSuffix)
	
	var hits_needed_to_destroy:float = float(tile.max_health) / float(Data.of(playerId + ".excavator.drillStrength"))
	emit_sparks(DrillHitTestRay.get_collision_point(), tile, hits_needed_to_destroy)
	emit_signal("tileHit")

func boom_check()->void:
	var tile = BoomHitTestRay.get_collider()
	
	if not tile or not tile.has_meta("destructable"):
		return
	if not tile.get_meta("destructable"):
		if Data.of(playerId + ".excavator.destroyindestructibletiles"):
			if not Level.map.isWithinBounds(tile.coord):
				return 
		else:
			return
	
	var dir = global_position - tile.global_position
	var boomStrength = 5000.0
	if tile.hardness >= 3:
		var tilehardnessmodifier = Data.ofOr(playerId + ".excavator.hardtilesmodifier", 1.0)
		boomStrength *= tilehardnessmodifier
	Level.map.damageTileCircleArea(tile.global_position,  3, boomStrength)
	emit_signal("mined", 0.1)
	
	if Options.shakeDrill:
		InputSystem.shakeTarget(self, 20, 0.2, 8)

	var knockback = Data.of("excavator.acceleration") * Data.of("excavator.tileKnockback")
	boomCooldown = Data.of("excavator.boomHitCooldown")
	moveSlowdown = 0.25 + currentSpeed() * 0.01
	spriteLockDuration = boomCooldown
	var drillbuff = 1.0 - float(Data.of(playerId+".keeper.drillBuff"))
	if drillbuff < 1.0:
		boomCooldown = max(boomCooldown * drillbuff, 0.5)
		spriteLockDuration *= drillbuff

	$TileHitSounds.hit(tile, drillbuff < 1.0, true)

	DrillSprite.show()
	DrillSprite.frame = 0
	var infix  = "_big" if Data.of("excavator.destroyindestructibletiles") else ""
	DrillSprite.play("drill" + infix + animationSuffix)
	DrillSprite.rotation = DrillHitTestRay.rotation + PI

	var anim_name = ""
	if abs(move.x) > abs(move.y):
		anim_name = "drill_right" if move.x < 0 else "drill_left"
	else:
		anim_name = "down" if move.y < 0 else "up"

	$Sprite2D.play(anim_name + animationSuffix)
	
	var hits_needed_to_destroy:float = float(tile.max_health) / float(Data.of(playerId + ".excavator.drillStrength"))
	emit_sparks(DrillHitTestRay.get_collision_point(), tile, hits_needed_to_destroy)
	emit_signal("tileHit")

@onready var drill_hit = $DrillHit
func emit_sparks(hit_position:Vector2, tile:Node, hits_needed_to_destroy:float):
	var tile_type = tile.type
	drill_hit.position = to_local(hit_position)*1.5
	drill_hit.rotation = DrillHitTestRay.rotation + PI
	drill_hit.frame = 0
	drill_hit.play("hit")
	var particle_amount = int(round(remap(clamp(hits_needed_to_destroy, 1.0, 8.0), 1, 8, 60, 10)))
	$DrillHit/DrillHitParticles.amount = particle_amount
	$DrillHit/DrillHitParticles.restart()

	
	var spark_amount = int(round(remap(clamp(hits_needed_to_destroy, 1.0, 8.0), 1, 8, 20, 3)))
	var random_amount := 3
	if Options.reducedParticles:
		spark_amount = clamp(spark_amount-1, 2, 5)
		random_amount = 1
	for _i in range(spark_amount+randi()%random_amount):
		var s = Data.KEEPER_SPARK.instantiate()
		s.global_position = hit_position
		s.apply_central_impulse(Vector2.RIGHT.rotated(drill_hit.rotation+randf_range(-0.4,0.4))*randf_range(30,150))
		get_parent().call_deferred("add_child", s)
	
	var dirt_color = Level.map.getBiomeColorByCoord(tile.coord)
	
	var dirt_amount = int(round(remap(clamp(hits_needed_to_destroy, 1.0, 8.0), 1, 8, 5, 0)))
	for _i in range(dirt_amount + randi()%2):
		var t = Data.TILE_DIRT_PARTICLE.instantiate()
		t.modulate = dirt_color
		t.type = tile_type
		t.global_position = hit_position
		t.apply_central_impulse(Vector2.RIGHT.rotated(drill_hit.rotation+randf_range(-0.7,0.7))*randf_range(60,130))
		get_parent().call_deferred("add_child", t)


func disableEffects():
	$StillSound.stop()

func enableEffects():
	$StillSound.play()


func kill():
	for carry in carriedCarryables:
		dropCarry(carry)
	for c in carryLines.values():
		c.queue_free()
	carriedCarryables.clear()
	carryLines.clear()
	$Light3D/LightSmall.set_light_active(false)
	$Light3D/LightBig.set_light_active(false)
	super.kill()
