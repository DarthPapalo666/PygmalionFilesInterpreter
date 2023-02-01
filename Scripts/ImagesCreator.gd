extends Control

signal image_generated(amount)
signal amount_will_generate(amount, text) # Also starts the loading progress

const OFFSET = 150

onready var message_scene = preload("res://Scenes/Message.tscn")

func generate_images(chat : Array, messages_per_img : int, user_avatar : ImageTexture, char_avatar : ImageTexture, export_path : String, quality : int, img_width, space_between_msg : int = 150) -> void:
	var images_amount : int = int(ceil(len(chat) / float(messages_per_img)))
	emit_signal("amount_will_generate", images_amount, "Generating images...")
	
	rect_size.x = img_width + OFFSET # Set x size of the viewport (final image width) to message size
	
	$Viewport/MarginContainer/MessagesContainer.set("custom_constants/separation", space_between_msg) # Set espace between message boxes
	
	var message_id : int = 0
	
	for i in range(images_amount):
		for u in range(messages_per_img):
			if len(chat) == message_id:
				break # No more messages on last image
			var current_message_array = chat[message_id]
			var new_message = message_scene.instance()
			if current_message_array[0] == true: # Its a user message
				new_message.set_message(img_width, user_avatar, current_message_array[1], current_message_array[2])
			else:
				new_message.set_message(img_width, char_avatar, current_message_array[1], current_message_array[2])
			
			$Viewport/MarginContainer/MessagesContainer.add_child(new_message)
			
			message_id += 1
			
		# Save viewport's image
		yield(VisualServer, "frame_post_draw")
		rect_size.y = $Viewport/MarginContainer.rect_size.y + OFFSET
		
		yield(VisualServer, "frame_post_draw") # get the img data after being draw
		var img = $Viewport.get_texture().get_data() # Image type
		img.flip_y()
		var img_size : Vector2 = img.get_size()
		img.resize(img_size.x * (float(quality) / 100), img_size.y * (float(quality) / 100), 4)
		img.save_png(export_path + "\\chat_image" + str(i) + ".png")
		
		emit_signal("image_generated", 1)
		
		for node in $Viewport/MarginContainer/MessagesContainer.get_children():
			$Viewport/MarginContainer/MessagesContainer.remove_child(node)
			node.free()
		
	pass
