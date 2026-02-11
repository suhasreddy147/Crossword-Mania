extends Panel
class_name Cell

signal cell_pressed(cell: Cell)

@onready var letter_label: Label = $Letter

var is_black: bool = false
var is_selected: bool = false

func _ready() -> void:
	# Ensure fixed-size control (no anchor stretching)
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	# Defer size assignment so Godot doesn't override it
	set_deferred("size", custom_minimum_size)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
func _gui_input(event: InputEvent) -> void:
	if is_black:
		return
	
	if event is InputEventMouseButton and event.pressed:
		cell_pressed.emit(self)

func set_letter(character: String):
	letter_label.text = character
	
func set_black(is_black_val: bool):
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	is_black = is_black_val
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

func set_selected(selected: bool) -> void:
	is_selected = selected
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if is_black:
		style.bg_color = Color.BLACK
	elif is_selected:
		style.bg_color = Color(0.9, 0.85, 0.4) # soft yellow highlight
		letter_label.modulate = Color.BLACK
	else:
		style.bg_color = Color.WHITE
		letter_label.modulate = Color.BLACK
	add_theme_stylebox_override("panel", style)
