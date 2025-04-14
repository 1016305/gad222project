extends Area3D

var door_is_open = false
@onready var big_door_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	if door_is_open == false:
		get_node("AnimationPlayer").play("big_door_open")
		big_door_sound.play()
		door_is_open = true
