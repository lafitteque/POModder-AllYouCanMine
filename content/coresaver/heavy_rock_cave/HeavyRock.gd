extends Sprite2D

var taken := false

func _ready():
	Style.init(self)

func canFocusUse(keeper:Keeper) -> bool:
	return not taken

func useHold(keeper:Keeper) -> bool:
	return useHit(keeper)

func useHit(keeper:Keeper) -> bool:
	if taken:
		return false
	taken = true
	
	var drop = preload("res://mods-unpacked/POModder-AllYouCanMine/content/coresaver/heavy_rock_cave/heavy_rock_drop.tscn").instantiate()
	drop.position = global_position
	Level.map.addDrop(drop)
	keeper.attachCarry(drop)
	queue_free()
	return true
