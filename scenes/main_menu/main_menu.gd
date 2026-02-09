extends Control

var has_active_game: bool = false

@onready var continue_button: Button = $MainLayoutMarginContainer/MainLayout/ButtonsContainer/ContinueButton
@onready var continue_info_label: Label = $MainLayoutMarginContainer/MainLayout/ButtonsContainer/ContinueInfoLabel
@onready var settings_button: TextureButton = $MainLayoutMarginContainer/MainLayout/TopBarContainer/SettingsContainer/SettingsButton
@onready var store_button: TextureButton = $MainLayoutMarginContainer/MainLayout/TopBarContainer/StoreContainer/StoreButton

func _ready() -> void:
	update_continue_button_state()
	var puzzle = PuzzleLoader.load_puzzle("res://data/puzzles/puzzle_0001/en.json")
	print(PuzzleLoader)
	if puzzle.is_empty():
		print('Puzzle failed to load')
	else:
		print('Puzzle loaded successfully')
		print(puzzle['title'])


func update_continue_button_state() -> void:
	continue_button.disabled = not has_active_game
	continue_info_label.visible = has_active_game

func _process(_delta: float) -> void:
	pass

func _on_settings_button_pressed() -> void:
	print("Settings entry point pressed (placeholder)")

func _on_store_button_pressed() -> void:
	print("Store entry point pressed (placeholder)")
