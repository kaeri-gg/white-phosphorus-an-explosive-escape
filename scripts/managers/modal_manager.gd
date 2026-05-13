class_name ModalManager
extends Control

const GAME_MENU = preload("uid://4ht2ox1qqc7q")

@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

@onready var settings_panel: PanelContainer = %Settings
@onready var about_panel: PanelContainer = %AboutTheGame
@onready var tutorial_panel: PanelContainer = %Tutorial
@onready var tutorial_slider: TutorialSlider = %TutorialContainer

@onready var close_button: CloseButton = %CloseButton
@onready var return_to_home_link: LinkButton = %ReturnToHomeLink

var modal_views: Dictionary[String, Control] = {}

func _ready() -> void:
	modal_views = {
		"settings": settings_panel,
		"about-the-game": about_panel,
		"tutorial": tutorial_panel,
	}
	hide()

	close_button.pressed.connect(close_modal)
	return_to_home_link.pressed.connect(return_to_home)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		sound_manager.play("Click")
		close_modal()
		get_viewport().set_input_as_handled()

func is_open() -> bool:
	return visible

func open_modal(view_name: String) -> void:
	for view in modal_views.values():
		if view:
			view.hide()

	var target_view: Control = modal_views.get(view_name)
	if not target_view:
		push_warning("Modal view '%s' was not found." % view_name)
		return

	target_view.show()
	self.show()

func show_settings() -> void:
	open_modal("settings")

func show_about_us() -> void:
	open_modal("about-the-game")

func show_tutorial() -> void:
	tutorial_slider.reset()
	open_modal("tutorial")

func close_modal() -> void:
	self.hide()

func return_to_home() -> void:
	close_modal()
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_packed(GAME_MENU)
