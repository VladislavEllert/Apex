extends Control

const SETTINGS_SCENE := "res://scenes_and_scripts/ui_and_ux/menu/settings_menu.tscn"

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var _parallax: Parallax2D = $Parallax
@onready var _play_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Play
@onready var _continue_restart_row: HBoxContainer = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow
@onready var _continue_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow/Continue
@onready var _delete_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow/Delete
@onready var _settings_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Settings
@onready var _quit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Exit

func _ready() -> void:
	get_tree().paused = false
	MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	if _parallax:
		_parallax.autoscroll_surfaces = true
		if _parallax.has_method("_update_autoscroll"):
			_parallax._update_autoscroll()

	# Подключаем сигналы кнопок
	_play_button.pressed.connect(_on_play_button_pressed)
	_continue_button.pressed.connect(_on_continue_button_pressed)
	_delete_button.pressed.connect(_on_delete_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)

	_refresh_buttons()

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
	_continue_button.custom_minimum_size.y = btn_h
	_delete_button.custom_minimum_size.y = btn_h
	_settings_button.custom_minimum_size.y = btn_h
	_quit_button.custom_minimum_size.y = btn_h

#region Переключение видимости кнопок в зависимости от наличия сейва
func _refresh_buttons() -> void:
	var has_save := SaveManager.exists()
	_play_button.visible = not has_save
	_continue_restart_row.visible = has_save
#endregion

#region Кнопка запуска новой игры (когда сейва нет)
func _on_play_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	SaveManager.save(SaveManager.get_default_data())
	GameManager.local_save = SaveManager.load()
	get_tree().change_scene_to_file(GameManager.local_save["level"]["current_scene"])
#endregion

#region Кнопка продолжения игры (когда сейв есть)
func _on_continue_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	GameManager.local_save = SaveManager.load()
	var path: String = GameManager.local_save["level"]["current_scene"]
	if not ResourceLoader.exists(path):
		push_warning("Сейв ссылается на отсутствующую сцену: " + path)
		SaveManager.delete()
		GameManager.local_save = SaveManager.get_default_data()    
		_refresh_buttons()
		return
	get_tree().change_scene_to_file(path)
#endregion

#region Кнопка удаления сохранения (Restart) — стирает сейв, UI возвращается к "новой игре"
func _on_delete_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	SaveManager.delete()
	GameManager.local_save = SaveManager.get_default_data()
	_refresh_buttons()
#endregion

#region Кнопка открытия настроек
func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)
#endregion

#region Кнопка выхода из игры
func _on_quit_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	if not GameManager.local_save.is_empty():
		SaveManager.save(GameManager.local_save)
	get_tree().quit()
#endregion
