extends Character

class_name NPC

const ARRIVAL_DIST_THRESHOLD = 1
var is_moving = false
var curr_target: Vector2

func reply(to_whom, text):
	var LLM_decision = await GPTApi.get_completion(get_system_prompt())
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
			var nearby_players = get_perceived_players()
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
			
func get_system_prompt():
	var prompt = """
	You are an NPC in an RPG game. You are a {0}. Respond in character and keep your response short.
	Event log:
	{1}
	You can act by outputting a JSON of the following form:
	{"action": <action name>, "args": <action parameters, if applicable>}
	Available actions:
	- "move" (moves you to a point) takes a list of two numbers specifying coordinates to move to (e.q. [10, 10])
	- "say" (lets you say stuff) takes a string of what to say as input
	- "pickup" (picks up an item)
	- "drop" (drops held item)
	- "use" (uses an item)
	- "follow" (follows the player)
	For example, if you wanted to move to 20, 20 on the map, you would output {"action":"move", "args":[20, 20]}
	Please reply with only the JSON object and nothing else. If an action takes no arguments, explicitly return them as null instead of omitting them.
	""".format([appearance, GlobalData.get_world_description()])
	return prompt
		
