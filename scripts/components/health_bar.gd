extends Control

@export var player: Player 
@onready var health_label: Label = %HealthLabel
@onready var damage_flash: ColorRect = %DamageFlash

var previous_health: int = -1

func _ready() -> void:
	if player != null:
		previous_health = player.PLAYER_HEALTH
		player.health_changed.connect(update_health_display)

func update_health_display(current: int, _max_hp: int) -> void:
	health_label.text = str(current)
	
	if previous_health != -1 and current < previous_health:
		trigger_negative_feedback()
		
	previous_health = current

func trigger_negative_feedback() -> void:
	flash_screen()
	shake_camera()

func flash_screen() -> void:
	var tween = get_tree().create_tween()
	
	damage_flash.modulate.a = 0.7 
	
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.4)

func shake_camera() -> void:
	var cam = get_viewport().get_camera_2d()
	
	if cam != null:
		var tween = get_tree().create_tween()
		
		tween.tween_property(cam, "offset", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.03)
		tween.tween_property(cam, "offset", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.03)
		tween.tween_property(cam, "offset", Vector2.ZERO, 0.05)
