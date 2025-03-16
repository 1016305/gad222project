extends Interactable

@export_file var unique_message: String
var content
var trigger_next_zone: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_from_file()

func load_from_file():
	print(unique_message)
	var file = FileAccess.open(unique_message, FileAccess.READ)
	content = file.get_as_text()
