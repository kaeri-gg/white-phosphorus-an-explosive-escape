extends CanvasLayer

@onready var _jump: TouchScreenButton = $GridContainer/VBoxContainer/JumpContainer/Jump
@onready var _interact: TouchScreenButton = $GridContainer/VBoxContainer/InteractContainer/Interact


func _ready() -> void:
	if not _is_touch_device():
		queue_free()
		return

	_jump.pressed.connect(_on_button_pressed)
	_interact.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	sound_manager.play("Click")


static func _is_touch_device() -> bool:
	return OS.has_feature("mobile") \
		or OS.has_feature("web_android") \
		or OS.has_feature("web_ios")
