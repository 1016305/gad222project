extends Interactable

@export_file var unique_message: String
var content

var is_read: bool = false

var mat1 = preload("res://materials/interactable_test_material.tres")
var mat2 = preload("res://materials/interactable_test_material_done.tres")

@export var trigger_next_zone: bool = false
var signal_sent: bool = false
signal iterate_progression_counter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_from_file()

func load_from_file():
	var file = FileAccess.open(unique_message, FileAccess.READ)
	content = file.get_as_text()

func change_color():
	get_meshinstance3d_child().set_surface_override_material(0, mat2)
	
func get_meshinstance3d_child(): #grabs the mesh instacne 3d child to change the material
	for child in get_children():
		if child is MeshInstance3D:
			return child

func iterate_prog_counter():
	if trigger_next_zone && !signal_sent:
		signal_sent = true
		emit_signal("iterate_progression_counter")
