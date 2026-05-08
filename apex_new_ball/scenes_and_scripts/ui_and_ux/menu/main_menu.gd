extends Control

const SLOT_MENU_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/menu.tscn"
const SETTINGS_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/settings_menu.tscn"

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var _parallax: Parallax2D = $Parallax
@onready var _play_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Play
@onready var _settings_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Settings
@onready var _quit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Exit
@onready var _music_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/TonggleMusic
@onready var _github_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/GitHub

func _ready() -> void:
	get_tree().paused = false
	MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	if _parallax:
		_parallax.autoscroll_surfaces = true
		if _parallax.has_method("_update_autoscroll"):
			_parallax._update_autoscroll()

	# Подключаем сигналы кнопок
	_play_button.pressed.connect(_on_play_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)
	_music_button.toggled.connect(_on_music_toggled)
	_github_button.pressed.connect(_on_github_button_pressed)
	
	_music_button.set_pressed_no_signal(GameManager.music_volume_percent <= 0)

	get_viewport().size_changed.connect(_apply_adaptive_layout)
	call_deferred("_apply_adaptive_layout")

func _apply_adaptive_layout() -> void:
	var rect := get_viewport().get_visible_rect()
	if rect.size.x <= 0 or rect.size.y <= 0: return

	var scale_ref := minf(rect.size.x / _REF_W, rect.size.y / _REF_H)

	if _parallax:
		_parallax.position = Vector2(rect.position.x, rect.position.y + rect.size.y - _parallax.get_anchor_bottom_extent())

	var btn_h := clampf(80.0 * scale_ref, 60.0, 100.0)
	_play_button.custom_minimum_size.y = btn_h
	_settings_button.custom_minimum_size.y = btn_h
	_quit_button.custom_minimum_size.y = btn_h

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(SLOT_MENU_SCENE)

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_music_toggled(toggled_on: bool) -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	
	# Убиваем возможный fade_tween, чтобы он не перезаписал громкость
	if MusicManager.fade_tween:
		MusicManager.fade_tween.kill()
		MusicManager.fade_tween = null
	
	if toggled_on:
		GameManager.set_music_volume_percent(0.0)
	else:
		GameManager.set_music_volume_percent(75.0)

func _on_github_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	OS.shell_open("https://github.com/top-it-090304/Apex")
