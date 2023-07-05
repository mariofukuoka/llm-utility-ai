extends Character

class_name Player


func set_appearance():
	appearance = 'knight'
	$AnimatedSprite2D.play(appearance)

func get_input():
	var input_dir = Input.get_vector('left', 'right', 'up', 'down')
	velocity = input_dir * SPEED
	if Input.is_action_just_pressed('pick_up_or_drop_item'):
		if not held_item: pick_up_nearest_item()
		else: drop_held_item()
	elif Input.is_action_just_pressed('use_item'):
		if held_item: held_item.use()

func _physics_process(delta):
	get_input()
	move_and_slide()
	
