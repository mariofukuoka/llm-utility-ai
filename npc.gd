extends Character

class_name NPC

signal reached_target
signal action_queue_finished
const ARRIVAL_DIST_THRESHOLD = 16
var is_moving = false
var curr_target: Vector2
var action_queue = []
var is_executing_action = false
var thought_fade_tween: Tween

func get_next_actions():
	var prompt = get_system_prompt()
	#print(prompt)
	var LLM_decision = await $GPTApi.get_completion(prompt)
	#print(LLM_decision)
	var parsed = JSON.parse_string(LLM_decision)
	$HUD/MouseOver.tooltip_text = 'Observations: "{0}"\nWhat to do: "{1}\nAction as sequence: {2}'.format([
		parsed['observations'], 
		parsed['what_to_do'],
		JSON.stringify(parsed['action_as_sequence'])
		])
	action_queue.append_array(parsed['action_as_sequence'])

func execute_action(action_tuple):
	is_executing_action = true
	var action = action_tuple[0]
	var args = action_tuple[1] if action_tuple.size() > 1 else null
	match action:
		'move':
			var target = get_perceived_char_or_item_by_name(args)
			if target:
				await move_to_target(target.global_position)
		'move_to_point':
			await move_to_target(Vector2(args[0] as float, args[1] as float))
		'pickup':
			pick_up_item_by_name(args)
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
	
func take_turn():
	await get_next_actions()
	await action_queue_finished
	turn_completed.emit()
	
	
func _physics_process(delta):
	if not is_executing_action and action_queue.size() > 0:
		execute_action(action_queue.pop_front())
	elif not is_executing_action and action_queue.size() == 0:
		action_queue_finished.emit()
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

