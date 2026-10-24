extends Node

const PATH := "user://tessera.save"

var best: int = 0
var games: int = 0
var coach_seen: bool = false


func _ready() -> void:
	_load()


func note_score(score: int) -> void:
	games += 1
	if score > best:
		best = score
	_save()


func mark_coach_seen() -> void:
	coach_seen = true
	_save()


func _save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_var({"best": best, "games": games, "coach_seen": coach_seen})


func _load() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var data = f.get_var()
	if data is Dictionary:
		best = int(data.get("best", 0))
		games = int(data.get("games", 0))
		coach_seen = bool(data.get("coach_seen", false))
