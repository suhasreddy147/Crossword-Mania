extends Control
var crossword_grid_scene: PackedScene = preload(
        "res://scenes/crossword_grid/CrosswordGrid.tscn"
	)

func _ready():
	print("TEST SCENE READY")
	test_function()
	
func test_function():
	#Below code is for testing purposes only and has to be removed later
	var puzzle = PuzzleLoader.load_puzzle("res://data/puzzles/puzzle_0001/en.json")
	print(PuzzleLoader)
	if puzzle.is_empty():
		print('Puzzle failed to load')
	else:
		print('Puzzle loaded successfully')
		print(puzzle['title'])
	var crossword_grid = crossword_grid_scene.instantiate()
	add_child(crossword_grid)
	crossword_grid.anchor_left = 0
	crossword_grid.anchor_top = 0
	crossword_grid.anchor_right = 1
	crossword_grid.anchor_bottom = 1
	crossword_grid.build_from_puzzle(puzzle)
