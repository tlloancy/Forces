class_name MenuTheme
extends RefCounted
## Palette inspirée jeux de stratégie mobile (carte centrale, accents dorés).

const BG := Color(0.06, 0.09, 0.14)
const BG_MAP := Color(0.09, 0.16, 0.24)
const PANEL := Color(0.11, 0.14, 0.19, 0.94)
const TEXT := Color(0.96, 0.94, 0.88)
const MUTED := Color(0.62, 0.68, 0.74)
const ACCENT := Color(0.82, 0.68, 0.22)
const ACCENT_HOVER := Color(0.92, 0.78, 0.32)


static func style_panel(panel: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(ACCENT, 0.35)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", sb)


static func style_title(label: Label, size: int = 44) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", ACCENT)


static func style_body(label: Label) -> void:
	label.add_theme_color_override("font_color", MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


static func style_primary_button(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.28, 0.38)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.border_width_bottom = 2
	sb.border_color = ACCENT
	btn.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.22, 0.34, 0.46)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", TEXT)
	btn.add_theme_font_size_override("font_size", 18)
