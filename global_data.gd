extends Node


var world_log = []

func log_event(who: String, action: String, what: String):
	var now = Time.get_ticks_msec()
	var event = {'who': who, 'action': action, 'what': what, 'when': now}
	world_log.append(event)
	print(event)
	
func get_world_description():
	var now = Time.get_ticks_msec()
	var world_desc: String
	for event in world_log:
		var elapsed_sec = ((now - event['when']) / 1000) as int
		var what = event['what']
		if event['action'] == 'said':
			what = '"' + what + '"'
		var event_desc = '[{0}s ago] {1} {2} {3}'.format([elapsed_sec, event['who'], event['action'], what])
		world_desc += event_desc + '\n'
	return world_desc
		
