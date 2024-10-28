extends CharacterBody2D

enum State {HIDE, GROW, IDLE, WALK, DIE, JUMP}
var state: int = State.GROW

var cooldown = 0.0
var initial_cooldown = 5.0
var old_x_speed = 0

var wall_during_jump = true
var just_landed = false
var drop  = null

@onready var jump_fall_acceleration = randf_range(4,6)
@onready var jump_initial_speed = randf_range(110,150)
@onready var x_speed = randf_range(20,40)
@onready var direction = randi_range(0,1)*2-1


func _ready():
	Style.init(self)
	$Sprite2D.play("idle")
	if direction<0 :
		flip()
		direction = -1

func start(startTile):
	$Tween.interpolate_callback(self, 60 + 60*randf(), "die")
	$Tween.start()

func _physics_process(delta):
	if GameWorld.paused :
		return
		
	cooldown -= delta
	velocity.x = 0
	if !is_instance_valid(drop):
		drop = null
	var keepdrop = drop and drop.carriedBy == []
	
	if not $GroundDetector.is_colliding():
		wall_during_jump = wall_during_jump and $WallDetector.is_colliding()
		state = State.JUMP
		velocity.y += jump_fall_acceleration
	elif state != State.GROW and state != State.DIE :
		if state == State.JUMP:
			just_landed = true
			velocity.y = 0
		state = State.WALK
	else : 
		velocity.y = 0
		
	match state:
		State.GROW:
			$Sprite2D.play("grow")
			state = State.IDLE
		State.WALK:
			velocity.x = x_speed*direction
			if just_landed and wall_during_jump:
				flip()
			else:
				wall_during_jump = true
				just_landed = false
			if not $Sprite2D.animation.begins_with("walk_"):
				$Sprite2D.play("walk_left" if direction < 0 else "walk_right")
			if $WallDetector.is_colliding():
				velocity.y = -jump_initial_speed
		State.JUMP:
			if velocity.y > 0.5:
				$Sprite2D.play("jump_up")
			elif velocity.y <=0.5:
				$Sprite2D.play("jump_down")
			velocity.x = old_x_speed
	if keepdrop:
		drop.global_position = $Sprite2D.global_position + Vector2.UP*3
	elif drop and !keepdrop:
		die()
	elif !drop and $DropDetector.is_colliding() and cooldown <=0:
		flip()
		cooldown = initial_cooldown
	if cooldown <= -30:
		die()
		
	old_x_speed = velocity.x
	if velocity.x == 0 and state != State.DIE:
		velocity.x = x_speed * direction
	move_and_slide()
	
func flip():
	$WallDetector.rotation += PI
	$DropDetector.rotation += PI
	direction = -direction

func _on_sprite_2d_animation_looped() -> void:
	_SpriteAnimationFinishedCheck()

func _on_Sprite_animation_finished() -> void:
	_SpriteAnimationFinishedCheck()

func _SpriteAnimationFinishedCheck() -> void:
	$Sprite2D.speed_scale = 1.0
	match $Sprite2D.animation:
		"shrink":
			if state == State.DIE:
				if drop :
					drop.get_node("BoolCarried").queue_free()
				queue_free()
			else:
				animateShrunken()
		"hidden":
			animateShrunken()
		"twinkle":
			animateShrunken()
		"grow":
			$Sprite2D.play("idle")

func animateShrunken():
	$Sprite2D.play("twinkle")
	$Sprite2D.speed_scale = 0.5 + 0.5 * randf()

func die():
	if state != State.DIE:
		state = State.DIE
		$Sprite2D.play("shrink")




func _on_area_2d_body_entered(body):
	if body is Carryable and !body.isCarried() and !drop and state != State.DIE and ! body.get_node("BoolCarried"):
		drop = body
		var bool_node = preload("res://mods-unpacked/POModder-MoreGuildMissions/content/drop_bearer/boolCarried.tscn").instantiate()
		body.add_child(bool_node)
		
