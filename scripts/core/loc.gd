extends Node

signal language_changed(code: String)

const SUPPORTED := ["en", "vi"]
var code: String = "en"

var _t := {
	"en": {
		"game.title": "Tessera",
		"game.tag": "Place. Clear. Think ahead.",
		"menu.play": "Play",
		"menu.best": "Best  %d",
		"menu.leave": "Leave",
		"hud.hint": "Drag a block up",
		"over.title": "No moves",
		"over.score": "Score  %d",
		"over.best": "Best  %d",
		"over.new_best": "New best  %d",
		"over.retry": "Again",
		"over.menu": "Menu",
		"flash.clear": "Clear",
		"flash.combo": "Combo ×%d",
		"coach.title": "How to play",
		"coach.1": "Drag a block onto the board.",
		"coach.2": "Fill a row, column, or 3×3 box to clear.",
		"coach.3": "Plan ahead — no moves ends the run.",
		"coach.ok": "Play",
	},
	"vi": {
		"game.title": "Tessera",
		"game.tag": "Đặt. Xóa. Nghĩ trước.",
		"menu.play": "Chơi",
		"menu.best": "Cao nhất  %d",
		"menu.leave": "Thoát",
		"hud.hint": "Kéo khối lên bàn",
		"over.title": "Hết nước",
		"over.score": "Điểm  %d",
		"over.best": "Cao nhất  %d",
		"over.new_best": "Kỷ lục mới  %d",
		"over.retry": "Lại",
		"over.menu": "Menu",
		"flash.clear": "Xóa",
		"flash.combo": "Combo ×%d",
		"coach.title": "Cách chơi",
		"coach.1": "Kéo khối lên bàn.",
		"coach.2": "Đầy hàng, cột hoặc ô 3×3 để xóa.",
		"coach.3": "Nghĩ trước — hết nước là hết ván.",
		"coach.ok": "Chơi",
	},
}


func tr_key(key: String) -> String:
	var table: Dictionary = _t.get(code, _t["en"])
	if table.has(key):
		return str(table[key])
	return str(_t["en"].get(key, key))


func set_language(new_code: String) -> void:
	if new_code not in SUPPORTED:
		return
	code = new_code
	language_changed.emit(code)
