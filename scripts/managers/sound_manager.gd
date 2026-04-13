class_name SoundManager
extends Node

func play(by_name: String, from: float = 0) -> void:
	var sound: AudioStreamPlayer = get_node(by_name)
	if not sound:
		push_warning("SoundManager: sound '%s' not found." % by_name)
		return
	sound.play(from)

func stop(by_name: String) -> void:
	var sound: AudioStreamPlayer = get_node(by_name)
	if not sound:
		push_warning("SoundManager: sound '%s' not found." % by_name)
		return
	sound.stop()
