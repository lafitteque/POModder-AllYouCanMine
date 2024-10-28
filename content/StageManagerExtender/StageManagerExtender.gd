extends Node2D

var stage = null
@onready var stage_manager = get_parent()
@onready var custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements

func _ready():
	print("ready , ", stage_manager.name)

func _on_timer_timeout():
	if !stage or stage_manager.currentStage.name != stage.name:
		stage_changed()
		
func stage_changed():
	stage = stage_manager.currentStage
	custom_achievements_manager.change_stage(stage.name)
	print("state changed , " , stage.name)
	await get_tree().create_timer(1)
	match stage.name:
		"MultiplayerLoadoutStage":
			print("Ask for change stage")
			#StageManager.sceneCache["stages/loadout/multiplayerloadoutmod"] = preload("res://mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutStageMod.tscn")
			StageManager.startStage("mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutMod")
			print("multiplayerloadoutMod Loaded")


