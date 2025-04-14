extends Area3D

@onready var door_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	get_node("AnimationPlayer").play("door_open")
	door_sound.pitch_scale = randf_range(0.9, 1.1)
	door_sound.play()
func _on_body_exited(body: Node3D) -> void:
	get_node("AnimationPlayer").play("door_close")
	door_sound.pitch_scale = randf_range(0.9, 1.1)
	door_sound.play()
