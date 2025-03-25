extends Keeper

signal tileHit

var minBallCharge := 0.5
var collectCharge := 0.0
var ballActionCooldown := 0.0
var reloadSpeedModifier := 1.0
var chargingCollect := false
var bundleShotRefPoint := Vector2()
var tileHitCooldown := 0.5

var pushTime := 0.0
var pushing := false
var pushDirection := Vector2()

var insideLift := false
var carryingResources := false
var reloadOnNextConsoleExit := false

var moveStopSoundPlayBuffer := 0.0 # we don't want the jetpack on(off sounds to play too much, so wait a few frames before playing them
var moveStartSoundPlayBuffer := 0.0

var bundleEffect

var action_hint_cancel_disable := -1
var action_hint_interact := -1
var action_hint_shoot_bundle := -1
var action_hint_drop := -1
var action_hint_shoot_pinball := -1
var last_frame_vel

func init():
	super.init()
	$ChargeCentral.modulate.a = 0.0
	$ChargeCentral.play("charge")
	$ChargePointer.modulate.a = 0.0
	$ChargePointer.play("default")
	
	$Sprite2D.frame = 0
	focussedUsable = null
	focussedCarryable = null
	
	$MuzzleFlash.hide()
	$BallExplodeArea.start(playerId)
	$BallSplitArea.start(playerId)
	$PinballAmmo.start(playerId)
	
	Data.apply(playerId + ".keeper2.remainingspheres", 0)
	Data.apply(playerId + ".keeper2.currentspherereload", Data.of(playerId + ".keeper2.spherereload") - 4)
	Data.listen(self, "monsters.wavepresent")
	Data.listen(self, playerId + ".keeper2.reflectsphere", true)

	Style.init(self)
	
	Level.addTutorial(self, "assessor2_intro")
	Level.addTutorial(self, "assessor2_bundle")
	Level.addTutorial(self, "assessor2_guidance")
	
	Achievements.addIfOpen(self, "KEEPER2_AMMO")

	await StageManager.stage_started # level
	if Level.map:
		var bundleTrackerAlreadySpawned := false
		for effect in Level.map.getAdditionalEffects():
			if effect.is_in_group("keeper2_bundle_tracker"):
				bundleTrackerAlreadySpawned = true
				break
		if not bundleTrackerAlreadySpawned:
			bundleEffect = preload("res://content/keeper/keeper2/BundleResourceTracker.tscn").instantiate()
			Level.map.registerAdditionalEffect(bundleEffect)
	else:
		Logger.error("Assessor tried to register additional map effect, but no map is set in Level", "Keeper2._ready")
	
	#action_hint_interact = Level.viewports.register_action_hint("keeper1_pickup", "pause.gamepadcontrols.use")
	#action_hint_cancel_disable = Level.viewports.register_action_hint("keeper2_gravityball", "actionhint.cancel")
	#action_hint_shoot_bundle =  Level.viewports.register_action_hint("keeper2_gravityball", "actionhint.release")
	#action_hint_shoot_pinball =  Level.viewports.register_action_hint("keeper2_gravityball", "actionhint.fire")
	#action_hint_drop =  Level.viewports.register_action_hint("keeper2_gravityball", "pause.gamepadcontrols.drop")

func propertyChanged(property:String, oldValue, newValue):
	match property:
		# ONLY LOWERCASE HERE
		"monsters.wavepresent":
			if newValue and newValue != oldValue:
				reloadOnNextConsoleExit = true
		"keeper2.reflectsphere": 
			if newValue and newValue != oldValue:
				visible = true
				Level.addTutorial(self, "assessor2_reflect")

func enterStation(dropResources := true):
	super.enterStation(dropResources)
	$AimIndicator.modulate.a = 0.0

