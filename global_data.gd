extends Node

signal event_logged

var world_log = []

func log_event(who: String, action: String, what: String, seen_by: Array):
	var now = Time.get_ticks_msec()
	var event = {'who': who, 'action': action, 'what': what, 'when': now, 'seen_by':seen_by}
	world_log.append(event)
	print(event)
	event_logged.emit()
	
func get_world_description(character):
	var now = Time.get_ticks_msec()
	var world_desc: String
	for event in world_log:
		if (character != event['who']) and (character not in event['seen_by']):
			continue
		var elapsed_sec = ((now - event['when']) / 1000) as int
		var what = event['what']
		if event['action'] == 'said':
			what = '"' + what + '"'
		var event_desc = '[{0}s ago] {1} {2} {3}'.format([elapsed_sec, event['who'], event['action'], what])
		world_desc += event_desc + '\n'
	return world_desc
		
func get_compass_direction(vector: Vector2):
	pass
