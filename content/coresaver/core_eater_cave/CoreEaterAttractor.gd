extends RelicAttractor

func _ready():
	Data.listen(self, "inventory.remaining_core_eaters")
	condition_fulfilled = false
	
func propertyChanged(property : String , old_value , new_value):
	var eater_list = [$"../../Sprites/Columns Front/eater 1" , $"../../Sprites/Columns Front/eater 2", $"../../Sprites/Columns back/eater 3" , $"../../Sprites/Columns back/eater 4"]
	
	if property == "inventory.remaining_core_eaters" :
		for i in range(4-new_value):
			eater_list[i].play("eater")
	if property == "inventory.remaining_core_eaters" and new_value == 0:
		condition_fulfilled = true

func _physics_process(delta):
	super(delta)
	if len_to_move < 10.0:
		Data.apply("inventory.relic", 1)
		$"../../ending".visible = true 
		$"../../ending".play("ending")
		await get_tree().create_timer(0.8).timeout
		$"../../ending".pause()
		$"../../ending".queue_free()
		for relic in get_tree().get_nodes_in_group("relic"):
			if relic.type == "bad_relic":
				relic.find_child("Sprite2D").texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/broken_relic.png")

		Data.apply("monsters.wavepresent", false)
		get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.unlockAchievement("CORE_EATER_ENDING")
		queue_free()

