extends Node

# Универсальная функция для проигрывания звуковых эффектов.
# Вызывается вручную: SFXManager.play_sfx(SFXManager.JUMP, SFXManager.JUMP_VOLUME)
# path: константа пути к аудиофайлу
# volume: громкость в децибелах (0.0 - норма)

# Каталог звуков
const CLICK = "res://assets/sound/click.wav"
const COIN = "res://assets/sound/coin.wav"
const BOUNCE = "res://assets/sound/bounce.wav"
const DAMAGE = "res://assets/sound/damage.wav"
const JUMP = "res://assets/sound/jump.wav"
const DOOR = "res://assets/sound/door.ogg"

const CLICK_VOLUME = 5.0
const JUMP_VOLUME = -20.0
const JUPM_VOLUME = -20.0  # устаревший алиас, оставлен для обратной совместимости
const COIN_VOLUME = -10.0
const DAMAGE_VOLUME = 2.0
const DOOR_VOLUME = 0.0

const MIN_VOLUME_DB := -40.0
const MUTED_VOLUME_DB := -80.0

var sfx_volume_db: float = 0.0

# Кэш: загружаем все звуки один раз при старте, чтобы не читать диск во время игры
var _cache: Dictionary = {}

# Пул звуков: заранее созданные узлы
const POOL_SIZE = 8
var _pool: Array[AudioStreamPlayer] = []
var _pool_index: int = 0

func _ready() -> void:
	_preload_all()
	
	# Создаем пул плееров один раз
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_pool.append(p)

func _preload_all() -> void:
	for path in [CLICK, COIN, BOUNCE, DAMAGE, JUMP, DOOR]:
		if ResourceLoader.exists(path):
			_cache[path] = load(path)
		else:
			push_warning("SFXManager: файл не найден при предзагрузке -> " + path)

func set_volume_percent(percent: float) -> void:
	sfx_volume_db = _percent_to_db(percent)

func get_volume_percent() -> float:
	return _db_to_percent(sfx_volume_db)

func play_sfx(path: String, volume: float = 0.0) -> void:
	# Берём поток из кэша
	var stream = _cache.get(path)
	if not stream:
		push_warning("SFXManager: звук не в кэше -> " + path)
		return

	# Берем плеер из пула по кругу
	var player = _pool[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE

	player.stream = stream
	player.volume_db = volume + sfx_volume_db
	player.play()

func _percent_to_db(percent: float) -> float:
	var clamped_percent := clampf(percent, 0.0, 100.0)
	if clamped_percent <= 0.0:
		return MUTED_VOLUME_DB
	return lerpf(MIN_VOLUME_DB, 0.0, clamped_percent / 100.0)

func _db_to_percent(db: float) -> float:
	if db <= MUTED_VOLUME_DB:
		return 0.0
	return clampf(inverse_lerp(MIN_VOLUME_DB, 0.0, db) * 100.0, 0.0, 100.0)
