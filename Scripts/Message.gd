extends PanelContainer

const ITALIC_OPEN : String = "[i][color=#85858e]"
const ITALIC_CLOSING : String = "[/color][/i]"

func set_message(size, avatar : ImageTexture, user : String, text : String = "Error loading message"):
	$HBoxContainer/AvatarTexture.texture = avatar
	$HBoxContainer/MessageText.bbcode_text = "[b]" + user + "[/b]\n" + adapt_text(text)
	rect_min_size.x = size
	
func adapt_text(text : String) -> String:
	var adapted_text : String = text
	# Transform italic to bb_code
	var italic_pos = adapted_text.find("*")
	while italic_pos != -1:
		var closing_italic_pos = adapted_text.find("*", italic_pos + 1)
		if closing_italic_pos != -1:
			adapted_text.erase(italic_pos, 1)
			adapted_text = adapted_text.insert(italic_pos, ITALIC_OPEN)
			
			adapted_text.erase(closing_italic_pos + len(ITALIC_OPEN) - 1, 1)
			adapted_text = adapted_text.insert(closing_italic_pos + len(ITALIC_OPEN) - 1, ITALIC_CLOSING)
			
			italic_pos = adapted_text.find("*")
		else:
			italic_pos = -1
	
	return adapted_text
	pass
