extends HBoxContainer

var sprite_width = 18

func set_map_size_to(map_size : String , col : int):
	match map_size:
		CONST.MAP_SMALL:
			$small.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/progress_map" + str(col) + ".png")
			$small.self_modulate = Color(1.0,1.0,1.0,1.0)
		CONST.MAP_MEDIUM:
			$medium.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/progress_map" + str(col) + ".png")
			$medium.self_modulate = Color(1.0,1.0,1.0,1.0)
		CONST.MAP_LARGE:
			$large.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/progress_map" + str(col) + ".png")
			$large.self_modulate = Color(1.0,1.0,1.0,1.0)
		CONST.MAP_HUGE:
			$huge.texture = load("res://mods-unpacked/POModder-AllYouCanMine/images/progress_map" + str(col) + ".png")
			$huge.self_modulate = Color(1.0,1.0,1.0,1.0)
			
func set_children_custom_size(multiplyier : float):
	for c in get_children():
		c.custom_minimum_size = c.get_minimum_size()*2
