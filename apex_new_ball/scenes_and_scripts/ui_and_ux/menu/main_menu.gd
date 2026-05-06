extends Control

const SLOT_MENU_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/menu.tscn"
const LEVEL_SELECT_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/level_select.tscn"
const SETTINGS_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/settings_menu.tscn"

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var _parallax: Parallax2D = $Parallax
@onready var _shade: ColorRect = $Shade
@onready var _safe_area: Control = $SafeArea
@onready var _main_stack: VBoxContainer = $SafeArea/MainStack
@onready var _logo: TextureRect = $SafeArea/MainStack/Logo
@onready var _play_button: TextureButton = $SafeArea/MainStack/PlayButton
@onready var _icon_row: HBoxContainer = $SafeArea/MainStack/IconRow
@onready var _levels_button: TextureButton = $SafeArea/MainStack/IconRow/LevelsButton
@onready var _settings_button: TextureButton = $SafeArea/MainStack/IconRow/SettingsButton
@onready var _quit_button: TextureButton = $SafeArea/MainStack/IconRow/QuitButton

func _ready() -> void:
	get_tree().paused = false
	MusicManager.set_paused(false)
	MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	_refresh_optional_actions()
	get_viewport().size_changed.connect(_apply_adaptive_layout)
	call_deferred("_apply_adaptive_layout")

func _apply_adaptive_layout() -> void:
	var rect := get_viewport().get_visible_rect()
	var w := rect.size.x
	var h := rect.size.y
	if w <= 0.0 or h <= 0.0:
		return

	var scale_ref := minf(w / _REF_W, h / _REF_H)
	var compact := w < 760.0 or h < 560.0
	var width_factor := 0.78 if compact else 0.46
	var logo_factor := 0.33 if compact else 0.36
	var vertical_factor := 0.42 if compact else 0.46
	var margin := clampf(minf(w, h) * 0.045, 20.0, 64.0)
	var stack_w := clampf(w * width_factor, 300.0, 560.0)
	var logo_h := clampf(stack_w * logo_factor, 96.0, 210.0)
	var play_w := clampf(stack_w * 0.9, 260.0, 500.0)
	var play_h := play_w * 0.47
	var icon_size := clampf(82.0 * scale_ref, 58.0, 108.0)
	var gap := clampf(18.0 * scale_ref, 10.0, 28.0)
	var stack_h := logo_h + play_h + icon_size + gap * 2.0
	var top_y := rect.position.y + maxf(margin, (h - stack_h) * vertical_factor)

	_parallax.position = Vector2(rect.position.x, rect.position.y + h - _parallax.get_anchor_bottom_extent())
	_shade.position = rect.position
	_shade.size = rect.size
	_safe_area.position = rect.position
	_safe_area.size = rect.size

	_main_stack.position = Vector2(rect.position.x + (w - stack_w) * 0.5, top_y)
	_main_stack.size = Vector2(stack_w, minf(stack_h, h - margin * 2.0))
	_main_stack.add_theme_constant_override("separation", int(gap))

	_logo.custom_minimum_size = Vector2(stack_w, logo_h)
	_play_button.custom_minimum_size = Vector2(play_w, play_h)
	_icon_row.custom_minimum_size = Vector2(stack_w, icon_size)
	_icon_row.add_theme_constant_override("separation", int(clampf(20.0 * scale_ref, 10.0, 34.0)))

	for button in [_levels_button, _settings_button, _quit_button]:
		button.custom_minimum_size = Vector2(icon_size, icon_size)
		button.size = Vector2(icon_size, icon_size)

func _refresh_optional_actions() -> void:
	var has_level_select := ResourceLoader.exists(LEVEL_SELECT_SCENE)
	var level_button_alpha := 1.0 if has_level_select else 0.45
	_levels_button.disabled = not has_level_select
	_levels_button.modulate = Color(1.0, 1.0, 1.0, level_button_alpha)
	_levels_button.tooltip_text = "Level Select"

func _change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Scene not found: %s" % path)
		return
	get_tree().change_scene_to_file(path)

func _play_click() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)

func _on_play_button_pressed() -> void:
	_play_click()
	_change_scene(SLOT_MENU_SCENE)

func _on_levels_button_pressed() -> void:
	_play_click()
	_change_scene(LEVEL_SELECT_SCENE)

func _on_settings_button_pressed() -> void:
	_play_click()
	_change_scene(SETTINGS_SCENE)

func _on_quit_button_pressed() -> void:
	_play_click()
	get_tree().quit()
