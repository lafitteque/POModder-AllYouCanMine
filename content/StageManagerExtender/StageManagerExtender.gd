extends Node2D

var stage = null
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements
@onready var saver = get_node("/root/ModLoader/POModder-AllYouCanMine").saver
@onready var data_mod = get_node("/root/ModLoader/POModder-AllYouCanMine").data_mod

func _ready():
	StageManager.stage_started.connect(stage_changed)

		
func stage_changed():
	await get_tree().create_timer(0.3).timeout
	stage = StageManager.currentStage
	saver.change_stage()
	custom_achievements_manager.change_stage(stage.name)
	
	if stage.name != "LevelStage":
		Engine.time_scale = 1
		
	match stage.name:
		"LandingSequence":
			data_mod.update_generation_data(stage.levelStartData.mapArchetype)
