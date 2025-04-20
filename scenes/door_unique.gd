extends Area3D

@onready var door_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
var mat1 = preload("res://assets/models/props/doors/DoorOpen.tres")
var is_locked: bool = true

func _on_body_entered(body: Node3D) -> void:
	if !is_locked:
		get_node("AnimationPlayer").play("door_open")
		door_sound.pitch_scale = randf_range(0.9, 1.1)
		door_sound.play()
func _on_body_exited(body: Node3D) -> void:
	if !is_locked:
		get_node("AnimationPlayer").play("door_close")
		door_sound.pitch_scale = randf_range(0.9, 1.1)
		door_sound.play()


func unlock():
	is_locked = false
	change_color()
func change_color():
		get_meshinstance3d_child().set_surface_override_material(0, mat1)	
func get_meshinstance3d_child(): #grabs the mesh instacne 3d child to change the material
	for child in get_children():
		if child is MeshInstance3D:
			return child
