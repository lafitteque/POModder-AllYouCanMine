extends Node2D

var keeperId = "player1"

var level1 : float
var level2 : float

var level1bar
var level2bar

# Called when the node enters the scene tree for the first time.
func _ready():
	level1 = Data.ofOr(keeperId + ".excavator.boomHeight1", 300.0)
	level2 = Data.ofOr(keeperId + ".excavator.boomHeight2", 500.0)
	level1bar = $Background/Level1
	level2bar = $Background/Level2
	Data.listen(self, keeperId + ".excavator.fallIndicator")
	var hasIndicator = Data.ofOr(keeperId + ".excavator.fallIndicator", false)
	visible = hasIndicator
	set_physics_process(hasIndicator)
	
func propertyChanged(property : String, oldValue, newValue):
	var fallVisible = keeperId + ".excavator.fallindicator"
	match property:
		fallVisible:
			visible = true
			set_physics_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if  not $RayCast2D.is_colliding() :
		level1bar.value = 1.0
		level2bar.value = 1.0
		return
		
	var heightFall = to_local($RayCast2D.get_collision_point()).y
	var minBoomHeight = Data.of(keeperId + ".excavator.minBoomHeight")
	if heightFall <= minBoomHeight :
		level1bar.value = 0.0
		level2bar.value = 0.0
	elif heightFall < level1 :
		level1bar.value = 0.5
		level2bar.value = 0.0
	elif heightFall - level1 < (level2 - level1)/2 :
		level1bar.value = 1.0
		level2bar.value = 0.0
	else :
		level1bar.value = 1.0
		level2bar.value = 1.0