func exitStation():
	if reloadOnNextConsoleExit:
		reloadOnNextConsoleExit = false
		var reloadTime = Data.of(playerId + ".keeper2.spherereload")
		var maxSpheres = Data.of(playerId + ".keeper2.totalspheres")
		var timeToAdd = maxSpheres * reloadTime * 0.55
		while timeToAdd > 0.0:
			var remainingShots = Data.of(playerId + ".keeper2.remainingspheres")
			if timeToAdd >= reloadTime and remainingShots < maxSpheres:
				remainingShots += 1
				Data.apply(playerId + ".keeper2.remainingspheres", remainingShots)
				timeToAdd -= reloadTime
			else:
				if remainingShots == maxSpheres:
					Data.apply(playerId + ".keeper2.currentspherereload", 0.0)
				else:
					Data.changeByInt(playerId + ".keeper2.currentspherereload", timeToAdd)
				timeToAdd = -1
	super.exitStation()
	$AimIndicator.modulate.a = 1.0

@onready var drill_particles = $DrillParticles
@onready var drill_sprite = $DrillSprite
func _physics_process(delta):
	super._physics_process(delta)
	
	update_action_hints()
		
	if isInsideStation or GameWorld.paused or disabled:
		$MoveSound.stop()
		return
	
	var speedBuff = Data.of(playerId + ".keeper.speedBuff")
	var drillBuff = Data.of(playerId + ".keeper.drillBuff")
	if speedBuff > 0 or drillBuff > 0:
		animationSuffix = "_buffed" if playerId == "player1" else ""
	else:
		animationSuffix = "_buffed" if playerId == "player2" else ""

	drill_particles.emitting = false
	drill_sprite.visible = false
	if moveDirectionInput.length() == 0:
		pushTime = 0.0
		pushDirection *= 0
	else:
		$DrillHitTestRay.rotation = moveDirectionInput.angle()
		$DrillHitTestRay.force_raycast_update()
		var tile = $DrillHitTestRay.get_collider()
		if not (tile and tile.has_meta("destructable") and tile.get_meta("destructable")):
			pushTime = 0.0
			pushDirection *= 0
		else:
			var directMiningDamage = Data.of(playerId + ".keeper2.directminingdamage")
			var drillbuff = 1.0 + drillBuff
			pushTime += delta * (1.0 - min(last_frame_vel.length() / 35.0, 1.0))
			pushDirection = global_position - tile.global_position
			if pushTime * drillbuff > 0.4:
				if not pushing:
					pushing = true
					match int(Data.of(playerId + ".keeper2.directminingstage")):
						1:
							$BallDrill.play()
							$BallDrillInit.play()
						2:
							$BallDrillUpgrade1.play()
							$BallDrillInitUpgrade1.play()
						3:
							$BallDrillUpgrade2.play()
							$BallDrillInitUpgrade2.play()
					match tile.type:
						CONST.IRON:
							$BallDrillIron.play()
						CONST.WATER:
							$BallDrillWater.play()
						CONST.SAND:
							$BallDrillCobolt.play()
						CONST.GADGET:
							$BallDrillSpecial.play()
						CONST.POWERCORE:
							$BallDrillSpecial.play()
						CONST.RELIC:
							$BallDrillSpecial.play()
			if pushTime * drillbuff > 0.8:
				var hardnessMod = 1.0
				if tile.hardness >= 3:
					hardnessMod -= ((tile.hardness - 2) * Data.of(playerId + ".keeper2.directmininghardness")) / 4.0
				if tile.hardness <= 1:
					hardnessMod += ((2 - tile.hardness) * Data.of(playerId + ".keeper2.directmininghardness")) / 2.0
				var mod = 1.0
				if tile.type == "iron":
					var v = max(15, Data.ofOr("map.ironAdditionalHealth", 0))
					mod = 15.0 / float(v)
				tile.hit(pushDirection, tile.max_health * directMiningDamage * drillbuff * hardnessMod * delta * mod)
				var pt = $DrillHitTestRay.get_collision_point()
				drill_particles.global_position = pt
				drill_particles.rotation = (pt - global_position).angle()
				drill_particles.emitting = true

				var s = randf_range(0.5, 1.0)
				drill_sprite.global_position = pt
				drill_sprite.rotation = (pt - global_position).angle()
				drill_sprite.scale = Vector2(s, s)
				drill_sprite.visible = true
	
	if pushTime <= 0 and pushing:
		pushing = false
		$BallDrill.stop()
		$BallDrillUpgrade1.stop()
		$BallDrillUpgrade2.stop()
		$BallDrillCobolt.stop()
		$BallDrillSpecial.stop()
		$BallDrillWater.stop()
		$BallDrillIron.stop()
	
	bundleShotRefPoint = global_position + moveDirectionInput.normalized() * 40
	
	if ballActionCooldown > 0.0:
		ballActionCooldown -= delta
		$ReflectCooldownSprite.rotation = randf() * TAU
		if ballActionCooldown <= 0.0:
			reloadSpeedModifier = 1.0
			if Data.of(playerId + ".keeper2.reflectsphere"):
				$ReflectionCooldownOver.play()
				$ReflectCooldownSprite.visible = false
	
	# floaty controls don't allow for traversing tunnels nicely, resukting in a lot of bumps.
	# this part helps quickly change direction if the controls suggest a steep turn
	var moveDotInput = moveDirectionInput.dot(move.normalized())
	var turnSpeed = (1.0 - moveDotInput)
	var strength = 8.0
	var absX = abs(moveDirectionInput.x)
	var absY = abs(moveDirectionInput.y)
	if absX > absY * 1.0:
		if absY > 0.0:
			strength = min(strength, absX / absY)
		move.y *= 1.0 - delta * turnSpeed * strength
	elif absY > absX * 1.0:
		if absX > 0.0:
			strength = min(strength, absY / absX)
		move.x *= 1.0 - delta * turnSpeed * strength
	
	var theoreticalBaseSpeed = currentSpeed()
	var relativeSpeed = clamp(move.length() / theoreticalBaseSpeed, 0, 1.0)
	var acceleration = Data.of(playerId + ".keeper2.acceleration")
	# acceleration should happen slower the faster you move. However, when trying to move sideways 
	# while going past, it should still be controllable, so turnspeed is needed. Has a unwanted 
	# sideffect of speeding up faster, if rapidly pressing left/right while moving up or down.
	acceleration *= min(1.0, (1.2 + 2.0 * max(0.0, turnSpeed)) - pow(relativeSpeed, 0.5))
	var deceleration = Data.of(playerId + ".keeper2.deceleration")
	var moveChange = moveDirectionInput * (acceleration + speedBuff) * delta * 3
	if moveDirectionInput.length() == 0:
		move = move * (1 - delta * deceleration)
	else:
		var intentionDiff = move.dot(moveDirectionInput)
		if intentionDiff < 0:
			moveChange *= 1.0 - intentionDiff / 25.0
	
	move = move + moveChange
	move *= clamp(1.0 - (pushTime - 0.1) * 2.0, 0.0, 1.0)
	
	if move.length() < 80:
		$MoveSound/MoveFastSound.setAdditionalVolume(-60) 
	else:
		$MoveSound/MoveFastSound.setAdditionalVolume(-12 + 12.0 * clamp((move.length() - 80) / 160.0, 0.0, 1.0)) 
	
	var carrySize := carriedCarryables.size()
	var slowdown := 1.0
	for c in carriedCarryables:
		slowdown *= 1.0 - (c.additionalSlowdown / c.carrierCount())
	
	var minSpeed = Data.of(playerId + ".keeper2.minspeed")
	var collectChargeAffectingSpeed = max(minSpeed * 30.0, minSpeed * theoreticalBaseSpeed * (1.0 - collectCharge * 3.0))
	var loweredByCarryables = max(minSpeed * 24.0, theoreticalBaseSpeed * (1.0 - pow(carrySize, 3) * 0.0065))
	
	var baseSpeed = min(loweredByCarryables, collectChargeAffectingSpeed)
	var maxSpeed = baseSpeed * slowdown
	if externallyMoved:
		move *= 0
		moveDirectionInput *= 0
	move = move.limit_length(max(0, maxSpeed))
	
	var actualMove = position
	set_velocity(move)
	move_and_slide_custom()
	actualMove = position - actualMove
	move = velocity
	
	#gd4 fix for changes to move and slide
	#extrapolate velocity because velocity property isn't set to 0 as expected when colliding
	last_frame_vel = actualMove / delta
	
	GameWorld.travelledDistance += actualMove.length()

	updateMoveAnimation(actualMove, delta)
	
	var remainingShots = Data.of(playerId + ".keeper2.remainingspheres")
	if remainingShots < Data.of(playerId + ".keeper2.totalspheres"):
		var reloadCounter = max(1.0, Data.ofOr(playerId + ".keeper2.currentspherereload", 0.0))
		reloadCounter += delta * reloadSpeedModifier
		if Data.of(playerId + ".keeper2.spherereload") <= reloadCounter:
			Data.apply(playerId + ".keeper2.currentspherereload", 0)
			Data.apply(playerId + ".keeper2.remainingspheres", remainingShots + 1)
			$AmmoAdded.play()
		else:
			Data.apply(playerId + ".keeper2.currentspherereload", reloadCounter)
	
	if tileHitCooldown > 0.0:
		tileHitCooldown -= delta
	
	updateCollectCharge(delta)
	
	# handle currently influenced carryables
	for influence in get_tree().get_nodes_in_group("carry_influence"):
		var carryable = influence.getCarryable()
		if not (chargingCollect and carryables.has(carryable)) and not carriedCarryables.has(carryable):
			influence.beingPulled = false
			if influence.isBundled():
				influence.strength -= delta
			else:
				var change = delta
				if carryable is Drop:
					change *= 0.2
				influence.strength -= change
	
	var collectScaling = min(1.0, collectCharge)
	var radius = 40 * collectScaling
	$CarryArea/CollisionDrops.shape.radius = radius + 8
	updateCollectSphereFx(collectScaling)
	
	# because there is no notification about usables becoming focussable, this runs every loop
	# otherwise there would be problems with carryables and stations, like in the cellar
	updateInteractables()
	
	for c in carriedCarryables.duplicate():
		var d:Vector2 = global_position - c.global_position
		var l = d.length()
		if l > 150:
			dropCarry(c)
			continue
		d = (d.normalized() * pow(d.length() * 0.1, 2)).limit_length(20)
		d += d.rotated(PI * 0.5) * 0.1
		c.apply_central_impulse(d)

	var aimDirection = getAimDirection()
	if aimDirection.length() == 0:
		$AimIndicator.modulate.a = 0
	else:
		if $AimIndicator.modulate.a == 0:
			$AimIndicator.rotation = aimDirection.angle()
		else:
			$AimIndicator.rotation = lerp_angle($AimIndicator.rotation, aimDirection.angle(), delta * 30.0)
		$AimIndicator.modulate.a = 1
	

