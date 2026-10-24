extends Control
## Tessera — Blockudoku: place polyominoes, clear rows/cols/boxes.

const N := 9
const CELL := 96.0
const GAP := 4.0
const BOARD_PAD := 8.0

@onready var score_l: Label = %Score
@onready var best_l: Label = %Best
@onready var hint_l: Label = %Hint
@onready var flash_l: Label = %Flash
@onready var board_host: Control = %BoardHost
@onready var tray_host: Control = %TrayHost
@onready var over: PanelContainer = %Over
@onready var over_title: Label = %OverTitle
@onready var over_score: Label = %OverScore
@onready var over_best: Label = %OverBest
@onready var btn_retry: Button = %Retry
@onready var btn_menu: Button = %Menu
@onready var dim: ColorRect = %Dim
@onready var drag_layer: Control = %DragLayer

var _grid: Array = [] # N*N ints 0 empty, else color packed as Color
var _colors: Array = [] # Color per cell
var _tray: Array = [] # 3 pieces {cells, color} or null
var _score := 0
var _alive := true
var _new_best := false
var _hint_done := false
var _drag_i := -1
var _drag_pos := Vector2.ZERO
var _preview: Vector2i = Vector2i(-1, -1)
var _preview_ok := false
var _board_origin := Vector2.ZERO
var _combo_chain := 0


func _ready() -> void:
	btn_retry.pressed.connect(_restart)
	btn_menu.pressed.connect(func() -> void:
		AudioBus.play_ui()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	over.visible = false
	dim.visible = false
	flash_l.modulate.a = 0.0
	_layout_board()
	_refresh_loc()
	Loc.language_changed.connect(func(_c): _refresh_loc())
	_start()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.35)


func _layout_board() -> void:
	if board_host == null:
		return
	var side := N * CELL + (N - 1) * GAP + BOARD_PAD * 2.0
	board_host.custom_minimum_size = Vector2(side, side)
	board_host.size = Vector2(side, side)


func _refresh_loc() -> void:
	hint_l.text = Loc.tr_key("hud.hint")
	over_title.text = Loc.tr_key("over.title")
	btn_retry.text = Loc.tr_key("over.retry")
	btn_menu.text = Loc.tr_key("over.menu")
	_paint_hud()


func _start() -> void:
	_grid.clear()
	_colors.clear()
	for i in N * N:
		_grid.append(0)
		_colors.append(Color.TRANSPARENT)
	_tray = [TesseraShapes.random_piece(), TesseraShapes.random_piece(), TesseraShapes.random_piece()]
	_score = 0
	_alive = true
	_new_best = false
	_hint_done = false
	_drag_i = -1
	_combo_chain = 0
	hint_l.visible = true
	over.visible = false
	dim.visible = false
	_paint_hud()
	queue_redraw()
	board_host.queue_redraw()
	tray_host.queue_redraw()
	drag_layer.queue_redraw()
	_check_game_over()


func _restart() -> void:
	AudioBus.play_ui()
	_start()


func _paint_hud() -> void:
	score_l.text = str(_score)
	best_l.text = Loc.tr_key("menu.best") % SaveData.best
	over_score.text = Loc.tr_key("over.score") % _score
	over_best.text = Loc.tr_key("over.new_best") % SaveData.best if _new_best else Loc.tr_key("over.best") % SaveData.best


func _cell_index(x: int, y: int) -> int:
	return y * N + x


func _board_rect() -> Rect2:
	return Rect2(board_host.global_position, board_host.size)


func _cell_at_global(g: Vector2) -> Vector2i:
	var local := g - board_host.global_position - Vector2(BOARD_PAD, BOARD_PAD)
	var step := CELL + GAP
	var x := int(floor(local.x / step))
	var y := int(floor(local.y / step))
	return Vector2i(x, y)


func _can_place(piece: Dictionary, origin: Vector2i) -> bool:
	if piece == null or not piece.has("cells"):
		return false
	for c in piece.cells:
		var p: Vector2i = origin + c
		if p.x < 0 or p.y < 0 or p.x >= N or p.y >= N:
			return false
		if int(_grid[_cell_index(p.x, p.y)]) != 0:
			return false
	return true


func _any_placement(piece: Dictionary) -> bool:
	for y in N:
		for x in N:
			if _can_place(piece, Vector2i(x, y)):
				return true
	return false


func _place(piece: Dictionary, origin: Vector2i) -> void:
	var col: Color = piece.color
	for c in piece.cells:
		var p: Vector2i = origin + c
		var idx := _cell_index(p.x, p.y)
		_grid[idx] = 1
		_colors[idx] = col
	AudioBus.play_place()
	_clear_lines()
	board_host.queue_redraw()


