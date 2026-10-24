class_name TesseraShapes
## Weighted polyomino catalog — studio balance (rare big pieces).


static func _raw() -> Array:
	return [
		# weight, cells
		[12, [Vector2i(0, 0)]],
		[10, [Vector2i(0, 0), Vector2i(1, 0)]],
		[10, [Vector2i(0, 0), Vector2i(0, 1)]],
		[8, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]],
		[8, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]],
		[7, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]],
		[7, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)]],
		[7, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]],
		[7, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]],
		[6, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]],
		[6, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]],
		[8, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]],
		[5, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)]],
		[5, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1)]],
		[5, [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 0)]],
		[5, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)]],
		[5, [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(0, 2)]],
		[5, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]],
		[5, [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]],
		[5, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]],
		[5, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]],
		[6, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)]],
		[6, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]],
		[6, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]],
		[6, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]],
		[3, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]],
		[3, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]],
		[1, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]],
	]


static func colors() -> Array[Color]:
	return [
		Color(0.94, 0.84, 0.62),
		Color(0.82, 0.72, 0.88),
		Color(0.68, 0.82, 0.86),
		Color(0.92, 0.7, 0.62),
		Color(0.74, 0.86, 0.7),
		Color(0.9, 0.78, 0.55),
		Color(0.76, 0.68, 0.9),
	]


static func random_piece() -> Dictionary:
	var raw: Array = _raw()
	var total := 0
	for e in raw:
		total += int(e[0])
	var roll := randi() % total
	var acc := 0
	var cells: Array = raw[0][1]
	for e in raw:
		acc += int(e[0])
		if roll < acc:
			cells = e[1]
			break
	var cols: Array[Color] = colors()
	return {
		"cells": cells.duplicate(),
		"color": cols[randi() % cols.size()],
	}
