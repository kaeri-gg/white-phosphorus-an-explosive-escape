class_name Utils
extends Node

const _OVERLAY_NAME := "ScreenTransitionOverlay"

func timeout(delay: float) -> void:
	var timer := get_tree().create_timer(delay)
	await timer.timeout

func fade_in(node: Node, duration: float = 0.4) -> void:
	var tween: Tween = create_tween()
	node.modulate.a = 0.0
	node.visible = true
	tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)
	await timeout(duration)

func fade_out(node: Node, duration: float = 0.4) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	await timeout(duration)
	node.visible = false

func slide_in(node: Sprite2D, to: float, duration: float = 0.4) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(node, "position:x", to, duration)
	await timeout(duration)

func fade_to_color(_parent: Node, color: Color, duration: float = 1.0) -> void:
	var canvas_layer := _ensure_overlay(color)
	var fade_rect: ColorRect = canvas_layer.get_child(0)
	fade_rect.color = color
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration).set_ease(Tween.EASE_IN)
	await tween.finished

func fade_to_black(parent: Node, duration: float = 1.0) -> void:
	await fade_to_color(parent, Color.BLACK, duration)

func fade_to_white(parent: Node, duration: float = 1.0) -> void:
	await fade_to_color(parent, Color.WHITE, duration)

func fade_from_overlay(duration: float = 0.6) -> void:
	var canvas_layer := _find_overlay()
	if canvas_layer == null:
		return
	var fade_rect: ColorRect = canvas_layer.get_child(0)
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration).set_ease(Tween.EASE_OUT)
	await tween.finished
	if is_instance_valid(canvas_layer):
		canvas_layer.queue_free()

func _ensure_overlay(color: Color) -> CanvasLayer:
	var existing := _find_overlay()
	if existing:
		return existing

	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = _OVERLAY_NAME
	canvas_layer.layer = 1000

	var fade_rect := ColorRect.new()
	fade_rect.color = color
	fade_rect.modulate.a = 0.0
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_rect)

	get_tree().root.add_child(canvas_layer)
	return canvas_layer

func _find_overlay() -> CanvasLayer:
	return get_tree().root.get_node_or_null(_OVERLAY_NAME) as CanvasLayer
