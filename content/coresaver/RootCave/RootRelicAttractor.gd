extends Area2D

var condition_fulfilled = true
var attraction_speed = 15.0
var bad_relic = null
var bad_relic_present = false
var len_to_move = 1000.0
var exploded = false


func _on_body_entered(body):
	if body is Drop and body.type == "bad_relic":
		bad_relic = body
		bad_relic_present = true


func _on_body_exited(body):
	if body is Drop and body.type == "bad_relic":
		bad_relic = null
		bad_relic_present = false

func _ready():
	condition_fulfilled = true
	$"../../Sprites/root".play("idle")

	
func _physics_process(delta):
	if !bad_relic_present:
		return
	if bad_relic.carriedBy.size() > 0 or  !condition_fulfilled:
		return
		
	var to_move = (global_position - bad_relic.global_position)
	len_to_move = to_move.length()
	bad_relic.linear_velocity =  to_move/len_to_move*max(attraction_speed,len_to_move/delta)
	
	if len_to_move < 10.0:
		await get_tree().create_timer(0.2).timeout
		$"../../Sprites".start_offset = 0.0
		$"../../Sprites".scaling = 1.0
		$"../../Sprites/root".z_index = 22
		$"../../Sprites/root".play("attack")
	
		await get_tree().create_timer(0.6).timeout
		explode()
		for relic in get_tree().get_nodes_in_group("relic"):
			if relic.type == "bad_relic":
				var broken_relic = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/BadRelic/BadRelicBroken.tscn").instantiate()
				add_child(broken_relic)
				broken_relic.global_position = relic.global_position
				relic.queue_free()

		Data.apply("inventory.relic", 1)
		Data.apply("monsters.wavepresent", false)
		
		get_node("/root/ModLoader/POModder-Dependency").custom_achievements.unlockAchievement("SECRET_ENDING")
		queue_free()



func _on_root_animation_finished():
	if $"../../Sprites/root".animation == "attack":
		$"../../Sprites/root".pause()
			
func explode():
	exploded = true
	if Level.map:
		Level.map.damageTileCircleArea(global_position,  5, 100000)
