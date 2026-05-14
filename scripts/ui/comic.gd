class_name Comic
extends TextureRect

@export var sequence: int = 0
@export var duration: float = 0.0
@export var fade_in_duration: float = 0.5

func fade_in() -> void:
	if visible:
		return
	modulate.a = 0.0
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
