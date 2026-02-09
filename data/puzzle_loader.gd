extends Node

func load_puzzle(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Puzzle file not found: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open puzzle file: %s" % path)
		return {}

	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON format in: %s" % path)
		return {}

	var puzzle: Dictionary = parsed

	if not _validate_puzzle(puzzle):
		push_error("Puzzle validation failed: %s" % path)
		return {}

	return puzzle


func _validate_puzzle(puzzle: Dictionary) -> bool:
	if not puzzle.has("grid"):
		return false

	var grid = puzzle["grid"]
	if typeof(grid) != TYPE_DICTIONARY:
		return false

	if not grid.has("rows") or not grid.has("cols") or not grid.has("cells"):
		return false

	var rows: int = grid["rows"]
	var cols: int = grid["cols"]
	var cells = grid["cells"]

	if typeof(cells) != TYPE_ARRAY:
		return false

	if cells.size() != rows:
		return false

	for row in cells:
		if typeof(row) != TYPE_STRING:
			return false
		if row.length() != cols:
			return false

	if not puzzle.has("clues"):
		return false

	var clues = puzzle["clues"]
	if typeof(clues) != TYPE_DICTIONARY:
		return false

	return true
