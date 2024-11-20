extends Carryable

@export var min_velocity_to_kill_bad_relic = 30.0


func _on_body_entered(body):
	if body is Drop and body.type == "bad_relic":
		if linear_velocity.length() > min_velocity_to_kill_bad_relic:
			Data.apply("inventory.relic", 1)
			await get_tree().create_timer(0.2).timeout
			for relic in get_tree().get_nodes_in_group("relic"):
				if relic.type == "bad_relic":
					var broken_relic = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/BadRelic/BadRelicBroken.tscn").instantiate()
					add_child(broken_relic)
					broken_relic.global_position = relic.global_position
					relic.queue_free()
			Data.apply("monsters.wavepresent", false)
			get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.unlockAchievement("HEAVY_ROCK_ENDING")
			
func _physics_process(delta):
	var can_move = GameWorld.boughtUpgrades.has("player1.jetpackstrength4") or GameWorld.boughtUpgrades.has("player1.keeper2bundle4")
	
	if ! can_move :
		for p in carriedBy:
			freeCarry(p)
		return
	
	
