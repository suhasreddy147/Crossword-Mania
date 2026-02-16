extends Panel
class_name CluePanel

@onready var across_list = $MarginContainer/VBoxContainer/AcrossScrollContainer/AcrossList
@onready var down_list = $MarginContainer/VBoxContainer/DownScrollContainer/DownList

var current_direction: String = ""
var current_number: int = -1

func _ready():
	var h = get_viewport_rect().size.y
	custom_minimum_size = Vector2(0, h * 0.25) # 25% of screen height


func show_clue(direction: String, number: int) -> void:
	current_direction = direction
	current_number = number
	
	_clear_highlights()

	var target_list = across_list if direction == "Across" else down_list
	
	for child in target_list.get_children():
		if child.has_meta("clue_number") and child.get_meta("clue_number") == number:
			child.add_theme_color_override("font_color", Color(1, 0.85, 0.3)) # highlight
			break


func populate_clues(clues: Dictionary) -> void:
	_clear_list(across_list)
	_clear_list(down_list)

	for clue in clues["across"]:
		_add_clue_label(across_list, clue)

	for clue in clues["down"]:
		_add_clue_label(down_list, clue)


func _add_clue_label(container: VBoxContainer, clue: Dictionary):
	var label := Label.new()
	label.text = str(int(clue["number"])) + ". " + clue["clue"]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.set_meta("clue_number", clue["number"])
	label.add_theme_font_size_override("font_size", 20)
	container.add_child(label)

func _clear_list(container: VBoxContainer):
	for child in container.get_children():
		child.queue_free()


func _clear_highlights():
	for list in [across_list, down_list]:
		for child in list.get_children():
			child.remove_theme_color_override("font_color")
