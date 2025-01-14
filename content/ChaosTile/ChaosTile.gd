extends Node2D

var used = false
var timer_label : Timer
var effect_list 
var label_duration = 3.0
var should_queue_free = false
var animation_finished = false

@onready var default_gravity_vector = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
@onready var data_mod = get_node("/root/ModLoader/POModder-Dependency").data_mod

# Called when the node enters the scene tree for the first time.
func _ready():
	effect_list= data_mod.chaos_effects
	set_physics_process(false)
	
	
func activate():
	if used :
		return
	
	
	var label = preload("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/chaos_label.tscn").instantiate()
	var effect_name = effect_list[randi() % effect_list.size()]
	var effect = load("res://mods-unpacked/POModder-AllYouCanMine/content/ChaosTile/effect_" + effect_name + ".tscn").instantiate()
	
	StageManager.get_parent().add_child(label)
	label.text = tr("chaos."+effect_name)
	var pos_offsets = [Vector2(100,50), Vector2(100,-50), 
	Vector2(-100,50), Vector2(-100,-50),
	Vector2(100,100), Vector2(100,-100), 
	Vector2(-100,100), Vector2(-100,-100)]
	label.global_position += pos_offsets[randi_range(0,7)]
	add_child(effect)
	for c in get_children():
		print(c.name)
	effect.activate()
	used = true
	await get_tree().create_timer(0.1).timeout
	$activation/AnimationPlayer.play("activate")
	
	
	
func request_queue_free():
	set_physics_process(true)
	should_queue_free = true


func _physics_process(delta):
	if animation_finished and should_queue_free:
		queue_free()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "activate":
		$activation/AnimationPlayer.play("RESET")
		animation_finished = true
	

