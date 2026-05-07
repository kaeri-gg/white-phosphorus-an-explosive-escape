class_name ModalManager
extends Control

const GAME_MENU = preload("uid://4ht2ox1qqc7q")

@export var fade_duration: float = 0.6

@onready var settings: Control = %SettingsControl
@onready var about_the_game: Control = %AboutTheGameControl

@onready var close_button: CloseButton = %CloseButton
@onready var return_to_home_link: LinkButton = %ReturnToHomeLink

var modal_views: Dictionary[String, Control] = {}

func _ready() -> void:
	modal_views = {
		"settings": settings,
		"about-the-game": about_the_game,
	}
	hide()

	close_button.clicked.connect(close_modal)
	return_to_home_link.pressed.connect(return_to_home)

func is_open() -> bool:
	return visible
	
func open_modal(view_name: String) -> void:
	for view in modal_views.values():
		if view:
			view.hide()
	
	var target_view : Control = modal_views.get(view_name)
	if not target_view:
		push_warning("Modal view '%s' was not found." % view_name)
		return
	
	target_view.show()
	self.show()

func show_settings() -> void:
	open_modal("settings")
	
func show_about_us() -> void:
	open_modal("about-the-game")

func close_modal() -> void:
	self.hide()
	
func return_to_home() -> void:
	close_modal()
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_packed(GAME_MENU)
