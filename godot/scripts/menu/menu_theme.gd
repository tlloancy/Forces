class_name MenuTheme
extends RefCounted

const BG := Color(0.102, 0.133, 0.165)
const PANEL := Color(0.14, 0.17, 0.21)
const TEXT := Color(0.92, 0.94, 0.96)
const MUTED := Color(0.65, 0.72, 0.78)
const ACCENT := Color(0.35, 0.62, 0.95)


static func style_panel(panel: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)


static func style_title(label: Label, size: int = 36) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT)


static func style_body(label: Label) -> void:
	label.add_theme_color_override("font_color", MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