func update_action_hints():
	pass
	#Level.viewports.set_action_hint_visible(action_hint_interact, not disabled and focussedUsable != null)
	#Level.viewports.set_action_hint_visible(action_hint_cancel_disable, disabled and disable_source != null)
	#
	#var action = getPotentialBallHitActionName()
	#Level.viewports.set_action_hint_visible(action_hint_shoot_bundle, action == "shoot_bundle")
	#Level.viewports.set_action_hint_visible(action_hint_shoot_pinball, action == "shoot")
	#Level.viewports.set_action_hint_visible(action_hint_drop, action == "drop_carry")
	
# Visual Effects for "collecting"
@onready var collect_sprite_mat : ShaderMaterial = $CollectSprite.material
@onready var collect_sprite = $CollectSprite
@onready var collect_sprite_particles_mat = $CollectSpriteParticles.process_material
@onready var collect_sprite_particles = $CollectSpriteParticles
@export var collect_modulation_curve : Curve
var last_collect_sprite_scale := 0.0

func updateCollectSphereFx(_scaling:float):
	collect_sprite_particles.visible = not isInsideDome
	var shrinking := last_collect_sprite_scale > _scaling
	last_collect_sprite_scale = _scaling
	collect_sprite_particles.emitting = not shrinking and last_collect_sprite_scale != _scaling
	collect_sprite_mat.set_shader_parameter("radius", 40*_scaling*0.9)
	collect_sprite_mat.set_shader_parameter("edge_width", remap(ease(_scaling, 0.4), 0, 1, 6, 0.7))
	collect_sprite.modulate.a = (ease(_scaling, 0.5)*0.2)+0.5
	var mainSpriteMod : Color = collect_sprite.modulate*2.0
	mainSpriteMod.a = 1.0
	if not shrinking:
		$Sprite2D.modulate = lerp(Color.WHITE, mainSpriteMod, collect_modulation_curve.sample(_scaling))
		collect_sprite.self_modulate = lerp(Color(2,2,2,1), Color.WHITE, ease(_scaling, 0.2))
	else:
		collect_sprite.self_modulate.a *= _scaling
		$Sprite2D.modulate = lerp(Color.WHITE, $Sprite2D.modulate, ease(_scaling, 0.5))
	collect_sprite_particles_mat.emission_ring_radius = 40 * _scaling
	collect_sprite_particles_mat.emission_ring_inner_radius = 40 * _scaling


