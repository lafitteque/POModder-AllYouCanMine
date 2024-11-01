extends Node2D

var stage = null
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements
@onready var saver = get_node("/root/ModLoader/POModder-AllYouCanMine").saver


func _on_timer_timeout():
	if !stage or StageManager.currentStage.name != stage.name:
		stage_changed()
		
func stage_changed():
	stage = StageManager.currentStage
	#await get_tree().create_timer(1)
	saver.change_stage()
	custom_achievements_manager.change_stage(stage.name)
	match stage.name:
		"MultiplayerLoadoutStage":
			#StageManager.sceneCache["stages/loadout/multiplayerloadoutmod"] = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutStageMod.tscn")
			StageManager.startStage("mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutMod")
		

