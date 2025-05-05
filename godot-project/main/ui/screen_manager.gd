class_name ScreenManager extends VBoxContainer

@export var tab_titles: Array[String] = ["Recording", "History", "Settings"]
@export var gradient: Gradient

@export var tab_colors_1: Array[Color]
@export var tab_colors_2: Array[Color]

@export var focus_color: Color
@export var unfocus_color: Color

@export var tabs: Array[Container]
@export var tab_buttons: Array[BaseButton]

var tab_id: int = 0

var tab_color_1: Color:
	set(val):
		tab_color_1 = val
		gradient.colors[1] = tab_color_1
var tab_color_2: Color:
	set(val):
		tab_color_2 = val
		gradient.colors[0] = tab_color_2

func _ready() -> void:
	assert(len(tabs) == len(tab_buttons))
	assert(len(tabs) == len(tab_titles))
	
	for i in len(tab_buttons):
		tab_buttons[i].pressed.connect(_on_tab_button_pressed.bind(i))
	
	update_screen(0)

func _on_tab_button_pressed(new_tab_id: int) -> void:
	update_screen(new_tab_id)

func update_screen(new_tab_id: int) -> void:
	tab_id = new_tab_id
	
	%Title.text = tab_titles[tab_id]
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "tab_color_1", tab_colors_1[tab_id], 0.2)
	tween.tween_property(self, "tab_color_2", tab_colors_2[tab_id], 0.2)
	
	for i in len(tabs):
		tabs[i].visible = tab_id == i
		tab_buttons[i].modulate = focus_color if tabs[i].visible else unfocus_color