func updateCollectCharge(delta):
	# pull minerals while charging, and equip with influence
	if chargingCollect:
		if position.y < CONST.DOME_CUPOLA_ENTRANCE_Y:
			collectRelease()
			return

		$CarryArea/CollisionDrops.disabled = false
		$CarryArea/CollisionNotDrops.disabled = true
		var untilFull = 2.0 * (1.0 - collectCharge)
		collectCharge = min(1.0, collectCharge + (1.0 + untilFull) * delta * 0.1)
		for c in carryables:
			if c.carryableType != "resource":
				continue 
			var influence = c.getOrCreateCarryInfluence(self)
			var newStrength = influence.strength + delta * 5.0
			influence.strength = min(1.0, newStrength)
			influence.beingPulled = true
			if carriedCarryables.has(c):
				continue
			
			var d:Vector2 = global_position - c.global_position
			if d.length() < GameWorld.TILE_SIZE * 2 and newStrength >= 0.9:
				if influence.isBundled():
					var inBundle = influence.getBundle().getBundledInfluences()
					for i in inBundle:
						influence.exitBundle()
					for i in inBundle:
						attachCarry(i.getCarryable())
					return
				else:
					attachCarry(c)
					continue
			
			c.apply_central_impulse(d.limit_length(pow(newStrength * 4, 1.5)))
	else:
		if collectCharge > 0.0:
			collectCharge = max(0.0, collectCharge - 1 * delta)
		$CarryArea/CollisionDrops.disabled = true
		$CarryArea/CollisionNotDrops.disabled = false
	
	# pitch up the higher it is charged
	$ChargeCollectAmb.setAdditionalPitch(collectCharge * 0.6)
	var carrysize = carriedCarryables.size()
	if not chargingCollect:
		# reduce volume if only carrying. Reduce more if there are less drops being carried.
		if carrysize == 0 and $ChargeCollectAmb.shouldPlay:
			$ChargeCollectAmb.stop()
		$ChargeCollectAmb.setAdditionalVolume(-6 + min(1.0, 8 * carrysize / 6.0))
	else:
		$ChargeCollectAmb.setAdditionalVolume(0)
	
