extends Control
class_name VirtualKeyboard

signal letter_pressed(letter: String)
signal backspace_pressed

#@onready var grid: GridContainer = $MarginContainer/GridContainer
@onready var row1 : HBoxContainer = $MarginContainer/VBoxContainer/Row1
@onready var row2 : HBoxContainer = $MarginContainer/VBoxContainer/Row2
@onready var row3 : HBoxContainer = $MarginContainer/VBoxContainer/Row3

const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var KEY_SIZE := Vector2(48, 48)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_width := get_viewport_rect().size.x
	if screen_width > 600:
		KEY_SIZE.x = 56
		KEY_SIZE.y = 46
	_build_qwerty_keyboard()
	#_build_keyboard() # Replace with function body.

func _build_qwerty_keyboard():
	_build_row(row1, ["Q","W","E","R","T","Y","U","I","O","P"])
	_build_row(row2, ["A","S","D","F","G","H","J","K","L"])
	_build_last_row_with_backspace(["Z","X","C","V","B","N","M"])

func _build_row(container: HBoxContainer, letters: Array):
	
	for letter in letters:
		var btn := _create_key_button(letter)
		container.add_child(btn)

func _build_last_row_with_backspace(letters: Array):
	# Letter keys
	for letter in letters:
		var btn := _create_key_button(letter)
		row3.add_child(btn)

	# Backspace key at end
	var backspace := _create_key_button("⌫", true)
	backspace.pressed.connect(func():
		backspace_pressed.emit()
	)
	row3.add_child(backspace)

func _create_key_button(text: String, is_backspace  := false) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = KEY_SIZE
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if is_backspace :
		btn.custom_minimum_size.x = KEY_SIZE.x * 2
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_stretch_ratio = 2.0
	else:
		btn.size_flags_stretch_ratio = 1.0
		btn.pressed.connect(func():
			letter_pressed.emit(text)
		)
	btn.focus_mode = Control.FOCUS_NONE
	return btn
