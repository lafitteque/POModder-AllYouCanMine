extends Carryable

@export var min_velocity_to_kill_bad_relic = 30.0


func _on_body_entered(body):
	if body is Drop and body.type == "bad_relic":
		if linear_velocity.length() > min_velocity_to_kill_bad_relic:
			Data.apply("inventory.relic", 1)
			await get_tree().create_timer(0.2).timeout
			Data.apply("monsters.wavepresent", false)