func updateMoveAnimation(actualMove:Vector2, delta:float):
	var combinedMove = moveDirectionInput
	if not pushing and actualMove.length() > 0.15:
		combinedMove += actualMove
	
	var moving = combinedMove.length() > 0.35
	$Trail.emitting = moving
	$StoppedParticles.emitting = not moving
	
	if not pushing and chargingCollect:
		$Sprite2D.play("pull"+animationSuffix)
	else:
		if combinedMove.length() < 0.35:
			$Sprite2D.play("default"+animationSuffix)
		else:
			var prefix = "push_" if pushing else ""
			if abs(combinedMove.x) > abs(combinedMove.y) * 0.95:
				$Sprite2D.play(prefix + "left" + animationSuffix if combinedMove.x < 0 else prefix + "right" + animationSuffix)
			else:
				$Sprite2D.play(prefix + "up" + animationSuffix if combinedMove.y < 0 else prefix + "down" + animationSuffix)
		if moveDirectionInput.length() == 0 or move.length() < 3:
			moveStartSoundPlayBuffer = 0
			if $MoveSound.shouldPlay:
				moveStopSoundPlayBuffer += delta
				if moveStopSoundPlayBuffer >= 0.2:
					$MoveSound.stop()
					$MoveStopSound.play()
					moveStopSoundPlayBuffer = 0
		else:
			moveStopSoundPlayBuffer = 0
			if not $MoveSound.shouldPlay:
				moveStartSoundPlayBuffer += delta
				if moveStartSoundPlayBuffer >= 0.1:
					$MoveSound.play()
					$MoveStartSound.play()
					moveStartSoundPlayBuffer = 0

