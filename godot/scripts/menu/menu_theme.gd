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


static func style_dock_panel(panel: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.1, 0.16, 0.92)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(ACCENT, 0.28)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)


static func style_chip_button(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.13, 0.19, 0.55)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.border_width_bottom = 2
	sb.border_color = Color(ACCENT, 0.35)
	sb.content_margin_left = 2
	sb.content_margin_right = 2
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	btn.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.14, 0.18, 0.26, 0.85)
	hover.border_color = Color(ACCENT, 0.65)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := sb.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.06, 0.09, 0.14, 0.95)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", sb.duplicate())
	btn.focus_mode = Control.FOCUS_NONE


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
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.22, 0.34, 0.46)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := sb.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.12, 0.2, 0.3)
	pressed.shadow_size = 0
	btn.add_theme_stylebox_override("pressed", pressed)
	var disabled := sb.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.14, 0.16, 0.2, 0.85)
	disabled.border_color = Color(MUTED, 0.35)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", TEXT)
	btn.add_theme_color_override("font_disabled_color", Color(MUTED, 0.85))
	btn.add_theme_font_size_override("font_size", 18)
	btn.custom_minimum_size = Vector2(46, 46)


static func style_deploy_button(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.32, 0.22, 0.96)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = Color(0.45, 0.92, 0.55, 0.85)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.42, 0.28, 0.98)
	hover.border_color = Color(0.55, 0.98, 0.65, 1.0)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := sb.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.08, 0.22, 0.16, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed)
	var disabled := sb.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.1, 0.12, 0.14, 0.92)
	disabled.border_color = Color(MUTED, 0.25)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.92, 0.98, 0.94))
	btn.add_theme_color_override("font_disabled_color", Color(MUTED, 0.75))
	btn.add_theme_font_size_override("font_size", 15)
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


static func style_compact_button(btn: Button, emphasize: bool = false) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.2, 0.28, 0.96)
	sb.corner_radius_top_left = 7
	sb.corner_radius_top_right = 7
	sb.corner_radius_bottom_left = 7
	sb.corner_radius_bottom_right = 7
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = Color(ACCENT if emphasize else MUTED, 0.6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.2, 0.27, 0.36, 0.98)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := sb.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.11, 0.17, 0.24, 1.0)
	pressed.shadow_size = 0
	btn.add_theme_stylebox_override("pressed", pressed)
	var disabled := sb.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.13, 0.15, 0.19, 0.85)
	disabled.border_color = Color(MUTED, 0.35)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", TEXT)
	btn.add_theme_color_override("font_disabled_color", Color(MUTED, 0.85))
	btn.add_theme_font_size_override("font_size", 13 if emphasize else 12)
	btn.custom_minimum_size = Vector2(44, 44)
