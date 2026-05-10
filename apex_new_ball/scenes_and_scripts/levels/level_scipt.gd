extends Node2D

func _ready() -> void:
	MusicManager.play_track("res://assets/sound/old_tricks_loop.ogg")
	_spawn_flags()

func _spawn_flags():
	#region получаем JSON файл c разметкой уровня
	var file = FileAccess.open("res://scenes_and_scripts/levelsJSON/level1.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	#endregion
	
	#region Добаввляем в сейв информацию о флагах
	var scene_num = GameManager.local_save["level"]["scene_number"]
	var json_key = str(scene_num)
	GameManager.local_save["level"]["flags_total"] = int(data[json_key]["flags"])
	#endregion
