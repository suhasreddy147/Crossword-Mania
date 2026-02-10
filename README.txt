Project: Crossword Mania
Engine: Godot 4
Last Updated: 2026-02-09
JSON file format is explained below:

1. Overview
Each crossword puzzle is stored as a single JSON file.
The JSON format is designed to be:
Easy to read and edit by humans
Safe to parse in Godot
Extensible for future features (packs, daily challenges, multiple languages)

2. File Location & Naming
res://data/puzzles/
 └── puzzle_001/
	  ├── en.json
One folder per puzzle ID
One JSON file per language
Language files use ISO 639-1 codes (e.g. en, es, fr)

3. Top-Level JSON Structure
{
  "id": "puzzle_001",
  "language": "en",
  "title": "First Steps",
  "author": "Crossword Mania",
  "difficulty": "easy",
  "grid": { ... },
  "clues": { ... }
}

4. Required fields
Field						Type										Description
id							string										Unique puzzle identifier
language					string										Language code (ISO 639-1)
title						string										Display title
grid						object										Grid layout and solution
clues						object										Across and Down clues

5. Optional fields
Field						Type										Description
author						string										Puzzle author
difficulty					string										easy, medium, hard, etc
_comment					string										Human-readable notes (ignored by game)

6. Grid Object
"grid": {
  "rows": 5,
  "cols": 5,
  "cells": [
	"HELLO",
	"E#A#S",
	"L#P#E",
	"L#O#N",
    "OCEAN"
  ]
}


7. Grid rules
rows × cols defines grid size
Each entry in cells represents one row
Each row string must be exactly cols characters long
# represents a black (blocked) cell
Letters represent solution characters (A–Z)

8. Clues Object
"clues": {
  "across": [ ... ],
  "down": [ ... ]
}
Both across and down are arrays of clue objects.

9. Clue Object Format
{
  "number": 1,
  "row": 0,
  "col": 0,
  "length": 5,
  "clue": "A common greeting",
  "answer": "HELLO"
}

10. Clue fields
Field						Type										Description
number						int											Clue number (display only)
row							int											Starting row (0-based)
col							int											Starting column (0-based)
length						int											Number of letters
clue						string										Clue text shown to player
answer						string										Correct answer (uppercase)

11. Indexing Rules
Rows and columns are 0-based
Top-left cell is (row: 0, col: 0)
Answers are written left-to-right (Across) or top-to-bottom (Down)

12. Comments & Notes
JSON does not support comments.
To include human-readable notes, use:
"_comment": "This puzzle is used as the tutorial level."
The game ignores all keys starting with _.

13. Validation Rules (Enforced by Loader)
cells.length == rows
Each row string length == cols
clues must contain across and down
Missing or invalid data causes the puzzle to fail loading safely

13. Future Extensions (Planned)
This format supports future additions such as:
Puzzle packs
Daily challenges
Time limits
Rewards
Analytics metadata
Server-downloaded puzzles

Example extension:
"meta": {
  "pack": "easy_pack_01",
  "is_daily": false
}


14. Design Philosophy
Clarity over cleverness
Explicit over implicit
One puzzle per file
Language-specific grids
This keeps puzzles easy to author, debug, and scale.

15. Contact
For format changes or questions, update this README alongside the JSON files.
