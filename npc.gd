extends Character

class_name NPC

const ARRIVAL_DIST_THRESHOLD = 1
var is_moving = false
var curr_target: Vector2

func reply(text):
	say(await GPTApi.get_completion(text))
	
	
func move_to_target(target: Vector2):
	is_moving = true
	curr_target = target
	
func _physics_process(delta):
	if is_moving:
		if global_position.distance_to(curr_target) < ARRIVAL_DIST_THRESHOLD:
			is_moving = false
			velocity = Vector2.ZERO
		else:
			var target_dir = global_position.direction_to(curr_target)
			velocity = target_dir * SPEED
			move_and_slide()
		
