extends Node2D

var stage = null
var data_mod

func _ready():
	StageManager.stage_started.connect(stage_changed)

		
func stage_changed():
	data_mod = get_node("/root/ModLoader/POModder-Dependency").data_mod
	await get_tree().create_timer(0.3).timeout
	stage = StageManager.currentStage
	
	if stage.name != "LevelStage":
		Engine.time_scale = 1
		
