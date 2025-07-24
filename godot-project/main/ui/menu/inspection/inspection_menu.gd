class_name InspectionMenu extends Menu

var show_advanced_info: bool = false

func _ready() -> void:
	super._ready()
	%AdvancedButton.pressed.connect(_on_advanced_pressed)

func _on_advanced_pressed() -> void:
	show_advanced_info = not show_advanced_info
	handle_advanced_info()

func initialize_information(recording: Recording) -> void:
	%Render.texture = recording.render
	%DateLabel.text = "%s/%s/%s" % [recording.time.year, recording.time.month, recording.time.day]
	%ScoreLabel.text = "Score: " + str(int(10 * recording.health_score))
	%PulseScoresLabel.text = "Pulse Scores: " + str(recording.pulse_scores)
	
	show_advanced_info = false
	handle_advanced_info()

func handle_advanced_info() -> void:
	%PulseScoresLabel.visible = show_advanced_info
	%AdvancedButton.text = "Hide Advanced Info" if show_advanced_info else "Show Advanced Info"
	
