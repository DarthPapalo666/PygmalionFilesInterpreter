extends Control

const MESSAGE_SIZE : int = 2354

#func _ready():
#	pass
#
#func _process(delta):
#	pass

func generate_images(messages : Array, messages_per_img : int, user_avatar : ImageTexture, char_avatar : ImageTexture, export_path : String, watermark : bool, space_between_msg : int = 100) -> void:
	var images_amount : int = ceil(len(messages) / messages_per_img) + 1
	messages.invert()
	
	$Viewport/MarginContainer/MessagesContainer.set("custom_constants/separation", space_between_msg)
	rect_size.x = MESSAGE_SIZE # Set x size of the viewport to message size
	
	for i in range(images_amount):
		for u in range(messages_per_img):
			var current_message_array = messages.back()
			if current_message_array == null:
				break # No more messages on last image
			var new_message = preload("res://Scenes/Message.tscn").instance()
			if current_message_array[0] == true: # Its a user message
				new_message.set_message(user_avatar, current_message_array[1], current_message_array[2])
			else:
				new_message.set_message(char_avatar, current_message_array[1], current_message_array[2])
				
			$Viewport/MarginContainer/MessagesContainer.add_child(new_message)
			
			messages.pop_back()
		
		# Save viewport's image
		# Set viewports long
		var long = 0
		for box in $Viewport/MarginContainer/MessagesContainer.get_children():
			long += box.rect_size.y + int(space_between_msg) # because of box margin_expand
			
		rect_size.y = long
		
		yield(VisualServer, "frame_post_draw") # get the img data after being draw
		var img = $Viewport.get_texture().get_data()
		img.flip_y()
		img.save_png(export_path + "\\chat_image" + str(i) + ".png")
		for node in $Viewport/MarginContainer/MessagesContainer.get_children():
			$Viewport/MarginContainer/MessagesContainer.remove_child(node)
			node.free()
	pass
