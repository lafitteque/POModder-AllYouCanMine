extends Node2D

var save_path = "res://save_AllYouCanMine.save"

var saver_progress_id = "keeper_and_dome_progress"
var saver_id = "custom_achievements"

var custom_achievements_manager

var save_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data() 
	# Prepare save_dict if first time
	if ! save_dict.has(saver_progress_id):
		save_dict[saver_progress_id] = {}
	for keeperId in Data.loadoutKeepers: 
		if !save_dict[saver_progress_id].has(keeperId):
			save_dict[saver_progress_id][keeperId] = {}
		for dome in Data.loadoutDomes:
			if !save_dict[saver_progress_id][keeperId].has(dome):
				save_dict[saver_progress_id][keeperId][dome] = {}
	save_data()
	
func change_stage():
	custom_achievements_manager = get_node("/root/ModLoader/POModder-AllYouCanMine").custom_achievements
	Data.listen(self, "game.over")
	update_progress_achievements()
	
func propertyChanged(property:String, oldValue, newValue):
	print("property changed : " , property ," ; ", oldValue , " ; " , newValue)
	Data.listen(self, "game.over")
	match property:
		"game.over":
			if Level and Level.dome != null and Data.ofOr("game.over","") == "won":
				print("save data game.over")
				var keeperId = Level.loadout.keepers.front().keeperId
				var mapsize = Level.loadout.modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "")
				match Level.loadout.difficulty:
					-2 :
						save_dict[saver_progress_id][keeperId][Level.domeId()][mapsize] = 1
					-1 :
						save_dict[saver_progress_id][keeperId][Level.domeId()][mapsize] = 2
					0 :
						save_dict[saver_progress_id][keeperId][Level.domeId()][mapsize] = 3
					2 :
						save_dict[saver_progress_id][keeperId][Level.domeId()][mapsize] = 4
				save_data()
				# Game Duration : GameWorld.runTime
				# Inventory : Data.of(inventory.")
				#print("dome name : " , Level.domeId())
				#save_dict[saver_progress_id][]

		
func load_data():
	var file = FileAccess.open(save_path,FileAccess.READ)
	if !file :
		save_data()
		file = FileAccess.open(save_path,FileAccess.READ)
	save_dict = file.get_var()
	file.close()


func save_data():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(save_dict)
	file.close()

func _exit_tree():
	Data.unlisten(self,"game.over")

func update_progress_achievements():
	#await get_tree().create_timer(1).timeout
	var domes_completed = 0
	for dome in Data.loadoutDomes.slice(0, 4) :
		domes_completed += min(1 , save_dict[saver_progress_id][Data.loadoutKeepers[0]][dome].keys().size())
	if domes_completed == 4:
		custom_achievements_manager.unlockAchievement("ALL_DOMES_ENGINEER")
		
	domes_completed = 0
	for dome in Data.loadoutDomes.slice(0, 4) :
		domes_completed += min(1 , save_dict[saver_progress_id][Data.loadoutKeepers[1]][dome].keys().size())
	if domes_completed == 4:
		custom_achievements_manager.unlockAchievement("ALL_DOMES_ASSESSOR")		
