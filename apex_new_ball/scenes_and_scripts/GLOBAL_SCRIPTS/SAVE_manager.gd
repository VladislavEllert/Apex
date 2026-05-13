extends Node
 
const SAVE_PATH = "user://game_data.cfg"
const SETTINGS_SECTION = "app_settings"
const SAVE_SECTIONS = ["player", "level"]

#region Функции для работы сохранений
func _ready() -> void:
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			_commit_cache()
			get_tree().quit()
		NOTIFICATION_APPLICATION_PAUSED:
			_commit_cache()

func _commit_cache() -> void:
	if GameManager.local_save and not GameManager.local_save.is_empty():
		save(GameManager.local_save)

func save(data: Dictionary) -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH)   # подгружаем существующий, чтобы не затереть settings
	
	for section in data.keys():
		for key in data[section].keys():
			var value = data[section][key]
			if value is Vector2:
				value = {"x": value.x, "y": value.y}
			config.set_value(section, key, value)
	
	config.save(SAVE_PATH)

func load() -> Dictionary:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return get_default_data()
	
	var data = {}
	for section in SAVE_SECTIONS:
		if not config.has_section(section):
			continue
		data[section] = {}
		for key in config.get_section_keys(section):
			data[section][key] = config.get_value(section, key)
	
	if data.is_empty():
		return get_default_data()
	return data

func delete() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for section in SAVE_SECTIONS:
		if config.has_section(section):
			config.erase_section(section)
	config.save(SAVE_PATH)

func exists() -> bool:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
	return config.has_section("player")
#endregion

 #region Дефолтные значения для сохранения
func get_default_data() -> Dictionary:
	return {
		"player": {
			"score": 0,
			"lives": 3,
			"max_lives": 100
		},
		"level": {
			"scene_number": 1,
			"current_scene": "res://scenes_and_scripts/levels/level_1.tscn",
			"checkpoint_position": {"x": 0, "y": 0},
			"flags_total": 0,
			"flags_collected": 0,
			"flags_collected_coordinates_level": [],
			"coins_collected_coordinates_level": [],
			"chests_collected_coordinates_level": [],
			"lives_collected_coordinates_level": []
		}
	}
#endregion

#region Дефолтные значения в настройках
func get_default_settings() -> Dictionary:
	return {
		"music_volume": 75.0,
		"sfx_volume": 100.0,
		"control_sensitivity": 5.0
	}
#endregion

#region Функции для работы настроек
func save_settings(data: Dictionary) -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH)

	for key in data.keys():
		config.set_value(SETTINGS_SECTION, key, data[key])

	config.save(SAVE_PATH)
	print("SaveManager: настройки сохранены")


func load_settings() -> Dictionary:
	var config = ConfigFile.new()
	var defaults := get_default_settings()

	if config.load(SAVE_PATH) != OK:
		return defaults

	for key in defaults.keys():
		defaults[key] = config.get_value(SETTINGS_SECTION, key, defaults[key])

	return defaults
#endregion
