class_name TesseraShapes
## Polyomino catalog for Blockudoku-style play.


static func catalog() -> Array:
	# Each shape: Array[Vector2i] of cells
	return [
		[Vector2i(0, 0)], # dot
		[Vector2i(0, 0), Vector2i(1, 0)], # domino H
		[Vector2i(0, 0), Vector2i(0, 1)], # domino V
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)], # tri I
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)], # L3
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], # I4
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # O
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)], # L4
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1)],
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 0)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], # Z/S
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)], # T
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)], # 3x3
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 2x3
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)], # 3x2
	]


static func colors() -> Array[Color]:
	return [
		Color(0.94, 0.84, 0.62),
		Color(0.82, 0.72, 0.88),
		Color(0.7, 0.82, 0.86),
		Color(0.9, 0.72, 0.64),
		Color(0.76, 0.86, 0.72),
		Color(0.88, 0.78, 0.58),
		Color(0.78, 0.7, 0.9),
	]


static func random_piece() -> Dictionary:
	var cat: Array = catalog()
	var cells: Array = cat[randi() % cat.size()]
	var cols: Array[Color] = colors()
	return {
		"cells": cells.duplicate(),
		"color": cols[randi() % cols.size()],
	}
