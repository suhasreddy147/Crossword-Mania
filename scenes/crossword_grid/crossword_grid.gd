extends Control

enum Direction { ACROSS, DOWN }

var active_direction: Direction = Direction.ACROSS

var cell_scene: PackedScene = preload(
	"res://scenes/crossword_grid/Cell.tscn"
)

@onready var clue_panel = get_parent().get_node("../CluePanel")

var puzzle_clues : Dictionary = {}
var puzzle_grid_data : Dictionary = {}

var cellSize : int

var selected_cell: Cell = null

var grid_cells: Array = [] # 2D array [row][col]

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	clue_panel.clue_selected.connect(_on_clue_selected)

func build_from_puzzle(puzzle: Dictionary):
	puzzle_clues = puzzle["clues"]
	puzzle_grid_data = puzzle["grid"]

	var rows: int = puzzle_grid_data["rows"]
	var cols: int = puzzle_grid_data["cols"]
	var cells: Array = puzzle_grid_data["cells"]
	
	clue_panel.populate_clues(puzzle_clues)

	# Ensure cell size is initialized
	var cell_size := _get_cell_size()
	@warning_ignore("narrowing_conversion")
	cellSize = cell_size.x

	# Clear old cells
	for child in grid_container.get_children():
		child.queue_free()

	grid_cells.clear()

	# Configure GridContainer
	grid_container.columns = cols
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for row in range(rows):
		var row_cells := []

		for col in range(cols):
			var character: String = cells[row][col]
			var cell := cell_scene.instantiate() as Cell
			if cell == null:
				push_error("Cell scene root is not of type Cell")
				return

			# Let container handle layout
			grid_container.add_child(cell)

			# Make every cell square
			cell.custom_minimum_size = Vector2(cellSize, cellSize)
			cell.size_flags_horizontal = Control.SIZE_FILL
			cell.size_flags_vertical = Control.SIZE_FILL

			if character == "#":
				cell.set_black(true)
			else:
				cell.set_black(false)

			cell.cell_pressed.connect(_on_cell_pressed)
			row_cells.append(cell)
			var clue_start_number := _get_clue_start_number(row, col)
			cell.set_number(clue_start_number)
		grid_cells.append(row_cells)

func _get_cell_size() -> Vector2:
	var temp := cell_scene.instantiate() as Cell
	@warning_ignore("shadowed_variable_base_class")
	var size := temp.get_cell_size()
	temp.queue_free()
	return size
	
func _on_cell_pressed(cell: Cell) -> void:
	if cell.is_black:
		return
	
	var pos := _find_cell_position(cell)
	if pos.x == -1:
		return
	
	var row := pos.x
	var col := pos.y
	
	var has_across := _has_across_word(row, col)
	var has_down := _has_down_word(row, col)

	# Deselect previous
	#if selected_cell != null:
		#selected_cell.set_selected(false)
	
	# Auto-detect direction on first tap
	if selected_cell != cell:
		if has_across and not has_down:
			active_direction = Direction.ACROSS
		elif has_down and not has_across:
			active_direction = Direction.DOWN
		# else: both valid → keep current direction
	else:
		# Second tap toggles direction
		if has_across and has_down:
			active_direction = (
				Direction.DOWN if active_direction == Direction.ACROSS
				else Direction.ACROSS
			)

	# Select new
	selected_cell = cell
	#selected_cell.set_selected(true)
	_update_active_word()

func _update_active_word():
	_clear_all_highlights()

	if selected_cell == null:
		return

	var pos := _find_cell_position(selected_cell)
	if pos.x == -1:
		return

	var row := pos.x
	var col := pos.y

	var word_cells := []

	if active_direction == Direction.ACROSS:
		word_cells = _collect_across(row, col)
	else:
		word_cells = _collect_down(row, col)

	var start_pos = _find_cell_position(word_cells[0])

	for cell in word_cells:
		cell.set_word_highlighted(true)
	# Highlight the tapped cell more strongly
	selected_cell.set_cursor_highlighted(true)
	_update_clue_panel(start_pos.x, start_pos.y)

func _clear_all_highlights():
	for row in grid_cells:
		for cell in row:
			cell.set_word_highlighted(false)
			cell.set_cursor_highlighted(false)
			
func _find_cell_position(target: Cell) -> Vector2i:
	for r in range(grid_cells.size()):
		for c in range(grid_cells[r].size()):
			if grid_cells[r][c] == target:
				return Vector2i(r, c)
	return Vector2i(-1, -1) # not found
	
func _collect_across(row: int, col: int) -> Array:
	var result := []

	var c := col
	while c >= 0 and not grid_cells[row][c].is_black:
		c -= 1
	c += 1

	while c < grid_cells[row].size() and not grid_cells[row][c].is_black:
		result.append(grid_cells[row][c])
		c += 1

	return result

func _collect_down(row: int, col: int) -> Array:
	var result := []

	var r := row
	while r >= 0 and not grid_cells[r][col].is_black:
		r -= 1
	r += 1

	while r < grid_cells.size() and not grid_cells[r][col].is_black:
		result.append(grid_cells[r][col])
		r += 1

	return result
	
func _has_across_word(row: int, col: int) -> bool:
	if col > 0 and not grid_cells[row][col - 1].is_black:
		return true
	if col < grid_cells[row].size() - 1 and not grid_cells[row][col + 1].is_black:
		return true
	return false

func _has_down_word(row: int, col: int) -> bool:
	if row > 0 and not grid_cells[row - 1][col].is_black:
		return true
	if row < grid_cells.size() - 1 and not grid_cells[row + 1][col].is_black:
		return true
	return false

func _update_clue_panel(row: int, col: int):

	var clue_number := _get_clue_start_number(row, col)

	if clue_number == -1:
		return

	var direction_key := "across" if active_direction == Direction.ACROSS else "down"

	if not puzzle_clues.has(direction_key):
		return

	var clue_list : Array = puzzle_clues[direction_key]

	for clue in clue_list:
		if clue["number"] == clue_number:
			clue_panel.show_clue(direction_key.capitalize(), clue_number)
			return

func _get_clue_number(row: int, col: int) -> int:

	var number := 1

	for r in range(grid_cells.size()):
		for c in range(grid_cells[r].size()):

			if grid_cells[r][c].is_black:
				continue

			var start_across := false
			var start_down := false

			if (c == 0 or grid_cells[r][c - 1].is_black) and (c < grid_cells[r].size() - 1 and not grid_cells[r][c + 1].is_black):
				start_across = true

			if (r == 0 or grid_cells[r - 1][c].is_black) and (r < grid_cells.size() - 1 and not grid_cells[r + 1][c].is_black):
				start_down = true

			if start_across or start_down:
				if r == row and c == col:
					return number
				number += 1
	return -1
	
func _get_clue_start_number(row: int, col: int) -> int:
	# Check across clues
	for clue in puzzle_clues["across"]:
		if clue["row"] == row and clue["col"] == col:
			return clue["number"]

	# Check down clues
	for clue in puzzle_clues["down"]:
		if clue["row"] == row and clue["col"] == col:
			return clue["number"]

	return 0

func _on_clue_selected(row: int, col:int, direction:String):
	
	#Update direction
	active_direction = (Direction.ACROSS if direction == "across" else Direction.DOWN)
	
	#Select first cell of word
	selected_cell = grid_cells[row][col]
	
	_update_active_word()
