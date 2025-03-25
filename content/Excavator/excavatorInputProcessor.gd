extends "res://content/keeper/KeeperInputProcessor.gd"

var pickupKeyDown := true
var pickupHold := false
var pickupKeyDownTime := 0.0
var pickupKeyCooldown := 0.0

var dropKeyDown := false
var dropHold := false
var dropKeyDownTime := 0.0
var dropKeyCooldown := 0.0

var pickHoldOverlap := false
var pickupDropMode := 0 # 0= nothin, 1=pickup, 2=drop

## Modded var
var pickupKeyDownMax = 2.0 
var realPichupKeyDown = false
var realPichupKeyDownTime = 0.0

func _process(delta):
	super._process(delta)
	if GameWorld.paused or desintegrating:
		return
	
	if realPichupKeyDown :
		realPichupKeyDownTime += delta
		keeper.holdCollect = true
		if realPichupKeyDownTime >= pickupKeyDownMax :
			keeper.addCrusher()
		if realPichupKeyDownTime <= 0.3:
			keeper.holdCollect = false
		
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
			elif is_instance_valid(keeper):
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
	pickupKeyDown = true
	pickupHold = false

func keeperButtonEvent(event, handled:bool):
	
	if keeper and keeper.disabled and justPressed(event, "keeper1_drop"):
		keeper.useTryCancelDisable()
		return
	
	if justPressed(event, "keeper1_pickup"):
		pickHoldOverlap = InputMap.event_is_action(event, "keeper1_pickup") and InputMap.event_is_action(event, "keeper1_drop")
		pickupKeyDownTime = 0.0
		pickupKeyDown = true
		realPichupKeyDown = true
		realPichupKeyDownTime = 0.0
	
	elif released(event, "keeper1_pickup"):
		realPichupKeyDown = false
		realPichupKeyDownTime = 0.0
		if keeper and ("holdCollect" in keeper):
			keeper.holdCollect = false
		
	elif justPressed(event, "keeper1_drop"):
		dropKeyDownTime = 0.0
		dropHold = false
		dropKeyDown = true

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
		pickupKeyDown = true

func becameLeaf():
	super.becameLeaf()
	GameWorld.setShowMouse(runningInLoadout and Options.useMouseMenus)
	InputSystem.changeCursor("default")
