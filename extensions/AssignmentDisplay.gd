extends "res://stages/loadout/AssignmentDisplay.gd"


func setAssignment(id:String, isChallengeMode := false):
	super.setAssignment(id,isChallengeMode)
	if assignment and assignment.goalvalue is PropertyCheck and assignment.goalvalue.property_key.ends_with("remainingtiles"):
		%GoalLabel.text = tr("assignment.goaltype.mineall")
