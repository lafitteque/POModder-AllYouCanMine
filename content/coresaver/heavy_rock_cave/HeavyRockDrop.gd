extends Carryable

@export var min_velocity_to_kill_bad_relic = 30.0


func _on_body_entered(body):
	if body is Drop and body.type == "bad_relic":
		if linear_velocity.length() > min_velocity_to_kill_bad_relic:
			Data.apply("inventory.relic", 1)
			await get_tree().create_timer(0.2).timeout
			for relic in get_tree().get_nodes_in_group("relic"):
				if relic.type == "bad_relic":
					relic.find_child("Sprite2D").texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/broken_relic.png")
			Data.apply("monsters.wavepresent", false)
			get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.unlockAchievement("HEAVY_ROCK_ENDING")
			
func _physics_process(delta):
	var can_move = GameWorld.boughtUpgrades.has("player1.jetpackstrength4") or GameWorld.boughtUpgrades.has("player1.keeper2bundle4")
	
	if ! can_move :
		for p in carriedBy:
			freeCarry(p)
		return
	
	
