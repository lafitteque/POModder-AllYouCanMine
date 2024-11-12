extends RelicAttractor

func _ready():
	condition_fulfilled = true
	

func _physics_process(delta):
	super(delta)
	if len_to_move < 10.0:
		Data.apply("inventory.relic", 1)
		await get_tree().create_timer(0.2).timeout
		Data.apply("monsters.wavepresent", false)
		queue_free()

