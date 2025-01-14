extends "res://stages/loadout/AssignmentDisplay.gd"

func setAssignment(id:String, isChallengeMode := false):
	super.setAssignment(id,isChallengeMode)
	Data.apply("chosenAssignment", assignment)
	if ! assignment :
		return
	if ! (assignment.goalvalue is PropertyCheck):
		return
	
	var conditionStrings := {}
	
	if assignment.freeGadgets > 0:
		var str = "assignment.condition.freegadget.plural" if  assignment.freeGadgets > 1 else "assignment.condition.freegadget.singular"
		conditionStrings[str] = assignment.freeGadgets
	
	if assignment.goalvalue.property_key.ends_with("remainingtiles"):
		%GoalLabel.text = tr("assignment.goaltype.mineall")
	

	if "worldmodifierspeed" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.speed"] = 0
	if "worldmodifierbigdrops" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.bigdrops"] = 0
	if "worldmodifiersmalldrops" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.smalldrops"] = 0
	if "worldmodifierautonomous" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.autonomous"] = 0
	if "worldmodifierpyromaniac" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.pyromaniac"] = 0
	if "worldmodifiersuperhot" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.superhot"] = 0
	if "worldmodifiernomonsters" in assignment.worldModifiers:
		conditionStrings["assignment.worldmodifier.nomonsters"] = 0
				
	if  assignment.goalvalue.property_key.begins_with("game.time"):
		var value = ( int( (assignment.goalvalue.expected_value - 1 ) /60) + 1)
		%GoalLabel.text = tr("assignment.goaltype.gametime") % value

	var changesToDisplay := [assignment.propertyChanges]
	if isChallengeMode:
		changesToDisplay.append(assignment.challengePropertyChanges)
	for changeArray in changesToDisplay:
		for propertyChange:PropertyChange in changeArray:
			match propertyChange.key:
				"monsters.additionalwaveweight":
					conditionStrings["properties.monsters.additionalstartweight"] = propertyChange.value
				"run.durationcycles":
					conditionStrings["assignment.condition.duration"] = propertyChange.value
				"game.fixedtimelimit":
					conditionStrings["properties.game.fixedtimelimit"] = propertyChange.value
				"monstermodifiers.totalrunweightmodifier":
					conditionStrings["properties.monstermodifiers.totalrunweightmodifier"] = propertyChange.value
				"monsters.waveinterval":
					conditionStrings["properties.monsters.waveinterval"] = propertyChange.value
				"monsters.fixedweight":
					conditionStrings["properties.monsters.fixedweight"] = propertyChange.value
				"monsters.finalwavefixedstrength":
					conditionStrings["properties.monsters.finalwavefixedstrength"] = propertyChange.value
					#### NEW VALUES
				"inventory.iron":
					conditionStrings["properties.inventory.iron"] = propertyChange.value
				"inventory.water":
					conditionStrings["properties.inventory.water"] = propertyChange.value
				"inventory.sand":
					conditionStrings["properties.inventory.sand"] = propertyChange.value	
				"game.debtcooldown":
					conditionStrings["properties.game.debtcooldown"] = propertyChange.value
				"game.debt":
					conditionStrings["properties.game.debt"] = propertyChange.value
	#find_child("SpacerChallengeMode").visible = %ButtonChallenge.is_visible_in_tree()
	
	var txt = ""
	for key in conditionStrings:
		if txt != "":
			txt += "\n"
		var string = tr(key)
		if string.find("{") >= 0:
			if string.find("{.percent}") >= 0:
				txt += string.replace("{.percent}", str(conditionStrings[key] * 100) + "%")
			else:
				txt += string.replace("{}", str(conditionStrings[key]))
		elif string.find("%") >= 0:
			txt += string % conditionStrings[key]
		else:
			txt += string
	
	if txt == "":
		%Conditions.visible = false
	else:
		%Conditions.visible = true
		%ConditionValueLabel.text = txt
	
