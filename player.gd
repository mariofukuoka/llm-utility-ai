extends Character

class_name Player

var is_typing = false
var is_player_turn = false

func set_appearance():
	appearance = 'knight'
	$AnimatedSprite2D.play(appearance)
	GlobalData.event_logged.connect(_on_event_logged)
	
func take_turn():
	is_player_turn = true
	await get_tree().create_timer(10).timeout	
	is_player_turn = false
	turn_completed.emit()
	
func _on_event_logged():
	$HUD/EventLog.text = 'Event log:\n' + GlobalData.get_world_description(appearance)

func get_input():
	if not is_typing and is_player_turn:
		var input_dir = Input.get_vector('left', 'right', 'up', 'down')
		velocity = input_dir * SPEED
		if Input.is_action_just_pressed('pick_up_or_drop_item'):
			if not held_item: pick_up_nearest_item()
			else: drop_held_item()
		elif Input.is_action_just_pressed('use_item'): 
			use_held_item()
		elif Input.is_action_just_pressed('debug'):
			var nearby_npcs = get_perceived_npcs()
			if nearby_npcs.size() > 0:
				attack(nearby_npcs[0])
			
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
			print(nearby_npcs[0].get_instance_id())

func send_chat_message(text: String):
	# detect nearby npcs
	var nearby_npcs = $PerceivedArea.get_overlapping_bodies().filter(func(body): return body is NPC)
	print(nearby_npcs)
	if nearby_npcs.size() > 0:
		say(text)
		#for npc in nearby_npcs:
			#npc.get_next_actions()
			

func _physics_process(delta):
	get_input()
	move_and_slide()
	

