extends Character

class_name Player

var is_typing = false

func set_appearance():
	appearance = 'knight'
	$AnimatedSprite2D.play(appearance)

func get_input():
	if not is_typing:
		var input_dir = Input.get_vector('left', 'right', 'up', 'down')
		velocity = input_dir * SPEED
		if Input.is_action_just_pressed('pick_up_or_drop_item'):
			if not held_item: pick_up_nearest_item()
			else: drop_held_item()
		elif Input.is_action_just_pressed('use_item'): 
			use_held_item()
	else:
		# to make sure player stops when pressing enter instead of sliding forever
		velocity = Vector2.ZERO
	if Input.is_action_just_pressed('grab_chat_focus'):
		# enter is used both for activating chat and sending messages
		if not is_typing:
			is_typing = true
			$HUD/ChatBox.grab_focus()
		else:
			if $HUD/ChatBox.text != '':
				send_chat_message($HUD/ChatBox.text)
			$HUD/ChatBox.text = ''
			is_typing = false
			$HUD/ChatBox.release_focus()
	elif Input.is_action_just_pressed('release_chat_focus'):
		is_typing = false
		$HUD/ChatBox.release_focus()
		var nearby_npcs = get_perceived_npcs()
		if nearby_npcs.size() > 0:
			print(nearby_npcs[0].get_system_prompt())

func send_chat_message(text: String):
	# detect nearby npcs
	var nearby_npcs = $PerceivedArea.get_overlapping_bodies().filter(func(body): return body is NPC)
	print(nearby_npcs)
	if nearby_npcs.size() > 0:
		# if message starts with /, interpret as command
		if text.begins_with('/'):
			var args = text.get_slice('/', 1).split(' ')
			nearby_npcs[0].act(args[0], args.slice(1, args.size()))
		else:
			say(text)
			nearby_npcs[0].reply(appearance, text)
			

func _physics_process(delta):
	get_input()
	move_and_slide()
	

