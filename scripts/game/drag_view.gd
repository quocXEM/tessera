extends Control

var game: Node = null


func _ready() -> void:
	game = owner
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if game == null:
		return
	var drag_i: int = game._drag_i
	if drag_i < 0:
		return
	var tray: Array = game._tray
	var piece = tray[drag_i]
	if piece == null:
		return
	const CELL := 72.0
	const GAP := 4.0
	var cells: Array = piece.cells
	var min_x := 99
	var max_x := -99
	var min_y := 99
	var max_y := -99
	for c in cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	var w := float(max_x - min_x + 1) * (CELL + GAP) - GAP
	var h := float(max_y - min_y + 1) * (CELL + GAP) - GAP
	var drag_pos: Vector2 = game._drag_pos
	var origin: Vector2 = drag_pos - global_position - Vector2(w, h) * 0.5
	var col: Color = piece.color
	col.a = 0.9
	for c in cells:
		var p: Vector2 = origin + Vector2(float(c.x - min_x) * (CELL + GAP), float(c.y - min_y) * (CELL + GAP))
		draw_rect(Rect2(p, Vector2(CELL, CELL)), col, true)
