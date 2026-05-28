extends Control

@onready var _summary: RichTextLabel = %SummaryLabel

@onready var _blue_kind: OptionButton = %BlueKind
@onready var _blue_diff: OptionButton = %BlueDiff
@onready var _red_kind: OptionButton = %RedKind
@onready var _red_diff: OptionButton = %RedDiff
@onready var _yellow_kind: OptionButton = %YellowKind
@onready var _yellow_diff: OptionButton = %YellowDiff


func _ready() -> void:
	_fill_kind_options(_blue_kind)
	_fill_kind_options(_red_kind)
	_fill_kind_options(_yellow_kind)
	_fill_diff_options(_blue_diff)
	_fill_diff_options(_red_diff)
	_fill_diff_options(_yellow_diff)
	_load_from_session()
	_refresh_summary()


func _fill_kind_options(ob: OptionButton) -> void:
	ob.clear()
	ob.add_item("AI", GameSession.SlotKind.AI)
	ob.add_item("Human (local)", GameSession.SlotKind.HUMAN)


func _fill_diff_options(ob: OptionButton) -> void:
	ob.clear()
	ob.add_item("Easy", GameSession.Difficulty.EASY)
	ob.add_item("Normal", GameSession.Difficulty.NORMAL)
	ob.add_item("Hard", GameSession.Difficulty.HARD)


func _load_from_session() -> void:
	_set_row(GameConstants.Camp.BLUE, _blue_kind, _blue_diff)
	_set_row(GameConstants.Camp.RED, _red_kind, _red_diff)
	_set_row(GameConstants.Camp.YELLOW, _yellow_kind, _yellow_diff)


func _set_row(camp: GameConstants.Camp, kind_ob: OptionButton, diff_ob: OptionButton) -> void:
	_select_by_id(kind_ob, int(GameSession.slot_kind(camp)))
	_select_by_id(diff_ob, int(GameSession.slot_difficulty(camp)))
	diff_ob.disabled = int(GameSession.slot_kind(camp)) == GameSession.SlotKind.HUMAN


func _select_by_id(ob: OptionButton, id: int) -> void:
	for i: int in ob.get_item_count():
		if ob.get_item_id(i) == id:
			ob.select(i)
			return


func _apply_row(camp: GameConstants.Camp, kind_ob: OptionButton, diff_ob: OptionButton) -> void:
	var kind: int = kind_ob.get_selected_id()
	var diff: int = diff_ob.get_selected_id()
	GameSession.set_slot(camp, kind as GameSession.SlotKind, diff as GameSession.Difficulty)
	diff_ob.disabled = kind == GameSession.SlotKind.HUMAN


func _refresh_summary() -> void:
	_summary.clear()
	_summary.append_text("[b]Green[/b] : Player (you)\n")
	for line: String in GameSession.setup_summary_lines():
		if line.begins_with("Green"):
			continue
		_summary.append_text(line + "\n")
	var humans: int = GameSession.human_player_count()
	if humans > 1:
		_summary.append_text("\n[color=orange]Local multiplayer: coming soon. Only Green is playable for now.[/color]")


func _on_slot_changed(_index: int = -1) -> void:
	_apply_row(GameConstants.Camp.BLUE, _blue_kind, _blue_diff)
	_apply_row(GameConstants.Camp.RED, _red_kind, _red_diff)
	_apply_row(GameConstants.Camp.YELLOW, _yellow_kind, _yellow_diff)
	_refresh_summary()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_start_pressed() -> void:
	_on_slot_changed()
	GameSession.clear_saved_battle()
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
