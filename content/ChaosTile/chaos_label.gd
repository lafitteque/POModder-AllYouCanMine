extends Label

func _ready():
	Style.init(self)
# Called when the node enters the scene tree for the first time.
func _on_timer_timeout():
	queue_free()
