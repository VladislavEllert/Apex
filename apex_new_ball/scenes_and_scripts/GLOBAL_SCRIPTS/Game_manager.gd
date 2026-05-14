extends Node

var pause_scene
var music_volume_percent: float = 75.0
var sfx_volume_percent: float = 100.0
var control_sensitivity: float = 5.0
var local_save: Dictionary

func _ready() -> void:
	_load_user_settings()
	_apply_user_settings()
	_save_debounce_timer = Timer.new()
	_save_debounce_timer.wait_time = 0.5
	_save_debounce_timer.one_shot = true
	add_child(_save_debounce_timer)
	_save_debounce_timer.timeout.connect(_save_user_settings)

	Events.TOUCHING_THE_FLAG.connect(_touch)
	Events.COLLECTING_COINS.connect(_collect)
	Events.OPEN_THE_CHEST.connect(_chest)
	Events.HEALING.connect(_heal)
	Events.OPEN_THE_DOOR.connect(_door)
	Events.PLAYER_RESPAWN.connect(_respa)
	
	local_save = SaveManager.load()
	if local_save["player"]["lives"] < 1:
		SaveManager.delete()
		local_save = SaveManager.get_default_data()

#region Фнукции для настроек
func set_music_volume_percent(value: float) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	MusicManager.set_volume_percent(music_volume_percent)
	_schedule_save_user_settings()

func set_sfx_volume_percent(value: float) -> void:
	sfx_volume_percent = clampf(value, 0.0, 100.0)
	SFXManager.set_volume_percent(sfx_volume_percent)
	_schedule_save_user_settings()

func set_control_sensitivity(value: float) -> void:
	control_sensitivity = clampf(value, 1.0, 10.0)
	Events.CONTROL_SENSITIVITY_CHANGED.emit(control_sensitivity)
	_schedule_save_user_settings()

func _load_user_settings() -> void:
	var settings := SaveManager.load_settings()
	music_volume_percent = float(settings.get("music_volume", music_volume_percent))
	sfx_volume_percent = float(settings.get("sfx_volume", sfx_volume_percent))
	control_sensitivity = float(settings.get("control_sensitivity", control_sensitivity))

func _apply_user_settings() -> void:
	MusicManager.set_volume_percent(music_volume_percent)
	SFXManager.set_volume_percent(sfx_volume_percent)

func _save_user_settings() -> void:
	SaveManager.save_settings({
		"music_volume": music_volume_percent,
		"sfx_volume": sfx_volume_percent,
		"control_sensitivity": control_sensitivity
	})
#endregion

var _save_debounce_timer: Timer

func _schedule_save_user_settings() -> void:
	if _save_debounce_timer.is_stopped():
		_save_debounce_timer.start()
	else:
		_save_debounce_timer.stop()
		_save_debounce_timer.start()

#region Флаги для изменений в сейв
func _touch(sprite):
	sprite.animation = "flag"
	Events.UI_FLAGS_UPDATED.emit()

func _respa():
	pass

func _collect(sprite):
	sprite.modulate.a = 0
	Events.UI_SCORE_UPDATED.emit()

func _chest(sprite):
	sprite.animation = "chest"
	Events.UI_SCORE_UPDATED.emit()

func _heal(sprite):
	if sprite:
		sprite.modulate.a = 0
	SaveManager.save(local_save)
	Events.UI_LIVES_UPDATED.emit()

func _door(sprite):
	sprite.animation = "open"
#endregion
