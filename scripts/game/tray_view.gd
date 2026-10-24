extends Control

var game: Node = null


func _ready() -> void:
	game = owner
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if game == null:
		return
	var cell := 40.0
	var gap := 3.0
	var tray: Array = game._tray
	var drag_i: int = game._drag_i
	for i in 3:
		var slot: Rect2 = game._tray_slot_rect(i)
		draw_rect(slot.grow(-12), Color(0.12, 0.1, 0.12, 0.75), true)
		draw_rect(slot.grow(-12), Color(0.94, 0.84, 0.62, 0.08), false, 1.0)
		var piece = tray[i]
		if piece == null or i == drag_i:
			continue
		_draw_piece(piece, slot.get_center(), cell, gap)


func _draw_piece(piece: Dictionary, center: Vector2, cell: float, gap: float) -> void:
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
	var origin := center - Vector2(w, h) * 0.5
	var col: Color = piece.color
	for c in cells:
		var p := origin + Vector2(float(c.x - min_x) * (cell + gap), float(c.y - min_y) * (cell + gap))
		draw_rect(Rect2(p, Vector2(cell, cell)), col, true)
