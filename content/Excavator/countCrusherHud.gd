extends HudElement


func init():
	super.init()
	Data.listen(self, "player1.excavator.fillRatio") #playerId + ".excavator.crusherFillRatio")
	
func propertyChanged(property:String, oldValue, newValue):
	var crusherFilling = "player1.excavator.fillratio" #playerId + ".excavator.fillRatio"
	var crusherCount = "player1.excavator.crushercount" #playerId + ".excavator.fillRatio"
	match property:
		crusherFilling:
			$UiPlaceCrusher.region_rect.position.y = 0
			$UiPlaceCrusher.region_rect.size.y = round(newValue*14.0)
		crusherCount:
			$UiPlaceCrusher.region_rect.position.y = 0
			$UiPlaceCrusher.region_rect.size.y = round(newValue*14.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
