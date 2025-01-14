extends Area2D

var condition_fulfilled = true
var attraction_speed = 15.0
var bad_relic = null
var bad_relic_present = false
var len_to_move = 1000.0
var cooldown = 10.0
var time = 10.0
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
	Data.apply("inventory.remaining_core_eaters",4)
	Data.listen(self, "inventory.remaining_core_eaters")
	condition_fulfilled = false
	
func propertyChanged(property : String , old_value , new_value):
	var eater_list = [$"../../Sprites/Columns Front/eater 1" , $"../../Sprites/Columns Front/eater 2", $"../../Sprites/Columns back/eater 3" , $"../../Sprites/Columns back/eater 4"]
	
	if property == "inventory.remaining_core_eaters" :
		if new_value < 3 :
			print("debug")
		for i in range(4-new_value):
			eater_list[i].play("eater")
	if property == "inventory.remaining_core_eaters" and new_value == 0:
		condition_fulfilled = true

func _physics_process(delta):
	if !bad_relic_present:
		return
	if bad_relic.carriedBy.size() > 0 or  !condition_fulfilled:
		return
		
	var to_move = (global_position - bad_relic.global_position)
	len_to_move = to_move.length()
	bad_relic.linear_velocity =  to_move/len_to_move*max(attraction_speed,len_to_move/delta)
	
	if len_to_move < 10.0:
		Data.apply("inventory.relic", 1)
		var ending = $"../../Sprites/ending"
		ending.visible = true 
		ending.play("ending")
		
		await get_tree().create_timer(0.4).timeout
		explode()
		await get_tree().create_timer(0.4).timeout

		ending.pause()
		ending.queue_free()
		for relic in get_tree().get_nodes_in_group("relic"):
			if relic.type == "bad_relic":
				var broken_relic = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/BadRelic/BadRelicBroken.tscn").instantiate()
				add_child(broken_relic)
				broken_relic.global_position = relic.global_position
				relic.queue_free()
				
		Data.apply("monsters.wavepresent", false)
		get_node("/root/ModLoader/POModder-Dependency").custom_achievements.unlockAchievement("CORE_EATER_ENDING")
		queue_free()

func explode():
	exploded = true
	if Level.map:
		Level.map.damageTileCircleArea(global_position,  5, 100000)
