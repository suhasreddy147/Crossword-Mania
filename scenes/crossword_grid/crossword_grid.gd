extends Control

enum Direction { ACROSS, DOWN }

var active_direction: Direction = Direction.ACROSS

var cell_scene: PackedScene = preload(
	"res://scenes/crossword_grid/Cell.tscn"
)

var cellSize : int

var selected_cell: Cell = null

var grid_cells: Array = [] # 2D array [row][col]

func build_from_puzzle(puzzle: Dictionary):
	var grid_data = puzzle["grid"]
	var rows: int = grid_data["rows"]
	var cols: int = grid_data["cols"]
	var cells: Array = grid_data["cells"]
	
	var cell_size := _get_cell_size()
	@warning_ignore("narrowing_conversion")
	cellSize = cell_size.x
	
	# Clear old cells
	for child in get_children():
		child.queue_free()

	grid_cells.clear()

	# Calculate grid size
	var grid_width := cols * cellSize
	var grid_height := rows * cellSize
	
	# Center grid manually
	var viewport_size := get_viewport_rect().size
	var origin := Vector2(
		(viewport_size.x - grid_width) * 0.5,
		(viewport_size.y - grid_height) * 0.5
	)
	
	for row in range(rows):
		var row_cells := []
		for col in range(cols):
			var character : String = cells[row][col]
			var cell := cell_scene.instantiate() as Cell
			if cell == null:
				push_error("Cell scene root is not of type Cell")
				return
			
			add_child(cell)
			cell.position = origin + Vector2(
				col * cellSize,
				row * cellSize
			)

			cell.custom_minimum_size = Vector2(cellSize, cellSize)
			
			if character == '#':
				cell.set_black(true)
			else:
				cell.set_black(false)
			
			#CONNECT SELECTION SIGNAL
			cell.cell_pressed.connect(_on_cell_pressed)
			row_cells.append(cell)
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

	for cell in word_cells:
		cell.set_word_highlighted(true)
	# Highlight the tapped cell more strongly
	selected_cell.set_cursor_highlighted(true)

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
