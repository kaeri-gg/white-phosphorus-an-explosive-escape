class_name SplashScreen
extends Control

const GAME_MENU = preload("uid://4ht2ox1qqc7q")

@onready var godot_teeth: TextureRect = %GodotTeeth
@onready var logo : TextureRect = %GodotLogo

func _ready() -> void:
	utils.fade(logo, GAME_MENU)
	utils.fade(godot_teeth, GAME_MENU)
	yoyo()

func yoyo() -> void:
	var speed = 0.1;
	var wide = 10.0
	var tween = create_tween().set_loops()
	tween.tween_property(godot_teeth, "position:y", wide, speed).as_relative()
	tween.tween_property(godot_teeth, "position:y", -wide, speed).as_relative()
