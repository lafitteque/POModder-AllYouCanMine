extends PanelContainer

@export var titleLocId: String
@export var disabledAlpha := 0.5

var filling:float
var disabled := false
var loadoutScale := 3.0
var depoping = false
var cooldown_depop = 7.0

@onready var target_pos = position
 
func _ready():
	position = get_viewport().get_visible_rect().size - Vector2(size.x,0)
	target_pos = get_viewport().get_visible_rect().size - size
	Style.init(self)

func set_scale(value) -> void:
	if typeof(value) == TYPE_FLOAT:
		assert(false, "This call happened most probably due to name clashes, this gdscript had property called 'scale'
				in Godot 3, but it's impossible in Godot 4 since Control has property named in the same way, it has been
				renamed to 'loadoutScale'")
		loadoutScale = value
	scale = value

func get_scale():
	assert(false, "This call happened most probably due to name clashes, this gdscript had property called 'scale'
		in Godot 3, but it's impossible in Godot 4 since Control has property named in the same way, it has been
		renamed to 'loadoutScale'")
	return loadoutScale


func seTitle(titleKey:String):
	titleLocId = titleKey
	
	if titleKey == "":
		%LabelTitle.visible = false
	else:
		%LabelTitle.text = tr(titleKey)
	set('theme_override_styles/panel', preload("res://gui/panels/panel_inside_dark.tres"))

func _process(delta):
	%LabelTitle.self_modulate = Color.WHITE * (1.0 + filling * 1.0)
	filling = max(0.0, filling - delta * 6)
	
	if not visible or disabled:
		return
	if ! depoping and abs((target_pos - position).y) >=2 :
		position.y -= 0.2
		
	elif ! depoping:
		cooldown_depop-= delta
		if cooldown_depop <= 0 :
			depoping = true
			cooldown_depop = 2.0
	elif depoping:
		position.y +=0.2
		cooldown_depop-= delta
		if cooldown_depop <= 0 :
			queue_free()
	


