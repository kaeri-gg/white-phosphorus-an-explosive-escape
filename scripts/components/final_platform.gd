class_name FinalPlatform
extends StaticBody2D

## Seconds the player stays on the platform in EVOLVED form before the
## child PortalArea is triggered to advance to the next scene.
@export var hold_duration: float = 2.0

@onready var detection_area: Area2D = %DetectionArea
@onready var hold_timer: Timer = %StableTimer

var current_player: Player
var has_triggered: bool = false

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	hold_timer.wait_time = hold_duration
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_on_hold_timeout)

func _on_body_entered(body: Node) -> void:
	if has_triggered or body is not Player:
		return
	has_triggered = true
	current_player = body
	current_player.transform_to_final_form()
	hold_timer.start()

func _on_hold_timeout() -> void:
	if not is_instance_valid(current_player):
		return
	var portal := _find_portal_area()
	if portal == null:
		push_warning("FinalPlatform has no PortalArea child to trigger.")
		return
	portal.advance()

func _find_portal_area() -> Area2D:
	for child in get_children():
		if child is Area2D and child.has_method("advance"):
			return child
	return null
