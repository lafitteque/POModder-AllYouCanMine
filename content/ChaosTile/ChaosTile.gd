extends Node2D

var used = false
var timer_label : Timer
var effect_list 
var label_duration = 3.0

@onready var default_gravity_vector = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod

# Called when the node enters the scene tree for the first time.
func _ready():
	effect_list= data_mod.chaos_effects
	
func activate():
	if used :
		return
	
	var label = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/chaos_label.tscn").instantiate()
	var effect_name = effect_list[randi() % effect_list.size()]
	var effect = load("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/effect_" + effect_name + ".tscn").instantiate()
	
	StageManager.get_parent().add_child(label)
	label.text = tr("chaos."+effect_name)
	#label.global_position = global_position
	print(tr("chaos."+effect_name) , "activated")
	
	add_child(effect)
	effect.activate()
	used = true
	
	
	
	
func kill():
	queue_free()

