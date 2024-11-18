extends RelicAttractor

func _ready():
	condition_fulfilled = true
	$"../../Sprites/root".play("idle")

	
func _physics_process(delta):
	super(delta)
	if len_to_move < 10.0:
		await get_tree().create_timer(0.2).timeout
		$"../../Sprites".start_offset = 0.0
		$"../../Sprites".scaling = 1.0
		$"../../Sprites/root".z_index = 22
		$"../../Sprites/root".play("attack")
	
		await get_tree().create_timer(0.6).timeout
		for relic in get_tree().get_nodes_in_group("relic"):
			if relic.type == "bad_relic":
				relic.find_child("Sprite2D").texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/broken_relic.png")

		Data.apply("inventory.relic", 1)
		Data.apply("monsters.wavepresent", false)
		
		get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.unlockAchievement("SECRET_ENDING")
		queue_free()



func _on_root_animation_finished():
	if $"../../Sprites/root".animation == "attack":
		$"../../Sprites/root".pause()
			
