extends Node

class_name ChatInterpreter

func get_clean_chat(file_path : String, UI : int) -> Array:
	var clean_chat : Array = [] # Array with Arrays with this sintax: "is_user", "name" and "mes"
	var f = File.new()
	f.open(file_path, File.READ)
	
	if UI == 0: # TavernUI (Multiple lines)
		var file_text = f.get_as_text() # Get all file as text

		var lines : Array = Array(file_text.split("\n"))
		
		lines.pop_front() #Eliminates first line of chat info
		
		for line in lines:
			var parsed_line = parse_json(line)
			
			if typeof(parsed_line) == TYPE_DICTIONARY:
				
				var message_data : Array = [] # Array with info about the writer, the name and the message
				message_data.append(parsed_line["is_user"])
				message_data.append(parsed_line["name"])
				message_data.append(parsed_line["mes"])
				
				clean_chat.append(message_data)
	
	elif UI == 1: # GradioUI (One line of JSON)
		var json_data = parse_json(f.get_as_text()) #Dictionary with "chat" key referencing "chat" Array containing all messages
		
		if typeof(json_data) == TYPE_DICTIONARY:
			
			for mes in json_data["chat"]:
				var message_data : Array = [] # Array with this sintax: "is_user", "name" and "mes"
				var end_name_pos = mes.find(":") # Check name
				var sender_name : String = mes.left(end_name_pos)
				
				if sender_name == "You":
					message_data.append(true)
				else:
					message_data.append(false)
				message_data.append(sender_name) # Sender of the message (Name that will appear on images)
				message_data.append(mes.right(end_name_pos + 2))
				
				clean_chat.append(message_data)
				
	f.close()
	return clean_chat
	pass

