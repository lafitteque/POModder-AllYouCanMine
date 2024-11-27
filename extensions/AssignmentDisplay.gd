extends "res://stages/loadout/AssignmentDisplay.gd"

func setAssignment(id:String, isChallengeMode := false):
	super.setAssignment(id,isChallengeMode)
	if ! assignment :
		return
	if ! (assignment.goalvalue is PropertyCheck):
		return
	
	if assignment.goalvalue.property_key.ends_with("remainingtiles"):
		%GoalLabel.text = tr("assignment.goaltype.mineall")
		
	if  assignment.goalvalue.property_key.begins_with("game.time"):
		var value = ( int( (assignment.goalvalue.expected_value - 1 ) /60) + 1)
		%GoalLabel.text = tr("assignment.goaltype.gametime") % value
