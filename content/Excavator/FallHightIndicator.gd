extends Node2D

var level1 : float
var level2 : float

var level1bar
var level2bar

# Called when the node enters the scene tree for the first time.
func _ready():
	level1 = Data.ofOr("excavator.boomHeight1", 300.0)
	level2 = Data.ofOr("excavator.boomHeight2", 500.0)
	level1bar = $Background/Level1
	level2bar = $Background/Level2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if  not $RayCast2D.get_collision_point() :
		level1bar.value = 1.0
		level2bar.value = 1.0
		return
		
	var heightFall = to_local($RayCast2D.get_collision_point()).y
	if heightFall <= level1/2 :
		level1bar.value = 0.0
		level2bar.value = 0.0
	elif heightFall < level1 :
		level1bar.value = 0.5
		level2bar.value = 0.0
	elif heightFall - level1 < (level2 - level1)/2 :
		level1bar.value = 1.0
		level2bar.value = 0.0
	elif heightFall < level2 :
		level1bar.value = 1.0
		level2bar.value = 0.5
	else :
		level1bar.value = 1.0
		level2bar.value = 1.0
