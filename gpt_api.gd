extends HTTPRequest


var api_key: String

func _ready():
	var config = ConfigFile.new()
	var err = config.load('res://secret.cfg')
	api_key = config.get_value('OpenAI', 'api_key')
	
func get_completion(prompt):
	#request_completed.connect(_on_request_completed)
	var messages = [
			{"role": "system", "content": prompt}
		]
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
	

