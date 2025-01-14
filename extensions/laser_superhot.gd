extends "res://content/weapons/laser/Laser.gd"

var exit_superhot_mode = true
var exit_normal_mode = false 

var initialEngineSpeed = 1.0

func _ready():
	super()
	if "worldmodifierspeed" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		initialEngineSpeed = 2.0

func inputs(moveValue:Vector2, fireValue:float, specialValue:float):
	if "worldmodifiersuperhot" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		if GameWorld.paused:
			if exit_superhot_mode:
				exit_superhot_mode = false
				Data.apply("laser.movespeed",2.0)
				Engine.time_scale = initialEngineSpeed
			exit_superhot_mode = true
			return
		
		if abs(fireValue) <= 0.1 and abs(specialValue) <= 0.1:
			if exit_normal_mode :
				Data.apply("laser.movespeed",4.0)
				Engine.time_scale = 0.2
				exit_normal_mode = false
			exit_superhot_mode = true
		else : 
			if exit_superhot_mode:
				Data.apply("laser.movespeed",2.0)
				Engine.time_scale = initialEngineSpeed
				exit_superhot_mode = false
			exit_normal_mode = true
			
	super(moveValue, fireValue, specialValue)
	
	
func _physics_process(delta):
	if GameWorld.paused or not inputReady:
		return
	
	var laserMoveSpeed = Data.of("laser.movespeed") * Data.of("laser.movespeedmod")
	if move.x == 0:
		distanceMoved = 0
		$MoveSound.stop()
		currentSpeed = 0
		acceleration = 0
	else:
#			distanceMoved -= 0.05
		if not $MoveSound.playing:
			$MoveSound.play()
		acceleration = clamp(acceleration + max(10.0 - 13.0 * laserMoveSpeed , laserMoveSpeed / 10) * delta, 0.05, 1.0)
	
	var goalSpeed = laserMoveSpeed * move.x

	if firing: 
		goalSpeed *= Data.of("laser.movespeedwhilefiring")
	if Options.useGamepad:
		currentSpeed = goalSpeed
	else:
		currentSpeed += (goalSpeed - currentSpeed) * delta * 8.0 * acceleration
	$MoveSound.pitch_scale = 0.45 + abs(currentSpeed) * 0.5
	var thisMove:float = pathProbe.moveBy(currentSpeed * delta)
	distanceMoved += abs(thisMove)

	var c
	var collisionPoint:Vector2
	var laserEndPos := Vector2(0,-1) * LASER_MAX_LENGTH
	var angleDelta := 0.0
	for raycast in raycasts:
		if not raycast.enabled:
			continue
		var c2 = raycast.get_collider()
		if c2:
			c = c2
			collisionPoint = raycast.get_collision_point()
			angleDelta = (collisionPoint - $RayCast2D.global_position).angle() - rotation + CONST.PI_HALF
			if angleDelta > PI:
				angleDelta -= 2*PI
			elif angleDelta < -PI:
				angleDelta += 2*PI
			laserEndPos = Vector2(0,-1) * ((collisionPoint - global_position).length() + 5)
			break
	
	if laser and Data.of("laser.aimLine"):
		$AimLine.visible = not firing
		if c and c.is_in_group("monster"):
			c.aim()
		$AimLine.set_point_position(1, laserEndPos)
	
	if firing:
		if c:
			if c.is_in_group("monster"):
				# Laser is hitting a monster
				laser.rotation += (angleDelta - laser.rotation) * delta * 5.0
				laser.target(laserEndPos)
				laser.start_hit(laserEndPos)
				if c.currentHealth >= 5:
					laser.playHitBumpSound()
				var damage = Data.of("laser.dps") * Data.of("laser.dpsmod") * delta
				c.hit("laser", damage, Data.of("laser.stun"))
#				if c.currentHealth - damage <= 0.0:
#					var e = preload("res://content/shared/explosions/Explosion3.tscn").instance()
#					e.damage = Data.of("laser.explode")
#					e.position = c.position
#					c.get_parent().add_child(e)
				hitState = 1
			elif Data.of("laser.hitprojectiles") and c.is_in_group("projectile"):
				c.domeAbsorbsDamage()
		elif hitState >= 1:
			hitState -= 1
		elif hitState == 0:
			laser.rotation = 0
			hitState = -1
			# Laser is not hitting anything
			laser.stop_hit()
			$AimLine.set_point_position(1, Vector2(0,-1) * LASER_MAX_LENGTH)
			laserEndPos = Vector2(0,-1) * LASER_MAX_LENGTH
			laser.target(laserEndPos)
	
	if SpriteCannon.animation.begins_with("shoot_" + str(variant)):
			frame += thisMove*3000.0 * delta
			if frame < FRAME_SHOOT_START:
				frame += FRAME_COUNT
			elif frame > FRAME_SHOOT_START + FRAME_COUNT:
				frame -= FRAME_COUNT
	elif SpriteCannon.animation.begins_with("idle_" + str(variant)):
			frame += thisMove*3000.0 * delta
			if frame < FRAME_MOVE_START:
				frame += FRAME_COUNT
			elif frame > FRAME_MOVE_START + FRAME_COUNT:
				frame -= FRAME_COUNT
	$SpriteBase.frame = clamp(int(frame),0,41)
	
	if skipFrame:
		skipFrame = false
		return
	
	# Show or hide laser beam depending on if we're firing
	if firing:
		laser.visible = true
			
			
func stop():
	super()
	exit_superhot_mode = false
	exit_normal_mode = true 
	if "worldmodifiersuperhot" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		Engine.time_scale = initialEngineSpeed

func start():
	super()
	exit_superhot_mode = false
	exit_normal_mode = true 
	super()
	if "worldmodifiersuperhot" in Level.loadout.modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, []):
		Engine.time_scale = initialEngineSpeed
