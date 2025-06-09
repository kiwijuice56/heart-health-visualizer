class_name InputBlocker extends ColorRect
## Sits on top of the screen to block any tap input when enabled.

func block() -> void:
	visible = true

func unblock() -> void:
	visible = false
