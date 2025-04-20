extends Control

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var timer: Timer = $Timer

const WORLD = preload("res://scenes/main_menu.tscn")

var fade_speed = 5
var start_fade = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_fade:
		color_rect_2.color = lerp(color_rect_2.color, Color(0,0,0,0),fade_speed * delta)



func _on_timer_timeout() -> void:
	start_fade = true


func _on_button_pressed() -> void:
	get_tree().quit()
