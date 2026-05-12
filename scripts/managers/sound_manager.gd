class_name SoundManager
extends Node

var _players: Dictionary[String, AudioStreamPlayer] = {}

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			_players[String(child.name)] = child as AudioStreamPlayer

func play(by_name: String, from: float = 0) -> void:
	var sound: AudioStreamPlayer = _players.get(by_name)
	if sound == null:
		push_warning("SoundManager: sound '%s' not found." % by_name)
		return
	sound.play(from)

func stop(by_name: String) -> void:
	var sound: AudioStreamPlayer = _players.get(by_name)
	if sound == null:
		push_warning("SoundManager: sound '%s' not found." % by_name)
		return
	sound.stop()
