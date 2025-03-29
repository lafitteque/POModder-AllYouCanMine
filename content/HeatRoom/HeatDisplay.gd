extends Container

var isChallengeMode := false
var assignment:Assignment
var assignmentCopy = []

var buttonMinusList = []
var buttonPlusList = []

var cobaltReduction = 0
var weight = 0
var multiplier = 1
var cooldown = -1

var originalMultiplier 
var originalWeight 
var originalCooldown
var originalDebtValue = 0
var originalIronValue = 0


var initialCooldown = 30
var mod_main


func _ready():
	mod_main = get_node("/root/ModLoader/POModder-AllYouCanMine")
	Data.apply("game.cobaltmultiplier", 0.0)
	
	for c in $MarginContainer/VBoxContainer.get_children():
		if c is HBoxContainer:
			for button in c.get_children():
				if button is PanelContainer:
					if button.name.ends_with("Minus"):
						buttonMinusList.append(button)
					elif button.name.ends_with("Plus"):
						buttonPlusList.append(button)
	
	Style.init(self)
	
	$MarginContainer/VBoxContainer/Reset.find_child("LabelTitle",true,true).text = tr("heat.reset")
	
	for button in buttonMinusList:
		button.find_child("LabelTitle",true,true).text = "-"
		button.find_child("SelectedPanel",true,true).visible = false
	for button in buttonPlusList:
		button.find_child("LabelTitle",true,true).text = "+"
		button.find_child("SelectedPanel",true,true).visible = false

	Data.listen(self,"chosenAssignment")
	Data.listen(self,"loadout.modeid")
	
	if GameWorld.assignmentProgress.values().filter(func(x) : return x>0).size() <= 16 :
		visible = false
	else :
		visible = true
		
func propertyChanged(property : String, old_value, new_value):
	if property == "loadout.modeid" and new_value == "prestige":
		visible = false
	else :
		visible = true
	
	if property == "chosenAssignment" and !new_value:
		return
	
	reset()

	mod_main.heatProperties = []
	originalMultiplier = -1
	originalWeight = -1
	originalCooldown = -1
	initialCooldown = -1
	originalDebtValue = 0
	originalIronValue = 0
	
	if property == "chosenassignment" :
		if new_value != old_value and old_value!= null:
			Data.assignments[old_value.id].challengePropertyChanges = []
			for prop in assignmentCopy:
				var rewriteProp = PropertyChange.new()
				rewriteProp.keyName = prop[0]
				rewriteProp.keyClass = prop[1]
				rewriteProp.value = prop[2]
				rewriteProp.key = rewriteProp.keyClass  + "." + rewriteProp.keyName
				Data.assignments[old_value.id].challengePropertyChanges.append(rewriteProp)

		assignmentCopy = []
		print("ID copié : " ,new_value.id)
		for prop in Data.assignments[new_value.id].challengePropertyChanges:
			assignmentCopy.append([prop.keyName, prop.keyClass, prop.value])
			var keyname = prop.keyName
			match prop.keyName:
				"totalrunweightmodifier":
					multiplier = prop.value
					originalMultiplier = multiplier
				"additionalwaveweight":
					weight = prop.value
					originalWeight = weight
				"debtcooldown":
					cooldown = prop.value
					originalCooldown = cooldown
				"debt":
					originalDebtValue = prop.value
				"iron":
					originalIronValue = prop.value
					
			assignment = Data.assignments[new_value.id]
		for prop in new_value.challengePropertyChanges:
			if prop.keyName == "debtcooldown":
				initialCooldown = prop.value
		
		
	if initialCooldown < 0:
		initialCooldown = 30

	resetDisplay()
	
	
func _on_reset_pressed():
	reset()
	resetDisplay()
	_on_cobalt_minus()
	_on_cooldown_plus()
	_on_multiplier_minus()
	_on_weight_minus()
	
	
func reset():
	weight = 0
	cobaltReduction = 0
	cooldown = -1
	multiplier = 1

func resetDisplay():
	updateCobalt()
	updateWeight()
	updateMultiplier()
	updateCooldown()	
	if Data.ofOr("loadout.modeId","") == "assignments":
		$MarginContainer/VBoxContainer/HBoxContainer6/DescriptionLabel.text = tr("loadout.heat.descassignment")
	else:
		$MarginContainer/VBoxContainer/HBoxContainer6/DescriptionLabel.text = tr("loadout.heat.desc")


func _on_cobalt_minus():
	$SfxChooseRegular.play()
	cobaltReduction = clamp(cobaltReduction - 0.1, 0, 1)
	updateCobalt()
	changePropertyValue("cobaltmultiplier", "game", cobaltReduction)

