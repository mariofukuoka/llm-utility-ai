extends CharacterBody2D


const SPEED = 300.0

func get_input():
	var input_dir = Input.get_vector('left', 'right', 'up', 'down')
	velocity = input_dir * SPEED

func _physics_process(delta):
	get_input()
	move_and_slide()
