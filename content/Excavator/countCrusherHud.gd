extends HudElement

var keeperId = "player1"
var originY = -2

func init():
	super.init()
	

func _ready():
	var crusherFilling = Data.ofOr(keeperId + ".excavator.fillratio", 0.0)
	var rel = round(crusherFilling*14)
	$UiPlaceCrusher.region_rect.size.y = rel
	$UiPlaceCrusher.region_rect.position.y = 14 - rel
	$UiPlaceCrusher.position.y =  originY +  $UiPlaceCrusher.region_rect.position.y
	Data.listen(self, keeperId + ".excavator.fillRatio") #playerId + ".excavator.crusherFillRatio")
	
func propertyChanged(property:String, oldValue, newValue):
	var crusherFilling = keeperId + ".excavator.fillratio" #playerId + ".excavator.fillRatio"
	var crusherCount = keeperId + ".excavator.crushercount" #playerId + ".excavator.fillRatio"
	match property:
		crusherFilling:
			var rel = round(newValue*14)
			$UiPlaceCrusher.region_rect.size.y = rel
			$UiPlaceCrusher.region_rect.position.y = 14 - rel
			$UiPlaceCrusher.position.y =  originY +  $UiPlaceCrusher.region_rect.position.y
		crusherCount:
			var rel = round(newValue*14)
			$UiPlaceCrusher.region_rect.size.y = rel
			$UiPlaceCrusher.region_rect.position.y = 14 - rel
			$UiPlaceCrusher.position.y = originY +  $UiPlaceCrusher.region_rect.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
