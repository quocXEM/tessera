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
	var cell: float = game.cell * 0.85
	var gap: float = game.gap
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
	var w := float(max_x - min_x + 1) * (cell + gap) - gap
	var h := float(max_y - min_y + 1) * (cell + gap) - gap
	var drag_pos: Vector2 = game._drag_pos
	var origin: Vector2 = drag_pos - global_position - Vector2(w, h) * 0.5
	var col: Color = piece.color
	col.a = 0.92
	# soft shadow under floating piece
	for c in cells:
		var p: Vector2 = origin + Vector2(float(c.x - min_x) * (cell + gap), float(c.y - min_y) * (cell + gap)) + Vector2(4, 8)
		draw_rect(Rect2(p, Vector2(cell, cell)), Color(0, 0, 0, 0.25), true)
	for c in cells:
		var p2: Vector2 = origin + Vector2(float(c.x - min_x) * (cell + gap), float(c.y - min_y) * (cell + gap))
		draw_rect(Rect2(p2, Vector2(cell, cell)), col, true)
