extends CanvasLayer
## One-shot coach — international casual standard.


func _ready() -> void:
	layer = 40
	if SaveData.coach_seen:
		queue_free()
		return
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.03, 0.05, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_top = -200
	panel.offset_right = 300
	panel.offset_bottom = 200
	add_child(panel)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)

	var title := Label.new()
	title.text = Loc.tr_key("coach.title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.14, 0.11, 0.1, 1))
	v.add_child(title)

	for key in ["coach.1", "coach.2", "coach.3"]:
		var row := Label.new()
		row.text = Loc.tr_key(key)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_font_size_override("font_size", 20)
		row.add_theme_color_override("font_color", Color(0.28, 0.24, 0.2, 0.9))
		v.add_child(row)

	var btn := Button.new()
	btn.text = Loc.tr_key("coach.ok")
	btn.custom_minimum_size = Vector2(220, 56)
	btn.pressed.connect(_dismiss)
	v.add_child(btn)


func _dismiss() -> void:
	AudioBus.play_ui()
	SaveData.mark_coach_seen()
	queue_free()
