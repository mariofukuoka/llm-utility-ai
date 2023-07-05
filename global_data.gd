extends Node


var chat_log = []
var api_key: String

func _ready():
	var config = ConfigFile.new()
	var err = config.load('res://secret.cfg')
	api_key = config.get_value('OpenAI', 'api_key')

