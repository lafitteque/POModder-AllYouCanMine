extends HudElement

var originY = -2

func init():
	super.init()
	Data.listen(self, "player1.excavator.fillRatio") #playerId + ".excavator.crusherFillRatio")
	
func propertyChanged(property:String, oldValue, newValue):
	var crusherFilling = "player1.excavator.fillratio" #playerId + ".excavator.fillRatio"
	var crusherCount = "player1.excavator.crushercount" #playerId + ".excavator.fillRatio"
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
