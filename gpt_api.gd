extends HTTPRequest


var api_key: String

func _ready():
	var config = ConfigFile.new()
	var err = config.load('res://secret.cfg')
	api_key = config.get_value('OpenAI', 'api_key')
	
func get_completion(author, text):
	#request_completed.connect(_on_request_completed)
	var messages = [
			{"role": "system", "content": get_system_prompt()},
			{"role": "user", "content": author + ': ' + text}
		]
	print(messages)
	var url = 'https://api.openai.com/v1/chat/completions'
	var headers = [
		'Content-Type: application/json', 
		'Authorization: Bearer {0}'.format([api_key])
		]
	var body = {
		"model": "gpt-3.5-turbo",
		"messages": messages,
		"temperature": 0.7
   	}
	request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	var response = await request_completed
	var json = JSON.parse_string(response[3].get_string_from_utf8())
	return json['choices'][0]['message']['content']
	
func get_system_prompt():
	var prompt = """
	You are an utility AI system of a NPC in an RPG game. Respond in short sentences.
	You are in charge of making decisions of what the NPC will do next, given a textual description of the current world state. This is a simple game where you can only hold one item at a time, though you can also talk to other characters as well.
	Your possible decisions are: {
		say(text: String),
		move(target: Vector2),
		pickUpItem(itemName: String),
		dropHeldItem,
		useHeldItem
		}
	"""
	var temp = """
	You are an NPC villager in an RPG game. Respond in character and keep your response short.
	Event log:
	{0}
	You can act by outputting a JSON of the following form:
	{"action": <action name>, "args": <action parameters, if applicable>}
	Available actions:
	- "move" (moves you to a point) takes a list of two numbers specifying coordinates to move to (e.q. [10, 10])
	- "say" (lets you say stuff) takes a string of what to say as input
	- "pickup" (picks up an item)
	- "drop" (drops held item)
	- "use" (uses an item)
	- "follow" (follows the player)
	For example, if you wanted to move to 20, 20 on the map, you would output {"action":"move", "args"[20, 20]}
	Please reply with only the JSON object and nothing else. If an action takes no arguments, explicitly return them as null instead of omitting them.
	""".format([GlobalData.get_world_description()])
	return temp
