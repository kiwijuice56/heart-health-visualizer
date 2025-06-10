extends Node
## Holds references to important nodes for easy access.

@onready var input_blocker: InputBlocker = get_tree().get_root().get_node("Main/%InputBlocker")
@onready var recorder: Recorder = get_tree().get_root().get_node("Main/%Recorder")
@onready var saver: Saver = get_tree().get_root().get_node("Main/%Saver")
@onready var renderer: Renderer = get_tree().get_root().get_node("Main/%Renderer")
