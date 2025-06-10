class_name SavedRecordingPanel extends PanelContainer

var recording: Recording

func initialize(new_recording: Recording) -> void:
	recording = new_recording
	%DateLabel.text = "%s/%s/%s" % [recording.time.year, recording.time.month, recording.time.day]
	%ScoreLabel.text = str(int(100 * recording.health_score))
	%Render.texture = recording.render
