extends Panel
@onready var message_panel: Panel = $"."
@onready var message_text: RichTextLabel = $"Message Text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact_raycast_on_interact_interactable(content) -> void:
	message_text.text = content
	message_panel.visible = !message_panel.visible
