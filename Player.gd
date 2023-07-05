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
			if held_item: held_item.use()
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
				say($HUD/ChatBox.text)
				trigger_npc_reply($HUD/ChatBox.text)
			$HUD/ChatBox.text = ''
			is_typing = false
			$HUD/ChatBox.release_focus()
	elif Input.is_action_just_pressed('release_chat_focus'):
		is_typing = false
		$HUD/ChatBox.release_focus()

func trigger_npc_reply(text):
	var nearby_npcs = $PerceivedArea.get_overlapping_bodies().filter(func(body): return body is NPC)
	print(nearby_npcs)
	if nearby_npcs.size() > 0:
		nearby_npcs[0].reply(text)
	

func _physics_process(delta):
	get_input()
	move_and_slide()
	
