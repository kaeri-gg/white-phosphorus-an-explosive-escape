class_name Utils
extends Node

@export var load_scene : PackedScene
@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 0.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5 

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

func fade(target : Object, scene : PackedScene) -> void:

	target.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(target, "modulate:a", 1, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(target, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished

	get_tree().change_scene_to_packed(scene)

## Fades the screen to black over `duration` seconds by spawning a
## full-screen ColorRect overlay inside a high-layer CanvasLayer parented
## to `parent`. Awaitable — resolves once the fade is complete.
##
## The overlay node is left in place so the screen stays black until the
## caller swaps scenes. When the parent scene is freed (e.g. via
## `reload_current_scene`), the overlay is freed with it.
func fade_to_black(parent: Node, duration: float = 1.0) -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 1000
	parent.add_child(canvas_layer)

	var fade_rect := ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0.0
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_rect)

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration).set_ease(Tween.EASE_IN)
	await tween.finished
