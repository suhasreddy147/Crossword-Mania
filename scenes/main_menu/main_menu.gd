extends Control

var has_active_game: bool = false

@onready var continue_button: Button = $MainLayoutMarginContainer/MainLayout/ButtonsContainer/ContinueButton

@onready var continue_info_label: Label = $MainLayoutMarginContainer/MainLayout/ButtonsContainer/ContinueInfoLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_continue_button_state() # Replace with function body.

func update_continue_button_state() -> void:
	continue_button.disabled = not has_active_game
	continue_info_label.visible = has_active_game

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
