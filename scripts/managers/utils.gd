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
