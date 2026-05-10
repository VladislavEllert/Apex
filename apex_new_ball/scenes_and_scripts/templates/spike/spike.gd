extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play()
 
func _on_body_entered(_body: Node2D) -> void:
	SFXManager.play_sfx(SFXManager.DAMAGE, SFXManager.DAMAGE_VOLUME)
	GameManager.local_save["player"]["lives"] -= 1
	SaveManager.save(GameManager.local_save)
	Events.GAME_ON_LOSE.emit()
	GameManager.live += 1
	if GameManager.local_save["player"]["lives"] < 0:
		print("проиграл")
