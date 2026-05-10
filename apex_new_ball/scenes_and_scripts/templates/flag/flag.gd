extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет был ли активирован флаг, и не дает сделать это ее еще раз
	var coords: Array = GameManager.local_save["level"]["flags_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.animation = "flag"
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала активирует флаг, записывает инофрмацию в сейв и ставит чекпоинт на последнем собранном флаге
	if  flag == false:
		Events.TOUCHING_THE_FLAG.emit($AnimatedSprite2D)
		GameManager.local_save["level"]["flags_collected"] = GameManager.local_save["level"]["flags_collected"] + 1
		GameManager.local_save["level"]["flags_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		}) 
		GameManager.local_save["level"]["checkpoint_position"] = {
			"x": position.x,
			"y": position.y
		}
		flag = true
	#endregion
