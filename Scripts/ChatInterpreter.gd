extends Node

class_name ChatInterpreter

func get_messages(file_path : String, UI : int, for_img : bool = false) -> Array:
	var clean_messages : Array = []
	var f = File.new()
	f.open(file_path, File.READ)
	if UI == 0: # TavernUI
		# Get char and user names (UNUSED RIGHT NOW)-----*
		var user_name : String
		var char_name : String
		
		var first_line = parse_json(f.get_line())
		if typeof(first_line) == TYPE_DICTIONARY:
			user_name = first_line["user_name"]
			char_name = first_line["character_name"]
		else:
			#print("Error parsing json")
			pass
		# (UNUSED RIGHT NOW)-----------------------------*
		
		var file_text = f.get_as_text() # Get all file as text
		#file_text = file_text.c_unescape()
		var lines : Array = Array(file_text.split("\n"))
		
		lines.pop_front() #Eliminates first line of info
		
		for i in lines:
			var actual_line = parse_json(i)
			if typeof(actual_line) == TYPE_DICTIONARY:
				if for_img == false:
					clean_messages.append(actual_line["name"] + ": " + actual_line["mes"])
				elif for_img == true:
					var writer_message : Array = [] # Array with info about the writer, the name and the message
					writer_message.append(actual_line["is_user"])
					writer_message.append(actual_line["name"])
					writer_message.append(actual_line["mes"])
					clean_messages.append(writer_message)
			else:
				#print("Error parsing")
				pass
			pass
	
	elif UI == 1: # GradioUI
		var json_data = parse_json(f.get_as_text())
		
		if for_img == false:
			if typeof(json_data) == TYPE_DICTIONARY:
				for i in json_data["chat"]:
					clean_messages.append(i)
		elif for_img == true: #Return a dictionary with is_user and mes
			for mes in json_data["chat"]:
				var writer_message : Array = [] # Array with info about the writer, the name and the message
				if mes.left(5) == "You: ":
					writer_message.append(true)
					writer_message.append("You")
				else:
					var end_name_pos = mes.find(":")
					var char_name : String = mes.left(end_name_pos)
					writer_message.append(char_name)
					writer_message.append(false)
				
				writer_message.append(mes)
				clean_messages.append(writer_message)
	
	f.close()
	return clean_messages
	pass

