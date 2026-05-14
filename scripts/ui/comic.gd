class_name Comic
extends TextureRect

enum TransitionType { FADE_IN, FADE_IN_UP, FADE_IN_DOWN, FADE_IN_LEFT, FADE_IN_RIGHT }

@export var sequence: int = 0
@export var duration: float = 0.0
@export var fade_in_duration: float = 0.5
@export var transition: TransitionType = TransitionType.FADE_IN

func fade_in() -> void:
	if visible:
		return
	modulate.a = 0.0
	visible = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)

	var viewport_size := get_viewport_rect().size
	var target_pos := position

	match transition:
		TransitionType.FADE_IN_LEFT:
			position.x -= viewport_size.x
			tween.tween_property(self, "position", target_pos, fade_in_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		TransitionType.FADE_IN_RIGHT:
			position.x += viewport_size.x
			tween.tween_property(self, "position", target_pos, fade_in_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		TransitionType.FADE_IN_UP:
			position.y -= viewport_size.y
			tween.tween_property(self, "position", target_pos, fade_in_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		TransitionType.FADE_IN_DOWN:
			position.y += viewport_size.y
			tween.tween_property(self, "position", target_pos, fade_in_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