func _on_cobalt_plus():
	$SfxChooseChallenge.play()
	cobaltReduction = clamp(cobaltReduction + 0.1, 0, 1)
	updateCobalt()
	changePropertyValue("cobaltmultiplier", "game", cobaltReduction)

	
func updateCobalt():
	var text = " -" + str(int(cobaltReduction*100)) + "%"
	%Cobalt.text = text


func _on_weight_plus():
	$SfxChooseChallenge.play()
	weight += 10
	updateWeight()
	changePropertyValue("additionalwaveweight", "monsters", weight)
	
func _on_weight_minus():
	$SfxChooseRegular.play()
	var weightMinimum = max(0,originalWeight)
	weight = max(weightMinimum,int(weight - 10))
	updateWeight()
	changePropertyValue("additionalwaveweight", "monsters", weight)
	
func updateWeight():
	var text = " +" + str(int(weight)) 
	%Weight.text = text
	
func _on_multiplier_plus():
	$SfxChooseChallenge.play()
	multiplier += 0.1
	updateMultiplier()
	changePropertyValue("totalrunweightmodifier", "monstermodifiers", multiplier)
	
func _on_multiplier_minus():
	$SfxChooseRegular.play()
	var multiplierMinimum = max(1.0,originalMultiplier)
	multiplier = max(multiplierMinimum, multiplier - 0.1)
	updateMultiplier()
	changePropertyValue("totalrunweightmodifier", "monstermodifiers", multiplier)
	
func updateMultiplier():
	var text = str(round(multiplier*100)) + "%"
	%Multiplier.text = text
	
	
func _on_cooldown_minus():
	$SfxChooseRegular.play()
	
	if cooldown == -1:
		cooldown = initialCooldown 
	cooldown = max(10, int(cooldown - 2))
	
	updateCooldown()
	changePropertyValue("debtcooldown", "game", cooldown)
	if cooldown > 0:
		changePropertyValue("debt", "game", max(1, originalDebtValue))
		changePropertyValue("iron", "inventory", max(2, originalIronValue))
		
func _on_cooldown_plus():
	$SfxChooseChallenge.play()
	var cooldownMaximum 
	if originalCooldown == -1:
		cooldownMaximum = 70
	else :
		cooldownMaximum = originalCooldown
	if cooldown > 0:
		cooldown = min(cooldown + 2, cooldownMaximum)
	if cooldown > 60:
		cooldown = -1
		
	if cooldown < 0 :
		changePropertyValue("debt", "game", null)
	else :
		changePropertyValue("debt", "game", max(1, originalDebtValue))
		changePropertyValue("iron", "inventory", max(2, originalIronValue))
	updateCooldown()
	changePropertyValue("debtcooldown", "game", cooldown)

func updateCooldown():
	var text = str(int(cooldown)) + "s"
	if cooldown < 0 :
		text = " / "
	%Debt.text = text

func changePropertyValue(keyName, keyClass, value):
	if Level.loadout.modeId == "assignments":
		changePropertyValueAssignment(keyName, keyClass, value)
	elif Level.loadout.modeId != "prestige":
		changePropertyValueMainMode(keyName, keyClass, value)


func changePropertyValueMainMode(keyName, keyClass, value):
	var props = mod_main.heatProperties
	if value == null :
		for prop in props:
			if prop.keyName == keyName:
				props.erase(prop)
		mod_main.heatProperties = props
		return
		
	var propInList = false
	for prop in props:
		if prop.keyName == keyName:
			prop.value = value
			propInList = true

	if !propInList:
		var newProp = PropertyChange.new()
		newProp.key = keyClass  + "." +keyName
		newProp.keyClass = keyClass
		newProp.keyName = keyName
		newProp.value = value
		props.append(newProp)
	mod_main.heatProperties = props
	print("property changed : ", keyName, " to ", value)
	
func changePropertyValueAssignment(keyName, keyClass, value):
	if !assignment :
		return
		
	if value == null :
		for prop in Data.assignments[assignment.id].challengePropertyChanges:
			if prop.keyName == keyName:
				Data.assignments[assignment.id].challengePropertyChanges.erase(prop)
		return
		
	var propInList = false
	for prop in Data.assignments[assignment.id].challengePropertyChanges:
		if prop.keyName == keyName:
			prop.value = value
			propInList = true

	if !propInList:
		var newProp = PropertyChange.new()
		newProp.key = keyClass  + "." + keyName
		newProp.keyClass = keyClass
		newProp.keyName = keyName
		newProp.value = value
		Data.assignments[assignment.id].challengePropertyChanges.append(newProp)

func _exit_tree():
	Data.unlisten(self,"chosenAssignment")
	Data.unlisten(self,"loadout.modeid")
