extends RelicAttractor

func _ready():
	Data.listen(self, "inventory.remaining_core_eaters")
	condition_fulfilled = false
	
func propertyChanged(property : String , old_value , new_value):
	if property == "inventory.remaining_core_eaters" and new_value == 0:
		condition_fulfilled = true

func _physics_process(delta):
	super(delta)
	if len_to_move < 10.0:
		Data.apply("inventory.relic", 1)
		await get_tree().create_timer(0.2).timeout
		Data.apply("monsters.wavepresent", false)
		get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements.unlockAchievement("CORE_EATER_ENDING")
		queue_free()

