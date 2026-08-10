extends CanvasLayer

@onready var _jump: TouchScreenButton = $GridContainer/VBoxContainer/JumpContainer/Jump
@onready var _interact: TouchScreenButton = $GridContainer/VBoxContainer/InteractContainer/Interact


func _ready() -> void:
	_jump.pressed.connect(_on_button_pressed)
	_interact.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	sound_manager.play("Click")
