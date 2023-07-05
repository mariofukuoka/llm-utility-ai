extends Character

class_name NPC

func reply(text):
	say(await ApiRequest.get_completion(text))
	
