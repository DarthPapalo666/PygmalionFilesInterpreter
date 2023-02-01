extends PanelContainer

onready var Dir := Directory.new()
onready var CI := ChatInterpreter.new()

onready var file_path_node = $AppContainer/ChatToFilesMenu/VBoxContainer/FilePathBox/FileTextPath
onready var folder_path_node = $AppContainer/ChatToFilesMenu/VBoxContainer/FolderPathBox/FolderTextPath

onready var file_status_label = $AppContainer/ChatToFilesMenu/VBoxContainer/FileStatus
onready var folder_status_label = $AppContainer/ChatToFilesMenu/VBoxContainer/FolderStatus

# Export Buttons
onready var chat_export_img = $AppContainer/ChatToFilesMenu/VBoxContainer/HBoxContainer/ExportImgButton
onready var chat_export_txt = $AppContainer/ChatToFilesMenu/VBoxContainer/HBoxContainer/ExportTextButton
onready var export_info_label = $AppContainer/ChatToFilesMenu/VBoxContainer/ExportButtonsInfo

# Export Options
onready var msg_per_image = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer/MsgPerImg/SpinBox
onready var type_of_ui = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer/TypeOfUI/OptionButton
onready var watermark = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer2/ToggleWatermark/OptionButton

onready var error_label = $AppContainer/ChatToFilesMenu/VBoxContainer/ErrorLabel

onready var user_avatar = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer2/UserAvatarContainer/UserAvatar
onready var user_avatar_info = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer2/UserAvatarContainer/Label
onready var character_avatar = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer2/CharacterAvatarContainer/CharAvatar
onready var character_avatar_info = $AppContainer/ChatToFilesMenu/VBoxContainer/Options/HBoxContainer2/CharacterAvatarContainer/Label

var selected_avatar : int = 0 # 0 is char and 1 i user

var file_valid : bool = false
var folder_valid : bool = false

var export_options : Dictionary

func _ready():
	# Set file browsers filters
	$AvatarDialog.add_filter("*.png ; png files")
	$AvatarDialog.add_filter("*.jpg ; jpg files")
	$FileDialog.add_filter("*.jsonl ; JSONL files")
	$FileDialog.add_filter("*.json ; JSON files")
	pass

func _process(delta):
	# Paths status
	if Dir.file_exists(file_path_node.text):
		file_valid = true
		file_status_label.set_text("File Selected!" + " (" + file_path_node.text.get_extension() + ")")
		file_status_label.set("custom_colors/font_color", Color.chartreuse)
	else:
		file_valid = false
		file_status_label.set_text("File not found.")
		file_status_label.set("custom_colors/font_color", Color.crimson)
		
	if Dir.dir_exists(folder_path_node.text) and folder_path_node.text != "":
		folder_valid = true
		folder_status_label.set_text("Folder Selected!")
		folder_status_label.set("custom_colors/font_color", Color.chartreuse)
	else:
		folder_valid = false
		folder_status_label.set_text("Folder does not exists.")
		folder_status_label.set("custom_colors/font_color", Color.crimson)
	
	# Check export button availability
	if file_valid and folder_valid:
		chat_export_txt.disabled = false
	else:
		chat_export_txt.disabled = true
	
	if file_valid and folder_valid and user_avatar.texture != null and character_avatar.texture != null:
		chat_export_img.disabled = false
	else:
		chat_export_img.disabled = true
	
	# Check avatar selection:
	if character_avatar.texture == null:
		character_avatar_info.text = "Select character avatar"
		character_avatar_info.set("custom_colors/font_color", Color.navajowhite)
	else:
		character_avatar_info.text = "Character avatar selected!"
		character_avatar_info.set("custom_colors/font_color", Color.chartreuse)
	
	if user_avatar.texture == null:
		user_avatar_info.text = "Select user avatar"
		user_avatar_info.set("custom_colors/font_color", Color.navajowhite)
	else:
		user_avatar_info.text = "User avatar selected!"
		user_avatar_info.set("custom_colors/font_color", Color.chartreuse)
	
	# Update export options
	export_options["MsgPerCap"] = msg_per_image.value
	export_options["UI"] = type_of_ui.selected
	export_options["Watermark"] = watermark.pressed
	
	pass

