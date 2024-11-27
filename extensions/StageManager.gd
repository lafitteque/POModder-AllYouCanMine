extends "res://stages/manager/StageManager.gd"


func startStage(stageName:String, data:Array=[], tabula:bool = true):
	if stageName == "stages/loadout/multiplayerloadout":
		stageName = "mods-unpacked/POModder-AllYouCanMine/stages/MultiplayerloadoutMod"
	super(stageName, data, tabula)
