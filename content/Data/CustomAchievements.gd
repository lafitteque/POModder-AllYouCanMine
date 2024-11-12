extends Node
class_name CustomAchievements

var achievements_unlocked = {}

var data_achievements 
var all_children = []
var stage = null
var saver_id = "custom_achievements"

@onready var saver = get_node("/root/ModLoader/POModder-AllYouCanMine").saver


@onready var achievement_stage = {
	"MultiplayerLoadoutModStage" :[preload("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/mine_loadout.tscn")],
	"LevelStage": [preload("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/fast_why.tscn"),
	preload("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/useless_explosion.tscn")],
	"Prestige" : [],
	"Assignments" : [],
	"Relichunt" : [preload("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/relic_wait.tscn")],
	"MultiplayerLoadoutStage" : [],
	"TitleStage":[],
	"LandingSequence":[],
	"Intro" : []
	}

 
func _ready():
	saver.load_data()
	
	if !saver.save_dict.has(saver_id): # If save_file is empty (first time)
		saver.save_dict[saver_id] = {}
		
	var loaded = saver.save_dict[saver_id] 
	if loaded!= {} and loaded != null:
		achievements_unlocked = loaded
		
	data_achievements = get_node("/root/ModLoader/POModder-AllYouCanMine").data_achievements
	for achievementId in data_achievements.CUSTOM_ACHIEVEMENTS:
		if !achievements_unlocked.has(achievementId):
			achievements_unlocked[achievementId] = false 

	
	
func _exit_tree():
	save_data()

func change_stage(new_stage : String):
	stage = new_stage
	for achievement in all_children :
		achievement.queue_free()
	all_children.clear()
	for achievement in achievement_stage[new_stage]:
		var new_child = achievement.instantiate()
		add_child(new_child)
		all_children.append(new_child)
		
	if new_stage == "LevelStage":
		for key in achievement_stage.keys():
			if Level.mode.name == key:
				for achievement in achievement_stage[key]:
					var new_child = achievement.instantiate()
					add_child(new_child)
					all_children.append(new_child)
			
			
func unlockAchievement(achievementId : String):
	assert( achievements_unlocked.has(achievementId), "ERROR: You try to unlock an achievement that does not exist.")
	if ! achievements_unlocked[achievementId]:
		var popup = preload("res://mods-unpacked/POModder-AllYouCanMine/content/Achievements/Achievement_popup.tscn").instantiate()
		popup.seTitle('achievement.' + achievementId.to_lower() + ".title")
		StageManager.find_child("Canvas",true,false).add_child(popup)
	achievements_unlocked[achievementId] = true
	if StageManager.currentStage.name == "MultiplayerLoadoutModStage":
		StageManager.currentStage.update_custom_achievements()
	save_data()
		
		
func isAchievementUnlocked(achievementId : String):
	assert( achievements_unlocked.has(achievementId), "ERROR: You try to access an achievement that does not exist.")
	return achievements_unlocked[achievementId] 
	

func save_data():
	saver.save_dict[saver_id] = achievements_unlocked
	saver.save_data()


