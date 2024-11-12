extends Area2D
class_name RelicAttractor

var condition_fulfilled = true
var attraction_speed = 15.0
var bad_relic = null
var bad_relic_present = false
var len_to_move = 1000.0

func _physics_process(delta):
	if !bad_relic_present:
		return
	if bad_relic.carriedBy.size() > 0 or  !condition_fulfilled:
		return
		
	var to_move = (global_position - bad_relic.global_position)
	len_to_move = to_move.length()
	bad_relic.linear_velocity =  to_move/len_to_move*max(attraction_speed,len_to_move/delta)
	
func _on_body_entered(body):
	if body is Drop and body.type == "bad_relic":
		bad_relic = body
		bad_relic_present = true


func _on_body_exited(body):
	if body is Drop and body.type == "bad_relic":
		bad_relic = null
		bad_relic_present = false
