extends Control

const SLOT_MENU_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/menu.tscn"
const LEVEL_SELECT_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/level_select.tscn"
const SETTINGS_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/settings_menu.tscn"

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var _parallax: Parallax2D = $TextureRect/Parallax
@onready var _safe_area: MarginContainer = $MarginContainer
@onready var _main_stack: VBoxContainer = $MarginContainer/VBoxContainer
@onready var _logo: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var _buttons_container: VBoxContainer = $MarginContainer/VBoxContainer/Buttons
@onready var _play_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Play
@onready var _settings_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Settings
@onready var _quit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Exit

func _ready() -> void:
	get_tree().paused = false
	# MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	if _parallax:
		_parallax.autoscroll_surfaces = true
		if _parallax.has_method("_update_autoscroll"):
			_parallax._update_autoscroll()

	# Подключаем сигналы кнопок
	_play_button.pressed.connect(_on_play_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)

	get_viewport().size_changed.connect(_apply_adaptive_layout)
	call_deferred("_apply_adaptive_layout")

func _apply_adaptive_layout() -> void:
	var rect := get_viewport().get_visible_rect()
	var w := rect.size.x
	var h := rect.size.y
	if w <= 0.0 or h <= 0.0:
		return

	var scale_ref := minf(w / _REF_W, h / _REF_H)

	if _parallax:
		_parallax.position = Vector2(rect.position.x, rect.position.y + h - _parallax.get_anchor_bottom_extent())

	# Настройка контейнера кнопок под размер экрана
	var button_h := clampf(80.0 * scale_ref, 60.0, 100.0)
	_play_button.custom_minimum_size.y = button_h
	_settings_button.custom_minimum_size.y = button_h
	_quit_button.custom_minimum_size.y = button_h

func _change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Scene not found: %s" % path)
		return
	get_tree().change_scene_to_file(path)

func _play_click_sfx() -> void:
	if has_node("/root/SFXManager"):
		SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)

func _on_play_button_pressed() -> void:
	_play_click_sfx()
	_change_scene(SLOT_MENU_SCENE)

func _on_settings_button_pressed() -> void:
	_play_click_sfx()
	_change_scene(SETTINGS_SCENE)

func _on_quit_button_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()
