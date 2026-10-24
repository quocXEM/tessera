extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("SMOKE: start")
	var scr = load("res://scripts/game/tessera_game.gd")
	if scr == null:
		push_error("SMOKE FAIL script")
		quit(1)
		return
	print("SMOKE: parsed")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await create_timer(0.3).timeout
	change_scene_to_file("res://scenes/game.tscn")
	await create_timer(0.5).timeout
	var root := current_scene
	if root == null or not root.has_method("_can_place"):
		push_error("SMOKE FAIL game")
		quit(1)
		return
	# Place first tray piece at first valid cell
	var piece = root._tray[0]
	var placed := false
	for y in 9:
		for x in 9:
			if root._can_place(piece, Vector2i(x, y)):
				root._place(piece, Vector2i(x, y))
				root._tray[0] = null
				placed = true
				break
		if placed:
			break
	print("SMOKE: placed ", placed)
	await create_timer(0.2).timeout
	print("SMOKE: PASS")
	quit(0)
