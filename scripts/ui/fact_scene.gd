class_name FactScene
extends Node

const LEVEL_01 = preload("uid://ckj7fgxtg1c")

@onready var proceed_button: ActionButton = $MarginContainer/ProceedButton

func _ready() -> void:
	sound_manager.play("EnterGame")
	proceed_button.pressed.connect(start_game)

func start_game() -> void:
	sound_manager.play("EnterGame")
	get_tree().change_scene_to_packed(LEVEL_01)
