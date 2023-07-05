extends Character

class_name NPC

const ARRIVAL_DIST_THRESHOLD = 1
var is_moving = false
var curr_target: Vector2

func reply(to_whom, text):
	var LLM_decision = await GPTApi.get_completion(to_whom, text)
	print(LLM_decision)
	var parsed = JSON.parse_string(LLM_decision)
	var action = parsed['action']
	var args = null
	if parsed['args']: args = parsed['args']
	act(action, args)

func act(action, args=null):
	print(action)
	print(args)
	match action:
		'move':
			move_to_target(Vector2(args[0] as float, args[1] as float))
		'pickup':
			pick_up_nearest_item()
		'drop':
			drop_held_item()
		'use':
			use_held_item()
		'say':
			say(args)
		'follow':
			var nearby_players = $PerceivedArea.get_overlapping_bodies().filter(func(b): return b is Player)
			if nearby_players.size() > 0:
				move_to_target(nearby_players[0].global_position)
	
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
		