func is_potential_carryable(carryable : Carryable) -> bool:
	if carriedCarryables.has(carryable):
		return false
	if carryable.carryableType != "gadget":
		return false
	if !carryable.canFocusCarry():
		return false
	if  (pickupType != "" and pickupType != carryable.carryableType):
		return false
	if carryable.is_in_group("usables") and not usables.has(carryable.get_meta("usable")):
		return false

	return true

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
		# carry radius is larger, but usables shouldn't switch mode so secretive
		if is_potential_carryable(carryable):
				potentialCarryables.append(carryable)
	
	potentialCarryables.sort_custom(Callable(self, "sortByDistance"))
	
	for carryable in potentialCarryables:
		if focussedCarryable == carryable:
			return
		else:
			if focussedCarryable:
				focussedCarryable.unfocusCarry(self)
			focussedCarryable = carryable
			focussedCarryable.focusCarry(self)
		return

func attachCarry(body):
	if carriedCarryables.has(body):
		Logger.error("Tried to attach carryable " + body.name + "although it's already carried ")
		return
	body.unfocusCarry(self)
	if body == focussedUsable:
		focussedUsable = null
	
	var influence = body.getOrCreateCarryInfluence(self)
	if influence.bundle:
		influence.exitBundle()
		influence = body.getOrCreateCarryInfluence(self)
	influence.strength = 1.0
	
	var po = CarryablePhysicsOverride.new(self)
	po.gravity_scale = 0.0
	po.linear_damp = 2
	po.angular_damp = 2
	body.addPhysicsOverride(po)
	carriedCarryables.append(body)
	body.setCarriedBy(self)
	
	$Pickup.play()

func shootPinball():
	$Shoot.play()
	var sphere = preload("res://content/keeper/keeper2/Pinball.tscn").instantiate()
	var keeperCoord = Level.map.getTileCoord(global_position)
	var newPos = Level.map.getTilePos(keeperCoord)
	sphere.position = lerp(position, newPos, 0.45)
	var db = Data.of(playerId + ".keeper.drillBuff")
	sphere.size = 1.0 + min(0.35, db * 0.5)
	sphere.maxSpeed += db * 60
	sphere.playerId = playerId
	get_parent().add_child(sphere)
	
	var aimDirection = getAimDirection()
	sphere.apply_central_impulse(aimDirection * 150)
	
	InputSystem.shakeTarget(self, 50, 0.2)
	
	Data.changeByInt(playerId + ".keeper2.remainingspheres", -1)
	emit_signal("mined", 3.0)

