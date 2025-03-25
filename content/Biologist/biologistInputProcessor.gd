extends "res://content/keeper/KeeperInputProcessor.gd"

var pickupKeyDown := false
var pickupHold := false
var pickupKeyDownTime := 0.0
var pickupKeyCooldown := 0.0

var dropKeyDown := false
var dropHold := false
var dropKeyDownTime := 0.0
var dropKeyCooldown := 0.0

var pickHoldOverlap := false
var pickupDropMode := 0 # 0= nothin, 1=pickup, 2=drop

func _process(delta):
	super._process(delta)
	if GameWorld.paused or desintegrating:
		return
	
	if pickupKeyDown and not useHoldHandled:
		pickupKeyDownTime += delta
		if pickupKeyDownTime > 0.3:
			if pickHoldOverlap:
				match pickupDropMode:
					0:
						if keeper.focussedCarryable:
							pickupDropMode = 1
							keeper.pickupHold()
						elif keeper.carriedCarryables.size() > 0:
							pickupDropMode = 2
							keeper.dropHold()
					1:
						keeper.pickupHold()
					2:
						keeper.dropHold()
			else:
				keeper.pickupHold()
			pickupHold = true
			# intentional getting shorter
			pickupKeyDownTime -= pickupKeyCooldown
			pickupKeyCooldown = max(0.06, pickupKeyCooldown * 0.6)
	else:
		pickupKeyCooldown = 0.25
	
	if dropKeyDown and not pickHoldOverlap:
		dropKeyDownTime += delta
		if dropKeyDownTime > 0.3:
			keeper.dropHold()
			dropHold = true
			# intentional getting shorter
			dropKeyDownTime -= dropKeyCooldown
			dropKeyCooldown = max(0.05, dropKeyCooldown * 0.6)
	else:
		dropKeyCooldown = 0.25


func clearInput():
	super.clearInput()
	pickupKeyDown = false
	pickupHold = false

func keeperButtonEvent(event, handled:bool):
	
	if keeper and keeper.disabled and justPressed(event, "keeper1_drop"):
		keeper.useTryCancelDisable()
		return
	
	if justPressed(event, "keeper1_pickup"):
		pickHoldOverlap = InputMap.event_is_action(event, "keeper1_pickup") and InputMap.event_is_action(event, "keeper1_drop")
		pickupKeyDownTime = 0.0
		pickupKeyDown = true
	elif justPressed(event, "keeper1_drop"):
		dropKeyDownTime = 0.0
		dropHold = false
		dropKeyDown = true

	if released(event, "keeper1_pickup"):
		if pickupKeyDown:
			pickupDropMode = 0
			pickupKeyDown = false
			if pickupHold:
				keeper.pickupHoldStopped()
				pickupHold = false
			elif not handled and not GameWorld.paused and not useHoldHandled:
				if pickHoldOverlap:
					if keeper.focussedCarryable:
						keeper.pickupHit()
					else:
						keeper.dropHit()
				else:
					keeper.pickupHit()
				pickupKeyDownTime = 0.0
	elif released(event, "keeper1_drop"):
		if dropKeyDown:
			dropKeyDown = false
			if not handled and not dropHold and not GameWorld.paused:
				keeper.dropHit()
				dropKeyDownTime = 0.0

func becameLeaf():
	super.becameLeaf()
	GameWorld.setShowMouse(runningInLoadout and Options.useMouseMenus)
	InputSystem.changeCursor("default")
