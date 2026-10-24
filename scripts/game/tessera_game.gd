extends Control
## Tessera studio build — Blockudoku, mobile-first, international juice.

const N := 9
const BOARD_PAD := 10.0
const DRAG_LIFT := 160.0 # piece floats above finger (see the board)

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
@onready var fx: Control = %FxLayer

var cell := 96.0
var gap := 4.0
var _grid: Array = []
var _colors: Array = []
var _tray: Array = []
var _score := 0
var _alive := true
var _new_best := false
var _hint_done := false
var _drag_i := -1
var _drag_pos := Vector2.ZERO
var _preview: Vector2i = Vector2i(-1, -1)
var _preview_ok := false
var _combo_chain := 0
var _clearing := false
var _shake := 0.0


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
	if not SaveData.coach_seen:
		var coach: CanvasLayer = (load("res://scripts/ui/coach_overlay.gd") as GDScript).new()
		add_child(coach)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.35)


func _layout_board() -> void:
	if board_host == null:
		return
	var vs := get_viewport_rect().size
	var max_side := mini(vs.x - 80.0, vs.y * 0.48)
	gap = 4.0
	cell = (max_side - BOARD_PAD * 2.0 - gap * float(N - 1)) / float(N)
	cell = clampf(cell, 56.0, 104.0)
	var side := float(N) * cell + float(N - 1) * gap + BOARD_PAD * 2.0
	board_host.custom_minimum_size = Vector2(side, side)
	board_host.size = Vector2(side, side)
	if tray_host:
		tray_host.custom_minimum_size = Vector2(side, 200.0)


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
	_clearing = false
	hint_l.visible = true
	over.visible = false
	dim.visible = false
	_paint_hud()
	_redraw_all()
	_check_game_over()


func _restart() -> void:
	AudioBus.play_ui()
	_start()


func _paint_hud() -> void:
	score_l.text = str(_score)
	best_l.text = Loc.tr_key("menu.best") % SaveData.best
	over_score.text = Loc.tr_key("over.score") % _score
	over_best.text = Loc.tr_key("over.new_best") % SaveData.best if _new_best else Loc.tr_key("over.best") % SaveData.best


func _redraw_all() -> void:
	if board_host:
		board_host.queue_redraw()
	if tray_host:
		tray_host.queue_redraw()
	if drag_layer:
		drag_layer.queue_redraw()
	if fx:
		fx.queue_redraw()


func _cell_index(x: int, y: int) -> int:
	return y * N + x


func _cell_at_global(g: Vector2) -> Vector2i:
	var local := g - board_host.global_position - Vector2(BOARD_PAD, BOARD_PAD)
	var step := cell + gap
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
	_vibrate(12)
	_clear_lines_async()


func _clear_lines_async() -> void:
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
		board_host.queue_redraw()
		return

	_clearing = true
	_alive = false # lock input during juice
	# Flash marked cells
	var flash_cells: Array[Vector2i] = []
	for y in rows:
		for x in N:
			flash_cells.append(Vector2i(x, y))
	for x in cols:
		for y in N:
			flash_cells.append(Vector2i(x, y))
	for b in boxes:
		for y in range(b.y * 3, b.y * 3 + 3):
			for x in range(b.x * 3, b.x * 3 + 3):
				flash_cells.append(Vector2i(x, y))
	_spawn_clear_fx(flash_cells)
	_shake = 10.0 if clears >= 2 else 5.0
	await get_tree().create_timer(0.18).timeout

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
	var pts := clears * 12 * _combo_chain + clears * clears * 8
	_score += pts
	_paint_hud()
	_pop_score()
	_float_points(pts)
	if clears >= 2 or _combo_chain > 1:
		_flash(Loc.tr_key("flash.combo") % maxi(clears, _combo_chain), Color(0.98, 0.9, 0.7, 1))
		AudioBus.play_combo()
		_vibrate(28)
	else:
		_flash(Loc.tr_key("flash.clear"), Color(0.9, 0.86, 0.8, 0.9))
		AudioBus.play_clear()
		_vibrate(18)

	_clearing = false
	_alive = true
	board_host.queue_redraw()
	_check_game_over()