func _clear_lines() -> void:
	var rows: Array[int] = []
	var cols: Array[int] = []
	var boxes: Array[Vector2i] = []
	for y in N:
		var full := true
		for x in N:
			if int(_grid[_cell_index(x, y)]) == 0:
				full = false
				break
		if full:
			rows.append(y)
	for x in N:
		var full := true
		for y in N:
			if int(_grid[_cell_index(x, y)]) == 0:
				full = false
				break
		if full:
			cols.append(x)
	for by in 3:
		for bx in 3:
			var full := true
			for y in range(by * 3, by * 3 + 3):
				for x in range(bx * 3, bx * 3 + 3):
					if int(_grid[_cell_index(x, y)]) == 0:
						full = false
						break
				if not full:
					break
			if full:
				boxes.append(Vector2i(bx, by))

	var clears := rows.size() + cols.size() + boxes.size()
	if clears == 0:
		_combo_chain = 0
		return

	for y in rows:
		for x in N:
			_grid[_cell_index(x, y)] = 0
	for x in cols:
		for y in N:
			_grid[_cell_index(x, y)] = 0
	for b in boxes:
		for y in range(b.y * 3, b.y * 3 + 3):
			for x in range(b.x * 3, b.x * 3 + 3):
				_grid[_cell_index(x, y)] = 0

	_combo_chain += 1
	var pts := clears * 10 * _combo_chain + clears * clears * 5
	_score += pts
	_paint_hud()
	_pop_score()
	if clears >= 2 or _combo_chain > 1:
		_flash(Loc.tr_key("flash.combo") % maxi(clears, _combo_chain), Color(0.98, 0.9, 0.7, 1))
		AudioBus.play_combo()
	else:
		_flash(Loc.tr_key("flash.clear"), Color(0.9, 0.86, 0.8, 0.9))
		AudioBus.play_clear()


func _refill_tray_if_needed() -> void:
	var empty := true
	for p in _tray:
		if p != null:
			empty = false
			break
	if empty:
		_tray = [TesseraShapes.random_piece(), TesseraShapes.random_piece(), TesseraShapes.random_piece()]
	tray_host.queue_redraw()
	_check_game_over()


func _check_game_over() -> void:
	for p in _tray:
		if p != null and _any_placement(p):
			return
	# none placeable
	_alive = false
	AudioBus.play_fail()
	_new_best = _score > SaveData.best
	SaveData.note_score(_score)
	_paint_hud()
	dim.visible = true
	dim.modulate.a = 0.0
	over.visible = true
	over.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(dim, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(over, "modulate:a", 1.0, 0.3)


func _pop_score() -> void:
	score_l.pivot_offset = score_l.size * 0.5
	score_l.scale = Vector2(1.12, 1.12)
	create_tween().tween_property(score_l, "scale", Vector2.ONE, 0.18)


func _flash(text: String, col: Color) -> void:
	flash_l.text = text
	flash_l.modulate = col
	var tw := create_tween()
	tw.tween_property(flash_l, "modulate:a", 0.0, 0.7).from(1.0)


func _tray_slot_rect(i: int) -> Rect2:
	var w := tray_host.size.x / 3.0
	return Rect2(Vector2(w * float(i), 0), Vector2(w, tray_host.size.y))


func _gui_input(event: InputEvent) -> void:
	# fallthrough — board/tray handle via _input on this Control with mouse_filter STOP on root
	pass


func _input(event: InputEvent) -> void:
	if not _alive:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event.index, event.pressed, event.position)
	elif event is InputEventScreenDrag:
		_handle_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(0, event.pressed, event.position)
	elif event is InputEventMouseMotion and _drag_i >= 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_handle_drag(event.position)


func _handle_touch(idx: int, pressed: bool, pos: Vector2) -> void:
	if idx > 0:
		return
	if pressed:
		# Pick from tray?
		for i in 3:
			if _tray[i] == null:
				continue
			var r := _tray_slot_rect(i)
			r.position += tray_host.global_position
			if r.has_point(pos):
				_drag_i = i
				_drag_pos = pos
				_hint_done = true
				hint_l.visible = false
				_update_preview(pos)
				drag_layer.queue_redraw()
				tray_host.queue_redraw()
				return
	else:
		if _drag_i < 0:
			return
		var piece: Dictionary = _tray[_drag_i]
		if _preview_ok and piece != null:
			_place(piece, _preview)
			_tray[_drag_i] = null
			_refill_tray_if_needed()
		_drag_i = -1
		_preview = Vector2i(-1, -1)
		_preview_ok = false
		drag_layer.queue_redraw()
		tray_host.queue_redraw()
		board_host.queue_redraw()


func _handle_drag(pos: Vector2) -> void:
	if _drag_i < 0:
		return
	_drag_pos = pos
	_update_preview(pos)
	drag_layer.queue_redraw()
	board_host.queue_redraw()


func _update_preview(pos: Vector2) -> void:
	var piece: Dictionary = _tray[_drag_i]
	# Anchor: finger is center of piece footprint
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
	var footprint := Vector2(float(max_x - min_x + 1), float(max_y - min_y + 1))
	var half := footprint * (CELL + GAP) * 0.5
	var anchor := pos - half + Vector2(CELL * 0.5, CELL * 0.5)
	var cell := _cell_at_global(anchor)
	cell.x -= min_x
	cell.y -= min_y
	_preview = cell
	_preview_ok = _can_place(piece, cell)


func _draw() -> void:
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_board()
