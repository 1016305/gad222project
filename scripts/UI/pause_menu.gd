extends Control

var pause: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"VBoxContainer/Resume Button".pressed.connect(_on_resume_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_pause_menu"):
		toggle_pause()
	
func toggle_pause():
	if !pause:
		pause = true
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif pause:
		_on_resume_pressed()

func _on_resume_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	pause = false

func _on_resume_button_pressed() -> void:
	_on_resume_pressed()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
