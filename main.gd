extends Node
@export var character_template: PackedScene
@export var item_template: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 2:
		var char = character_template.instantiate()
		char.position = Vector2(randi_range(60, 180), randi_range(60, 180)) 
		print(char.appearance)
		$Actors.add_child(char)
		
	for i in 5:
		var item = item_template.instantiate()
		item.position = Vector2(randi_range(0, 240), randi_range(0, 240)) 
		print(item.appearance)
		$Items.add_child(item)
	
	
	var children = $Actors.get_children()
	for child in children:
		print('child: {0}'.format([child.name]))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
