extends CharacterBody2D

class_name Character

var items
@export var health = 100
var held_item = null
var appearance = null

var chat_fade_tween: Tween

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
		GlobalData.log_event(appearance, 'picked up', held_item.appearance)


func pick_up_nearest_item():
	var nearby_items = $ItemDetectionArea.get_overlapping_areas().filter(func(a): return a is Item)
	if nearby_items.size() > 0:
		nearby_items.sort_custom(_compare_dist_to)
		pick_up_item(nearby_items[0])
		
		
func _compare_dist_to(a, b): 
	return position.distance_to(a.position) < position.distance_to(b.position)
	
	
func use_held_item():
	if held_item:
		held_item.use()
		# log event
		GlobalData.log_event(appearance, 'used', held_item.appearance)


func drop_held_item():
	if held_item:
		self.remove_child(held_item)
		items.add_child(held_item)
		held_item.global_position = self.global_position
		held_item.is_being_held = false
		# log event
		GlobalData.log_event(appearance, 'dropped', held_item.appearance)
		
		held_item = null
		
		
func say(text):
	if chat_fade_tween: chat_fade_tween.kill()
	$HUD/ChatBubble.modulate.a = 1
	$HUD/ChatBubble.text = text
	$HUD/ChatBubble/ChatFadeTimer.start()
	# log event
	GlobalData.log_event(appearance, 'said', text)
	
	
func _on_chat_fade_timer_timeout():
	chat_fade_tween = get_tree().create_tween()
	chat_fade_tween.tween_property($HUD/ChatBubble, 'modulate:a', 0, 5)
		
