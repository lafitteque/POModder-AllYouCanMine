extends "res://stages/loadout/LoadoutChoice.gd"

#var is_completed = false

func _ready() -> void:
	super._ready()
	%CheckIcon.texture = preload("res://gui/buttons/checkbox_normal.png")

func _process(delta):
	pass
	#if is_completed:
		#%CheckIcon.texture = preload("res://gui/buttons/checkbox_checked.png")

func completed():
	set('theme_override_styles/panel', preload("res://gui/panels/panel_inside_dark_selected.tres"))
	#await get_tree().create_timer(2.0).timeout
	%CheckIcon.texture = preload("res://gui/buttons/checkbox_checked.png")
	#is_completed = true
	
func setChoice(titleKey:String, id:String, icon:Texture2D, hint = null):
	titleLocId = titleKey
	if hint is String:
		descLocId = hint
	setChoiceCalled = true
	self.id = id
	
	if titleKey == "":
		%LabelTitle.visible = false
		#if id.find("pet") == -1:
			#%Icon.modulate = Color(0.02, 0.02, 0.02)
	else:
		%LabelTitle.text = tr(titleKey)
	
	setDescription(hint)
	
	
	find_child("CollisionShape2D").shape = RectangleShape2D.new()