func shootBundle(carryables):
	var bundle = preload("res://content/keeper/keeper2/Bundle.tscn").instantiate()
	bundle.position = position
	Level.viewports.addElement(bundle)
	var bundleGroup:Array = []
	for carryable in carryables:
		if carryable.carryableType == "resource":
			bundleGroup.append(carryable)
	
	if bundleGroup.size() == 0:
		bundleGroup = carryables.duplicate()
	
	bundleGroup.sort_custom(Callable(self, "sortByDistanceToRefPo"))
	for b in bundleGroup:
		dropCarry(b)
	
	for carryable in bundleGroup:
		for carrier in carryable.carriedBy:
			carrier.dropCarry(carryable)

	var aimDirection = getAimDirection()
	var bundleLeader = self if aimDirection.length() == 0.0 and Data.of(playerId + ".keeper2.bundleguide") else null
	
	bundle.start(aimDirection, bundleGroup, Data.of(playerId + ".keeper2.bundlespeed"), 
	Data.of(playerId + ".keeper2.bundleduration"), bundleLeader)
	
	var groupSize = bundleGroup.size()
	if groupSize <= 4:
		$BundleShotSmall.play()
	elif groupSize <= 14:
		$BundleShotMedium.play()
	else:
		$BundleShotBig.play()
	
	InputSystem.shakeTarget(self, min(80, groupSize * 20), 0.2)
	move += aimDirection.rotated(PI) * 10 * groupSize
#	move *= 0
	
	carryingResources = false

func ballHold():
	if disabled or isInsideDome:
		return
	
	collectRelease()

func ballRelease():
	collectRelease()

func getPotentialBallHitActionName():
	if disabled:
		return null
	
	var resources := []
	var otherDrops := []
	for c in carriedCarryables:
		if c.carryableType == "resource":
			resources.append(c)
		else:
			otherDrops.append(c)
			
	if resources.size() > 0:
		return "shoot_bundle"
	
	if otherDrops.size() > 0:
		return "drop_carry"

	if Data.of(playerId + ".keeper2.remainingspheres") > 0 and not isInsideDome:
		return "shoot"
	
	return null

var tmpAimDirection := Vector2()
func ballHit():
	if disabled:
		return
	
	var resources := []
	var otherDrops := []
	for c in carriedCarryables:
		if c.carryableType == "resource":
			resources.append(c)
		else:
			otherDrops.append(c)
	
	if resources.size() > 0:
		shootBundle(resources)
	elif otherDrops.size() > 0:
		tmpAimDirection = getAimDirection()
		otherDrops.sort_custom(sortByDistanceToGlobalPos)
		var farthestCarryable
		for carryable in otherDrops:
			if carryable.carryableType == "resource":
				farthestCarryable = carryable
				break
		if not farthestCarryable:
			farthestCarryable = otherDrops.front()
		dropCarry(farthestCarryable)
		$Drop.play()
		
		if tmpAimDirection.length() > 0:
			var impulse = tmpAimDirection * 150
			farthestCarryable.apply_central_impulse(impulse - farthestCarryable.linear_velocity)
	elif Data.of(playerId + ".keeper2.remainingspheres") > 0 and not isInsideDome:
		var aimDirection = getAimDirection()
		var directionSufficientToShoot:bool
		if Options.useMouseKeeperGameplay or Options.useGamepad:
			directionSufficientToShoot = aimDirection.length() > 0
		else:
			directionSufficientToShoot = moveDirectionInput.length() >= moveDirectionThreshold
		if directionSufficientToShoot:
			shootPinball()

