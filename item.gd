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

func get_description(viewer_pos:=Vector2.ZERO):
	var desc = appearance
	var relative_pos = global_position - viewer_pos
	var dist_m = (relative_pos.length() / 16) as int
	desc += '({0}m away)'.format([dist_m])
	return desc
