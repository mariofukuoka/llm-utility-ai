extends Character

class_name NPC

signal reached_target
const ARRIVAL_DIST_THRESHOLD = 16
var is_moving = false
var curr_target: Vector2
var action_queue = []
var is_executing_action = false

func get_next_actions():
	var prompt = get_system_prompt()
	print(prompt)
	var LLM_decision = await $GPTApi.get_completion(prompt)
	print(LLM_decision)
	var parsed_actions = JSON.parse_string(LLM_decision)
	action_queue.append_array(parsed_actions['action_as_sequence'])

func execute_action(action_tuple):
	is_executing_action = true
	var action = action_tuple[0]
	var args = action_tuple[1] if action_tuple.size() > 1 else null
	match action:
		'move':
			await move_to_target(get_perceived_char_or_item_by_name(args).global_position)
		'move_to_point':
			await move_to_target(Vector2(args[0] as float, args[1] as float))
		'pickup':
			pick_up_nearest_item()
		'drop':
			drop_held_item()
		'use':
			use_held_item()
		'say':
			say(args)
		'attack':
			await move_to_target(get_perceived_char_or_item_by_name(args).global_position)
			attack_by_name(args)
		'wait':
			await wait(args as int)
	
	is_executing_action = false
			
	
func move_to_target(target: Vector2):
	is_moving = true
	curr_target = target
	await reached_target
	
func _physics_process(delta):
	if not is_executing_action and action_queue.size() > 0:
		execute_action(action_queue.pop_front())
	else:
		if is_moving: _move_every_frame()

func _move_every_frame():
	if global_position.distance_to(curr_target) < ARRIVAL_DIST_THRESHOLD:
		is_moving = false
		velocity = Vector2.ZERO
		reached_target.emit()
	else:
		var target_dir = global_position.direction_to(curr_target)
		velocity = target_dir * SPEED
		move_and_slide()



