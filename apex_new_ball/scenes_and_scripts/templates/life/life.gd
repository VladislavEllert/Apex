extends Area2D

var flag = false

func _ready() -> void:
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.has_method("play"):
		sprite.play()
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	#region При запуске уровня проверяет была ли собрана жизнь, и не дает собрать ее еще раз
	var coords: Array = GameManager.local_save["level"].get("lives_collected_coordinates_level", [])
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			queue_free()
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	# Проверяем, что предмет еще не собран
	if flag == false:
		var current_lives = GameManager.local_save["player"]["lives"]
		var max_lives = GameManager.local_save["player"].get("max_lives", 5)
		
		# Если жизней меньше максимума, лечим
		if current_lives < max_lives:
			# Воспроизводим звук (пока используем звук монетки как плейсхолдер)
			SFXManager.play_sfx(SFXManager.COIN, SFXManager.COIN_VOLUME)
			
			# Добавляем жизнь
			GameManager.local_save["player"]["lives"] += 1
			
			# Записываем информацию в сейв (координаты сбора)
			if GameManager.local_save["level"].has("lives_collected_coordinates_level"):
				GameManager.local_save["level"]["lives_collected_coordinates_level"].append({
					"x": position.x,
					"y": position.y
				})
			
			# Эмитим сигнал с передачей спрайта для скрытия
			var sprite = get_node_or_null("AnimatedSprite2D")
			if not sprite:
				sprite = get_node_or_null("Sprite2D")
			Events.HEALING.emit(sprite)
			
			flag = true
			queue_free() # Удаляем объект со сцены, чтобы он 100% исчез
