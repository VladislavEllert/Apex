extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет была ли собрана монетка, и не дает собрать ее еще раз
	var coords: Array = GameManager.local_save["level"]["coins_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.modulate.a = 0
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала собирает монету, записывает инофрмацию в сейв
	if flag == false:
		SFXManager.play_sfx(SFXManager.COIN, SFXManager.COIN_VOLUME)
		Events.COLLECTING_COINS.emit($AnimatedSprite2D)
		GameManager.local_save["player"]["score"] = GameManager.local_save["player"]["score"] + 100
		GameManager.local_save["level"]["coins_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		})
		flag = true
	#endregion
