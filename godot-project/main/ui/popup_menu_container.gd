class_name PopupMenuContainer extends Control

@export var transition_time: float = 0.2

var menu: Menu 
var tween: Tween

func _ready() -> void:
	menu = get_child(0)
	assert(menu is Menu)
	
	menu.entered.connect(enter)
	menu.exited.connect(exit)
	
	exit()
	
	visible = true

func enter() -> void:
	Ref.input_blocker.block()
	
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:x", 0, transition_time)
	
	await tween.finished
	
	Ref.input_blocker.unblock()

func exit() -> void:
	Ref.input_blocker.block()
	
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:x", get_viewport_rect().size.x, transition_time)
	
	await tween.finished
	
	Ref.input_blocker.unblock()
