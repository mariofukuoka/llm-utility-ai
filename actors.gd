extends Node2D

var active_actor

func _ready():
	active_actor = get_child(0)
	while true:
		await play_turn()
	
func play_turn():
	print("{0}'s turn".format([active_actor.appearance]))
	active_actor.take_turn()
	await active_actor.turn_completed
	var new_index: int = (active_actor.get_index() + 1) % get_child_count()
	active_actor = get_child(new_index)
