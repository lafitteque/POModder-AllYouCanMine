extends "res://content/map/chamber/Chamber.gd"

signal relic_taken

var shouldOpen := false

var stingerId:String

const TILE_BAD_RELIC = 14


func _ready():
	super._ready()
	$SpriteBack.visible = false
	$SpriteBack/SpriteFront.play("closed")
	$SpriteBack.play("running")
	chamberType = TILE_BAD_RELIC
	currentState = State.HIDDEN

func deserialize(data: Dictionary):
	super.deserialize(data)
	if currentState == State.REVEALED:
		pass
	if currentState == State.OPEN or currentState == State.OPENING or currentState == State.EMPTY:
		$Light3D.light_active = true
		$SpriteBack.show()
		$SpriteBack/SpriteFront.play("opening")
		$SpriteBack/SpriteFront.frame = $SpriteBack/SpriteFront.sprite_frames.get_frame_count("opening")-1
		
func propertyChanged(property:String, oldValue, newValue):
	pass

func _process(delta):
	if shouldOpen:
		for keeper in Keepers.getAll():
			if keeper.global_position.distance_to(global_position) < GameWorld.TILE_SIZE * 8:
				open()
				shouldOpen = false
				return

func open():
	currentState = State.OPENING
	$TileCover.queue_free()
	for c in tileCoords:
		Level.map.removeTileDestroyedListener(self, coord + Vector2(c))
	onOpening()
	Backend.event("chamber", {"status": "opened", "coord":tileCoords, "type": type})


func onExcavated():
	open()


func onOpening():
	$SpriteBack/SpriteFront.play("opening")
	
func onRevealed():
	$SpriteBack.visible = true
	$GizmoSpawn/ChamberAmb.play()

func onUsed():
	$DoorOpen.queue_free()
	$Usable.queue_free()
	$GizmoSpawn.queue_free()
	$Light3D.light_active = false
	$SpriteBack.play("empty")
	$GizmoSpawn/ChamberAmb.stop()

	Data.apply("map.relictaken", true)
	emit_signal("relic_taken")


func _on_SpriteFront_frame_changed():
	if $SpriteBack/SpriteFront.animation == "opening":
		if $SpriteBack/SpriteFront.frame == 01:
			$DoorOpen.play()
		elif $SpriteBack/SpriteFront.frame == 50:
			$Light3D.light_active = true
			if stingerId == "":
				stingerId = "stinger_relic_chamber_excavated_" + Audio.get_closest_keeperId_or_music_override(position)
			Audio.stinger(stingerId)
		elif $SpriteBack/SpriteFront.frame == 65:
			currentState = State.OPEN

func addCable(cable):
	$SpriteBack/SpriteFront.add_child(cable)
	cable.centerOffset = 36

func getTileType() -> int:
	return TILE_BAD_RELIC

