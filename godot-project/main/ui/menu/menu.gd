class_name Menu extends Container
## Base class for all menus.

@export var close_button: Button

signal entered
signal exited

func _ready() -> void:
	if is_instance_valid(close_button):
		close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed() -> void:
	exit()

func enter() -> void:
	entered.emit()

func exit() -> void:
	exited.emit()