# Selection of paths
func _on_ButtonFileSelect_pressed():
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.window_title = "Select a JSONL file"
	
	$FileDialog.popup_centered(Vector2(500, 375))
	$FileDialog.popup_centered(Vector2(500, 375))
	pass

func _on_FileDialog_file_selected(path):
	file_path_node.set_text(path)
	pass

func _on_ButtonFolderSelect_pressed():
	$FileDialog.mode = FileDialog.MODE_OPEN_DIR
	$FileDialog.window_title = "Select the export folder path"
	
	$FileDialog.popup_centered(Vector2(500, 375))
	pass

func _on_FileDialog_dir_selected(dir):
	folder_path_node.set_text(dir)
	pass

# Selection of AVATARS
#Character
func _on_ButtonCharacterAvatar_pressed():
	selected_avatar = 0
	$AvatarDialog.mode = FileDialog.MODE_OPEN_FILE
	$AvatarDialog.window_title = "Select an image for the character avatar"
	
	$AvatarDialog.popup_centered(Vector2(500, 375))
	pass

func _on_ButtonUserAvatar_pressed():
	selected_avatar = 1
	$AvatarDialog.mode = FileDialog.MODE_OPEN_FILE
	$AvatarDialog.window_title = "Select an image for the user avatar"
	
	$AvatarDialog.popup_centered(Vector2(500, 375))
	pass

func _on_AvatarDialog_file_selected(path): # On image selected
	var f = File.new()
	f.open(path, File.READ)
	var image_data = f.get_buffer(f.get_len())
	var image = Image.new()
	
	var err
	if path.get_extension() == "png" or path.get_extension() == "PNG":
		err = image.load_png_from_buffer(image_data)
	elif path.get_extension() == "jpg" or path.get_extension() == "JPG":
		err = image.load_jpg_from_buffer(image_data)
	
	if err == 0:
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		
		if selected_avatar == 0:
			character_avatar.texture = texture
		elif selected_avatar == 1:
			user_avatar.texture = texture
	else:
		error_label.text = "ERROR: Image couldn't be loaded."
		$AnimationPlayer.play("FlashError")
	pass

# EXPORTING CHATS FUNCTIONS
# Exporting as txt
func _on_ExportTextButton_pressed():
	if (file_path_node.text.get_extension() == "jsonl" and export_options["UI"] == 0) or (file_path_node.text.get_extension() == "json" and export_options["UI"] == 1):
		$ChooseNamePopup.popup_centered(Vector2(250, 125))
		error_label.text = ""
	else:
		error_label.text = "ERROR: file can't be exported (Check the UI selected)"
		$AnimationPlayer.play("FlashError")
	pass

func _on_AcceptName_pressed():
	$ChooseNamePopup.visible = false
	var file_name : String = $ChooseNamePopup/CenterContainer/HBoxContainer/LineEdit.text
	if folder_path_node.text.right(len(folder_path_node.text) - 1) == "\\":
		save_chat_as_txt(folder_path_node.text + file_name + ".txt", export_options["UI"])
	else:
		save_chat_as_txt(folder_path_node.text + "\\" + file_name + ".txt", export_options["UI"])
		
	pass

func save_chat_as_txt(path : String, UI : int, blank_between_msg : bool = true):
	var f = File.new()
	f.open(path, File.WRITE)
	var messages_lines : Array
	
	if UI != -1: # TavernUI or GradioUI
		messages_lines = CI.get_messages(file_path_node.text, UI)
	elif UI == -1: #No UI selected
		$AlertDialog.dialog_text = "Select a UI on the export options."
		$AlertDialog.popup_centered(Vector2(250, 150))
	
	# Write file
	for i in messages_lines:
		f.store_line(i)
		if blank_between_msg:
			f.store_line("\n")
	
	f.close()
	pass


# Exporting as img
func _on_ExportImgButton_pressed():
	save_chat_to_img()
	pass

func save_chat_to_img() -> void:
	# Get message and "is_user" in an array
	var messages : Array = CI.get_messages(file_path_node.text, export_options["UI"], true)
	ImagesCreator.generate_images(messages, export_options["MsgPerCap"], user_avatar.texture, character_avatar.texture, folder_path_node.text, export_options["Watermark"])
	pass
