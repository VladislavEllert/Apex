extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет был ли собран сундук, и не дает собрать его еще раз
	var coords: Array = GameManager.local_save["level"]["chests_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.animation = "open"
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала открывает сундук, записывает инофрмацию в сейв
	if flag == false:
		Events.OPEN_THE_CHEST.emit($AnimatedSprite2D)
		SFXManager.play_sfx(SFXManager.DOOR, -10)
		GameManager.local_save["player"]["score"] = GameManager.local_save["player"]["score"] + 500
		GameManager.local_save["level"]["chests_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		})
		flag = true
	#endregion
