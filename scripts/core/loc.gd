extends Node

signal language_changed(code: String)

const SUPPORTED := ["en", "vi"]
var code: String = "en"

var _t := {
	"en": {
		"game.title": "Tessera",
		"game.tag": "Place blocks. Clear the grid.",
		"menu.play": "Play",
		"menu.best": "Best  %d",
		"menu.leave": "Leave",
		"hud.hint": "Drag a block onto the board",
		"over.title": "No moves",
		"over.score": "Score  %d",
		"over.best": "Best  %d",
		"over.new_best": "New best  %d",
		"over.retry": "Again",
		"over.menu": "Menu",
		"flash.clear": "Clear",
		"flash.combo": "Combo ×%d",
	},
	"vi": {
		"game.title": "Tessera",
		"game.tag": "Đặt khối. Xóa lưới.",
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
