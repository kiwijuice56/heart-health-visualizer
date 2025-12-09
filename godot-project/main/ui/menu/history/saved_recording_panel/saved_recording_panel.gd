class_name SavedRecordingPanel extends PanelContainer

var recording: Recording

signal tapped

func _ready() -> void:
	%TapButton.pressed.connect(_on_tap_pressed)

func _on_tap_pressed() -> void:
	tapped.emit()

func initialize(new_recording: Recording) -> void:
	recording = new_recording
	%NameLabel.text = recording.user_id
	%NameLabel.visible = recording.user_id.length() > 0
	%DateLabel.text = "%s/%s/%s" % [recording.time.year, recording.time.month, recording.time.day]
	%ScoreLabel.text = str(int(100 * recording.health_score))
	%Render.texture = recording.render
