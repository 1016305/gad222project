extends Control

@onready var instructions_a: RichTextLabel = $"instructions A"
@onready var instructions_b: RichTextLabel = $"instructions B"
const WORLD = preload("res://scenes/world.tscn")

func _on_NEXT_press():
	instructions_a.hide()
	instructions_b.show()

func _on_START_press():
	get_tree().change_scene_to_packed(WORLD)
