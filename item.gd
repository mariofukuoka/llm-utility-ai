extends Area2D

class_name Item

var is_being_held := false

var appearance = null

func _ready():
	set_appearance()
	
func set_appearance():
	var sprites = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var sprite_name = sprites[randi() % sprites.size()]
	$AnimatedSprite2D.play(sprite_name)
	appearance = sprite_name

func use():
	if is_being_held:
		print('{0} used'.format([self.appearance]))

func get_description():
	var desc = appearance
	desc += ' ({0},{1})'.format([global_position.x as int, global_position.y as int])
	return desc
