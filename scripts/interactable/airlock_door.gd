extends Area3D

var door_is_open = false
var sound_played = false
@onready var big_door_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	open_door()

func open_door():
	if door_is_open == false:
		get_node("AnimationPlayer").play("big_door_open")
		door_is_open = true
		big_door_sound.play()
		
func open_door_distant():
	if door_is_open == false:
		get_node("AnimationPlayer").play("big_door_open")
		door_is_open = true
