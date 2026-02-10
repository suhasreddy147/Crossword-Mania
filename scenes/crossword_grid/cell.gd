extends Panel
class_name Cell
@onready var letter_label: Label = $Letter
	
func set_letter(character: String):
	letter_label.text = character
	
func set_black(is_black: bool):
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if is_black:
		style.bg_color = Color.BLACK
		letter_label.modulate = Color.WHITE
	else:
		style.bg_color = Color.WHITE
		letter_label.modulate = Color.BLACK
	
	add_theme_stylebox_override("panel", style)

func set_debug_text(t: String):
	letter_label.text = t
	
func get_cell_size() -> Vector2:
	return custom_minimum_size
