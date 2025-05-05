class_name ScreenManager extends VBoxContainer

@export var tab_titles: Array[String] = ["Recording", "History", "Settings"]
@export var tab_colors: Array[Color]
@export var focus_color: Color
@export var unfocus_color: Color
@export var tabs: Array[Container]
@export var tab_buttons: Array[BaseButton]
@export var tab_id: int = 0

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
	
	for i in len(tabs):
		tabs[i].visible = tab_id == i
		tab_buttons[i].get_parent().modulate = focus_color if tabs[i].visible else unfocus_color
