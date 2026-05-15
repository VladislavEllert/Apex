extends Parallax2D

@export var autoscroll_surfaces: bool = false:
	set(v):
		autoscroll_surfaces = v
		if is_node_ready(): _update_autoscroll()

@export var extra_repeat_tiles: int = 2
@export var anchor_bottom_extent: float = 648.0

func get_anchor_bottom_extent() -> float:
	return anchor_bottom_extent

func _ready() -> void:
	_update_autoscroll()
	_update_dynamic_repeat()
	get_tree().root.size_changed.connect(_update_dynamic_repeat)

func _update_autoscroll() -> void:
	var s = 1.0 if autoscroll_surfaces else 0.0

	if has_node("Cloud1"): $Cloud1.autoscroll = Vector2(-20, 0) * s
	if has_node("Cloud2"): $Cloud2.autoscroll = Vector2(-30, 0) * s
	if has_node("Cloud3"): $Cloud3.autoscroll = Vector2(-40, 0) * s
	if has_node("Cloud4"): $Cloud4.autoscroll = Vector2(-50, 0) * s

	if has_node("Surface1"): $Surface1.autoscroll = Vector2(-10, 0) * s
	if has_node("Surface2"): $Surface2.autoscroll = Vector2(-20, 0) * s
	if has_node("Surface3"): $Surface3.autoscroll = Vector2(-30, 0) * s
	if has_node("Surface4"): $Surface4.autoscroll = Vector2(-40, 0) * s
	if has_node("Surface5"): $Surface5.autoscroll = Vector2(-50, 0) * s

func _update_dynamic_repeat() -> void:
	var viewport_width = get_viewport().get_visible_rect().size.x
	
	for layer in get_children():
		if not layer is Parallax2D: continue
		
		var rs = layer.repeat_size
		if rs.x <= 0: continue
		
		# Высчитываем сколько раз нужно повторить текстуру, чтобы закрыть весь экран
		# Плюс 2 для запаса при прокрутке
		var needed_repeats = int(ceil(viewport_width / rs.x)) + 2
		layer.repeat_times = max(1, needed_repeats)
