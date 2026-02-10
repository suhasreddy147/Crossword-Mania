extends Control

var cell_scene: PackedScene = preload(
	"res://scenes/crossword_grid/Cell.tscn"
)

var cellSize : int

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
	
	# Calculate grid size
	var grid_width := cols * cellSize
	var grid_height := rows * cellSize
	
	# Center grid manually
	var viewport_size := get_viewport_rect().size
	var origin := Vector2(
		(viewport_size.x - grid_width) * 0.5,
		(viewport_size.y - grid_height) * 0.5
	)
		
	var index := 0
	for row in range(rows):
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
			
			cell.set_debug_text(str(index))
			index += 1

func _get_cell_size() -> Vector2:
	var temp := cell_scene.instantiate() as Cell
	@warning_ignore("shadowed_variable_base_class")
	var size := temp.get_cell_size()
	temp.queue_free()
	return size
