extends Container

var isIn := false
var animationDone := false

func init():
	if GameWorld.won or GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION:
		find_child("KeepGadgetPopup").visible = false
	else:
		find_child("KeepGadgetPopup").init()
		
	if GameWorld.won:
		find_child("TitleLabel").text = "level.gameover.win.title"
	else:
		find_child("TitleLabel").text = "level.gameover.lose.title"

	if GameWorld.won and GameWorld.unlockableElements.size() > 0 and GameWorld.buildType != CONST.BUILD_TYPE.EXHIBITION:
		find_child("MainMenuButton").visible = false
		find_child("AnotherRunButton").visible = false
		find_child("UnlockElementButton").visible = true
	else:
		find_child("MainMenuButton").visible = true
		find_child("AnotherRunButton").visible = true
		find_child("UnlockElementButton").visible = false
	
	find_child("RunStats").init(self)
	
	if not Data.ofOr("postrun.showmine", false):
		find_child("MineViewButton").visible = false
	
	Style.init(self)

func updateFocus():
	var fo = find_child("KeepGadgetPopup").getFirstOption()
	var ueb = find_child("UnlockElementButton")
	if fo:
		InputSystem.grabFocus(fo)
	elif ueb and ueb.visible:
		InputSystem.grabFocus(ueb)
	else:
		InputSystem.grabFocus(find_child("AnotherRunButton"))

func moveIn():
	if isIn:
		return
	
	GameWorld.setShowMouse(Options.useMouseMenus)
	isIn = true
	$Tween.stop_all()
	$Tween.remove_all()
	$Tween.interpolate_property(self, "position:y", position.y, (get_viewport_rect().size.y-size.y)*0.5, 1.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_callback(self, 1.3, "set", "animationDone", true)
	$Tween.interpolate_callback(self, 2.5, "updateFocus")
	$Tween.start()

func _on_MainMenuButton_pressed():
	if isIn:
		continuePressed()
		if GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION:
			StageManager.startStage("stages/loadout/multiplayerloadout")
		else:
			StageManager.startStage("stages/title/title")

func _on_AnotherRunButton_pressed():
	if isIn:
		continuePressed()
		if GameWorld.buildType == CONST.BUILD_TYPE.EXHIBITION:
			StageManager.startStage("stages/loadout/multiplayerloadout")
		else:
			StageManager.startStage("stages/loadout/multiplayerloadout")

func _on_MineViewButton_pressed():
	if isIn:
		Level.stage.startMineView()

func continuePressed():
	Audio.stopMusic()
	Audio.sound("gui_select")
	find_child("MainMenuButton").disabled = true
	find_child("AnotherRunButton").disabled = true
	find_child("MineViewButton").disabled = true
	SaveGame.persistMetaState()

func _on_UnlockElementButton_pressed():
	Audio.sound("gui_select")
	var i = preload("res://gui/PopupInput.gd").new()
	var unlockablesPopup = preload("res://content/gamemode/unlockables/UnlockablesPopup.tscn").instantiate()
	unlockablesPopup.connect("proceed", i.desintegrate)
	unlockablesPopup.connect("back", i.desintegrate)
	unlockablesPopup.connect("back", updateFocus)
	unlockablesPopup.connect("back", unlockablesPopup.queue_free)
	get_parent().add_child(unlockablesPopup)
	i.popup = unlockablesPopup
	i.integrate(Level.stage)

func focusMineViewButton():
	InputSystem.grabFocus(find_child("MineViewButton"))
