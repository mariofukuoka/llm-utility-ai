extends CharacterBody2D

class_name Character

var items
@export var health = 100
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
	desc += ' ({0},{1})'.format([global_position.x as int, global_position.y as int])
	return desc

			
func get_system_prompt():
	var prompt = """
	You are an NPC in an RPG game. You are a {0}. Respond in character and keep your response short.
	Event log:
	{1}
	Your position: ({2}, {3})
	Characters you can see: [{4}]
	Item you are holding: [{5}]
	Items you can see: [{6}]
	You can act by outputting a JSON of the following form:
	[{"action": <action name>, "args": <action parameters, if applicable>},]
	The list of objects represents a sequence of actions to execute one after another.
	Available actions:
	- "move" (moves you to a point) takes a list of two numbers specifying coordinates to move to (e.q. [10, 10])
	- "say" (lets you say stuff) takes a string of what to say as input
	- "pickup" (picks up an item)
	- "drop" (drops held item)
	- "use" (uses an item)
	- "wait" (stay idle for some time) takes a number of seconds as input (e.q. 5)
	For example, if you wanted to pick up an item located at (20, 20), you would output [{"action":"move", "args":[20, 20]}, {"action":"pickup", "args":null}].
	If you wanted to then go somewhere to (60, 30) and leave the item there, you would output [{"action":"move", "args":[60, 30]}, {"action":"drop", "args":null}]
	If someone asked you to bring some item to them, you would first say something back to them, then move to the item, pick up, move to that person, then drop.
	Please reply with only the JSON object and nothing else. If an action takes no arguments, explicitly return them as null instead of omitting them.
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
