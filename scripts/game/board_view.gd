extends Control

var game: Node = null


func _ready() -> void:
	game = owner
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if game == null:
		return
	const N := 9
	var cell: float = game.cell
	var gap: float = game.gap
	const PAD := 10.0
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.11, 0.09, 0.11, 0.98), true)
	# soft inner rim
	draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color(0.16, 0.13, 0.15, 0.35), false, 2.0)
	var grid: Array = game._grid
	var colors: Array = game._colors
	for y in N:
		for x in N:
			var p := Vector2(PAD + x * (cell + gap), PAD + y * (cell + gap))
			var r := Rect2(p, Vector2(cell, cell))
			var zone := ((x / 3) + (y / 3)) % 2 == 0
			var base := Color(0.17, 0.14, 0.17, 1) if zone else Color(0.14, 0.12, 0.14, 1)
			draw_rect(r, base, true)
			var idx: int = y * N + x
			if int(grid[idx]) != 0:
				var col: Color = colors[idx]
				draw_rect(r.grow(-3), col, true)
				draw_rect(Rect2(r.position + Vector2(5, 5), Vector2(r.size.x - 10, 9)), Color(1, 1, 1, 0.2), true)
	var drag_i: int = game._drag_i
	if drag_i >= 0:
		var tray: Array = game._tray
		var piece = tray[drag_i]
		if piece != null:
			var preview: Vector2i = game._preview
			var ok: bool = game._preview_ok
			if preview.x >= 0:
				var ghost: Color = piece.color
				ghost.a = 0.6 if ok else 0.22
				for c in piece.cells:
					var p2: Vector2i = preview + c
					if p2.x < 0 or p2.y < 0 or p2.x >= N or p2.y >= N:
						continue
					var pos := Vector2(PAD + p2.x * (cell + gap), PAD + p2.y * (cell + gap))
					var gr := Rect2(pos, Vector2(cell, cell)).grow(-3)
					draw_rect(gr, ghost, true)
					if ok:
						draw_rect(gr, Color(1, 1, 1, 0.35), false, 2.0)