func _spawn_clear_fx(cells: Array[Vector2i]) -> void:
	for p in cells:
		var world := board_host.global_position + Vector2(BOARD_PAD, BOARD_PAD) + Vector2(float(p.x) * (cell + gap), float(p.y) * (cell + gap))
		var r := ColorRect.new()
		r.size = Vector2(cell, cell)
		r.position = world - fx.global_position
		r.color = Color(1, 1, 1, 0.85)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fx.add_child(r)
		var tw := create_tween()
		tw.tween_property(r, "modulate:a", 0.0, 0.28)
		tw.parallel().tween_property(r, "scale", Vector2(1.15, 1.15), 0.28)
		tw.tween_callback(r.queue_free)


func _float_points(pts: int) -> void:
	var lab := Label.new()
	lab.text = "+%d" % pts
	lab.add_theme_font_size_override("font_size", 32)
	lab.add_theme_color_override("font_color", Color(0.94, 0.84, 0.62, 1))
	lab.position = Vector2(size.x * 0.5 - 40.0, size.y * 0.28)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.add_child(lab)
	var tw := create_tween()
	tw.tween_property(lab, "position:y", lab.position.y - 60.0, 0.55)
	tw.parallel().tween_property(lab, "modulate:a", 0.0, 0.55)
	tw.tween_callback(lab.queue_free)


func _vibrate(ms: int) -> void:
	if DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(ms)


func _refill_tray_if_needed() -> void:
	var empty := true
	for p in _tray:
		if p != null:
			empty = false
			break
	if empty:
		_tray = [TesseraShapes.random_piece(), TesseraShapes.random_piece(), TesseraShapes.random_piece()]
	tray_host.queue_redraw()
	if not _clearing:
		_check_game_over()


func _check_game_over() -> void:
	if _clearing or not _alive:
		return
	for p in _tray:
		if p != null and _any_placement(p):
			return
	_alive = false
	AudioBus.play_fail()
	_vibrate(40)
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
	score_l.scale = Vector2(1.14, 1.14)
	create_tween().tween_property(score_l, "scale", Vector2.ONE, 0.18)


func _flash(text: String, col: Color) -> void:
	flash_l.text = text
	flash_l.modulate = col
	var tw := create_tween()
	tw.tween_property(flash_l, "modulate:a", 0.0, 0.75).from(1.0)


func _tray_slot_rect(i: int) -> Rect2:
	var w := tray_host.size.x / 3.0
	return Rect2(Vector2(w * float(i), 0), Vector2(w, tray_host.size.y))


func _process(delta: float) -> void:
	if _shake > 0.0:
		_shake = maxf(0.0, _shake - delta * 40.0)
		board_host.position.x = sin(_shake * 2.0) * (_shake * 0.35)
	else:
		board_host.position.x = 0.0


func _input(event: InputEvent) -> void:
	if not _alive or _clearing:
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
		for i in 3:
			if _tray[i] == null:
				continue
			var r := _tray_slot_rect(i)
			r.position += tray_host.global_position
			if r.has_point(pos):
				_drag_i = i
				_drag_pos = pos + Vector2(0, -DRAG_LIFT)
				_hint_done = true
				hint_l.visible = false
				_update_preview(_drag_pos)
				_redraw_all()
				return
	else:
		if _drag_i < 0:
			return
		var piece = _tray[_drag_i]
		if _preview_ok and piece != null:
			_place(piece, _preview)
			_tray[_drag_i] = null
			_refill_tray_if_needed()
		_drag_i = -1
		_preview = Vector2i(-1, -1)
		_preview_ok = false
		_redraw_all()


func _handle_drag(pos: Vector2) -> void:
	if _drag_i < 0:
		return
	_drag_pos = pos + Vector2(0, -DRAG_LIFT)
	_update_preview(_drag_pos)
	_redraw_all()


func _update_preview(pos: Vector2) -> void:
	var piece: Dictionary = _tray[_drag_i]
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
	var half := footprint * (cell + gap) * 0.5
	var anchor := pos - half + Vector2(cell * 0.5, cell * 0.5)
	var cell_pos := _cell_at_global(anchor)
	cell_pos.x -= min_x
	cell_pos.y -= min_y
	_preview = cell_pos
	_preview_ok = _can_place(piece, cell_pos)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_board()
		_redraw_all()
