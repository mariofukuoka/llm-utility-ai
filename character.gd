extends CharacterBody2D

class_name Character

var items
@export var health = 50
var held_item = null
var appearance = null

var chat_fade_tween: Tween
enum MODE {NAME_ONLY, DESC_ONLY}

var SPEED = 100

func _ready():
	items = get_node('/root/Main/Items')
	set_appearance()
	
	
func set_appearance():
	var sprites = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var sprite_name = sprites[randi() % sprites.size()]
	$AnimatedSprite2D.play(sprite_name)
	appearance = sprite_name


func pick_up_item(item: Item):
	if not item.is_being_held:
		item.get_parent().remove_child(item)
		self.add_child(item)
		item.position = Vector2.ZERO
		item.is_being_held = true
		held_item = item
		# log event
		GlobalData.log_event(
			appearance, 
			'picked up', 
			held_item.appearance, 
			get_perceived_characters(MODE.NAME_ONLY)
			)


func pick_up_nearest_item():
	var nearby_items = get_items_in_reach()
	if nearby_items.size() > 0:
		pick_up_item(nearby_items[0])
		
		
func _compare_dist_to(a, b): 
	return position.distance_to(a.position) < position.distance_to(b.position)
	
	
func use_held_item():
	if held_item:
		held_item.use()
		# log event
		GlobalData.log_event(
			appearance, 
			'used', 
			held_item.appearance, 
			get_perceived_characters(MODE.NAME_ONLY)
			)


func drop_held_item():
	if held_item:
		self.remove_child(held_item)
		items.add_child(held_item)
		held_item.global_position = self.global_position
		held_item.is_being_held = false
		# log event
		GlobalData.log_event(
			appearance, 
			'dropped', 
			held_item.appearance, 
			get_perceived_characters(MODE.NAME_ONLY)
			)
		
		held_item = null
		
		
func say(text):
	if chat_fade_tween: chat_fade_tween.kill()
	$HUD/ChatBubble.modulate.a = 1
	$HUD/ChatBubble.text = text
	$HUD/ChatBubble/ChatFadeTimer.start()
	# log event
	GlobalData.log_event(
		appearance, 
		'said', 
		text, 
		get_perceived_characters(MODE.NAME_ONLY)
		)
	
	
func _on_chat_fade_timer_timeout():
	chat_fade_tween = get_tree().create_tween()
	chat_fade_tween.tween_property($HUD/ChatBubble, 'modulate:a', 0, 5)

func wait(n_seconds: int):
	print('start')
	await get_tree().create_timer(n_seconds).timeout
	print('end')

func get_perceived_characters(mode=null):
	var nearby_characters = $PerceivedArea.get_overlapping_bodies().filter(func(b): return b is Character and b != self)
	nearby_characters.sort_custom(_compare_dist_to)
	if mode == MODE.NAME_ONLY:
		return nearby_characters.map(func(c): return c.appearance)
	elif mode == MODE.DESC_ONLY:
		return nearby_characters.map(func(c): return c.get_description())
	else:
		return nearby_characters

func get_perceived_npcs():
	return get_perceived_characters().filter(func(char): return char is NPC)

func get_perceived_players():
	return get_perceived_characters().filter(func(char): return char is Player)

func get_items_in_reach():
	var nearby_items = $ItemDetectionArea.get_overlapping_areas().filter(func(a): return a is Item and not a.is_being_held)
	nearby_items.sort_custom(_compare_dist_to)
	return nearby_items
	
func get_perceived_items(mode=null):
	var nearby_items = $PerceivedArea.get_overlapping_areas().filter(func(a): return a is Item and not a.is_being_held)
	nearby_items.sort_custom(_compare_dist_to)
	if mode == MODE.NAME_ONLY:
		return nearby_items.map(func(i): return i.appearance)
	elif mode == MODE.DESC_ONLY:
		return nearby_items.map(func(i): return i.get_description())
	else:
		return nearby_items
		
func get_description():
	var desc = appearance
	if held_item: desc += ' holding a ' + held_item.appearance
	#desc += ' ({0},{1})'.format([global_position.x as int, global_position.y as int])
	return desc
	
func get_perceived_character_by_name(name):
	for char in get_perceived_characters():
		if char.appearance == name:
			return char

func get_perceived_item_by_name(name):
	for item in get_perceived_items():
		if item.appearance == name:
			return item

func get_perceived_char_or_item_by_name(name):
	print(name)
	var char = get_perceived_character_by_name(name)
	if char:
		return char
	else:
		return get_perceived_item_by_name(name)

func get_system_prompt():
	var prompt = """d
	You are an NPC in an RPG game. You are a {0}. Respond in character and keep your response short. You can only hold one item at a time. In order to use an item, you need to pick it up it first.
	Event log:
	{1}
	Your position: ({2}, {3})
	Characters you can see: [{4}]
	Item you are holding: [{5}]
	Items you can see on the ground: [{6}]
	Please output according to the following format:
	{"observations": <your character's observations>,"action_description": <what to do now>,"action_as_sequence":[[<action1>,<argument1>],[<action2>,<argument2>],<etc>]}
	The list of action, argument tuples represents a sequence of actions to execute one after another.
	Available actions:
	- "move": moves you to a character or item as specified by name
	- "move_to_point": moves you to a point, takes a list of two numbers specifying coordinates to move to (e.q. [10, 10])
	- "say": lets you say stuff, takes a string of what to say as input
	- "pickup": picks up an item so that you hold it
	- "drop": drops held item
	- "use": uses the item you are holding. If you are not holding the item, you cannot use it.
	- "wait": if you want to stay idle, or have nothing to do, wait for some time, takes a number of seconds as input (e.q. 5)
	Your job is to interpret what's happening in the world, and convert that into actions to undertake next.
	For example, if a character asks you to bring them a potion, you would output:
	{"observations": "I am asked to bring the character a potion.","action_description": "I should go to the potion, pick it up, then bring it to the character and drop it.","action_as_sequence":[["move","potion"],["pickup"],["move","character"],["drop"],["say","Here you go!"]]}
	Please only respond with the JSON string.
	""".format([
		appearance, 
		GlobalData.get_world_description(appearance), 
		global_position.x as int,
		global_position.y as int,
		", ".join(get_perceived_characters(MODE.DESC_ONLY)),
		held_item.get_description() if held_item else '',
		", ".join(get_perceived_items(MODE.DESC_ONLY))
		])
	return prompt