func sortByDistanceToGlobalPos(d1, d2) -> bool:
	var p = global_position + tmpAimDirection * 50.0
	return p.distance_to(d1.global_position) < p.distance_to(d2.global_position)

func collectHold():
	if disabled or position.y < CONST.DOME_CUPOLA_ENTRANCE_Y:
		return
	
	if collectCharge == 0.0 and focussedCarryable and focussedCarryable.carryableType != "resource":
		attachCarry(focussedCarryable)
		return
	
	if not chargingCollect:
		chargingCollect = true
		$ChargeCollectStart.play()
		$ChargeCollectAmb.play()
		$InitPull.play()

func collectRelease():
	if chargingCollect:
		chargingCollect = false
		$ChargeCollectStart.stop()

func collectHit():
	if disabled or isInsideDome:
		return
	
	# pick up carryable directly
	if focussedCarryable:
		attachCarry(focussedCarryable)
		return
	
	for u in usables:
		if u.canPickup(self):
			u.useHit(self)
			return
	
	if Data.of(playerId + ".keeper2.reflectsphere"):
		if ballActionCooldown <= 0.0:
			match Data.of(playerId + ".keeper2.actionstage"):
				1: $ReflectionOn.play()
				2: $ReflectionOnUpgrade.play()
			$ReflectCooldownSprite.visible = true
			$ReflectCooldownSprite.play("active")
			var reflector = preload("res://content/keeper/keeper2/BallReflectArea.tscn").instantiate()
			var keeperCoord = Level.map.getTileCoord(global_position)
			var newPos = Level.map.getTilePos(keeperCoord)
			reflector.position = lerp(position, newPos, 0.6)
			reflector.lifetime = Data.of(playerId + ".keeper2.reflectlifetime")
			get_parent().add_child(reflector)
			ballActionCooldown = Data.of(playerId + ".keeper2.actioncooldown")
	elif Data.of(playerId + ".keeper2.spheresplit"):
		if ballActionCooldown <= 0.0:
			move *= 0.0
			$BallSplitArea.catch()
			create_tween().tween_callback($BallSplitArea.stopCatching).set_delay(1.0)
		else:
			$AbilityOnCooldown.play()
	elif Data.of(playerId + ".keeper2.explodespheres"):
		if ballActionCooldown <= 0.0:
			$BallExplodeArea.explode()
			reloadSpeedModifier = 1.5
		else:
			$AbilityOnCooldown.play()

func sortByDistanceToRefPo(d1, d2) -> bool:
	return (d1.global_position - bundleShotRefPoint).length() < (d2.global_position - bundleShotRefPoint).length()

func dropCarry(carryable):
	carriedCarryables.erase(carryable)
	carryable.freeCarry(self)

func currentSpeed() -> float:
	var s = Data.of(playerId + ".keeper2.maxSpeed")
	s += Data.ofOr(playerId + ".keeper.speedBuff", 0)
	var yMove = move.normalized().y
	s += Data.ofOr(playerId + ".keeper.additionalupwardsspeed", 0) * abs(yMove)
	return s

func disableEffects():
	$StoppedParticles.emitting = false
	$Trail.emitting = false
	$PinballAmmo.visible = false

func enableEffects():
	$PinballAmmo.visible = true

func getBallActionCooldown() -> float:
	return ballActionCooldown

func kill():
	$Light3D/LightSmall.set_light_active(false)
	$Light3D/LightBig.set_light_active(false)
	super.kill()

func wasHolding() -> bool:
	return collectCharge > 0.0

func onShowKeeperAimIndicatorChanged():
	$AimIndicator.visible = (Options.showKeeperAimIndicatorGamepad and Options.useGamepad) or (Options.showKeeperAimIndicatorMouse and Options.useMouseKeeperGameplay and not Options.useGamepad)

func canEnterRemoteStation() -> bool:
	#assessor cannot enter remote station while carrying something
	#because otherwise the remote station is really annoying with bundle gameplay
	return carriedCarryables.size() == 0
