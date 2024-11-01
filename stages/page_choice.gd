extends PanelContainer

signal select
signal toggled(bool)

@export var toggleable := false

@export var id: String
@export var titleLocId: String
@export var descLocId: String
@export var icon: Texture2D
@export var disabledAlpha := 0.5
var setChoiceCalled := false

var filling:float
var selected := false
var disabled := false
var mouseInside := false
var hovered := false

var loadoutScale := 3.0

func _ready():
	Style.init(self)
	$SelectedPanel.modulate.a = 0

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

func canFocusUse(keeper:Keeper) -> bool:
	return is_visible_in_tree()

func useHold(keeper:Keeper) -> bool:
	return false

func useHit(keeper:Keeper) -> bool:
	if disabled:
		return false
	
	if toggleable:
		selected = not selected
		emit_signal("toggled", selected)
	else:
		emit_signal("select")
	
	if not (toggleable and not selected):
		$SelectedPanel.modulate.a = 1.0
		$Tween.interpolate_property($SelectedPanel, "modulate:a", $SelectedPanel.modulate.a, 0.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
		$Tween.start()
	return true

func onLocaleChanged():

	if icon:
		%Icon.texture = icon
		%Icon.custom_minimum_size = icon.get_size() * loadoutScale
		%Icon.visible = true
	else:
		%Icon.visible = false
	
	find_child("CollisionShape2D").shape = RectangleShape2D.new()


func _process(delta):
	if not visible or disabled:
		return
	
	if selected:
		set('theme_override_styles/panel', preload("res://gui/panels/panel_inside_dark_selected.tres"))
	elif hovered:
		set('theme_override_styles/panel', preload("res://gui/panels/panel_inside.tres"))
	else:
		set('theme_override_styles/panel', preload("res://gui/panels/panel_inside_dark.tres"))
	
	%Usable.position = size * 0.5 
	find_child("CollisionShape2D").shape.extents = size * 0.5 
	
	if mouseInside:
		hovered = true
		filling = min(1.0, filling + delta * 6)
	else:
		if %Usable.focussed:
			hovered = true
			filling = min(1.0, filling + delta * 4)
		else:
			hovered = false
			filling = max(0.0, filling - delta * 6)

func set_enabled(enable:bool):
	disabled = false
	modulate.a = 1.0
	%Icon.material = null
	$Usable.monitorable = true
	$Usable.monitoring = true
		
func _on_LoadoutChoice_mouse_entered():
	mouseInside = true

func _on_LoadoutChoice_mouse_exited():
	mouseInside = false

func _on_LoadoutChoice_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		useHit(null)

func getGlobalPosition() -> Vector2:
	return $Usable.global_position
