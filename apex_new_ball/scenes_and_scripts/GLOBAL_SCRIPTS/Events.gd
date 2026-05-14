extends Node

@warning_ignore("unused_signal")
signal SHOW_PAUSE_MODAL

@warning_ignore("unused_signal")
signal HIDE_PAUSE_MODAL

@warning_ignore("unused_signal")
signal GAME_ON_LOSE

@warning_ignore("unused_signal")
signal TOUCHING_THE_FLAG(sprite)

@warning_ignore("unused_signal")
signal PRINT_FLAGS

@warning_ignore("unused_signal")
signal COLLECTING_COINS(sprite)

@warning_ignore("unused_signal")
signal OPEN_THE_CHEST(sprite)

@warning_ignore("unused_signal")
signal HEALING(sprite)

@warning_ignore("unused_signal")
signal OPEN_THE_DOOR(sprite)

@warning_ignore("unused_signal")
signal PLAYER_RESPAWN

@warning_ignore("unused_signal")
signal CONTROL_SENSITIVITY_CHANGED(value)

@warning_ignore("unused_signal")
signal SHOW_LEADERBOARD_SUBMIT(score)

# Сигналы для обновления UI (вместо polling в _process)
@warning_ignore("unused_signal")
signal UI_SCORE_UPDATED

@warning_ignore("unused_signal")
signal UI_FLAGS_UPDATED

@warning_ignore("unused_signal")
signal UI_LIVES_UPDATED
