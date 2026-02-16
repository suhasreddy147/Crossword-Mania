extends Control

@onready var crossword_grid = $VBoxContainer/CenterContainer/CrosswordGrid
@onready var keyboard = $VBoxContainer/VirtualKeyboard

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load a test puzzle
	var puzzle = PuzzleLoader.load_puzzle("res://data/puzzles/puzzle_0002/en.json")
	crossword_grid.build_from_puzzle(puzzle)

	# Wire keyboard to grid
	keyboard.letter_pressed.connect(_on_letter_pressed)
	keyboard.backspace_pressed.connect(_on_backspace_pressed)

func _on_letter_pressed(letter: String):
	if crossword_grid.selected_cell == null:
		return
	crossword_grid.selected_cell.set_letter(letter)

func _on_backspace_pressed():
	if crossword_grid.selected_cell == null:
		return
	crossword_grid.selected_cell.set_letter("")
