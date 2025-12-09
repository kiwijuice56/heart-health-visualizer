class_name RecordingMenu extends Menu

@onready var record_button: Button = %RecordButton
@onready var user_id: LineEdit = %UserIDLineEdit

signal recording_requested

func _ready() -> void:
	super._ready()
	record_button.pressed.connect(_on_recording_pressed)

func _on_recording_pressed() -> void:
	recording_requested.emit()
