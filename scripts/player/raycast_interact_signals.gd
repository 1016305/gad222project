extends RayCast3D

@onready var raycast: RayCast3D = $"."
@onready var prompt: Label = $"../../../UI_Crosshair/Prompt"

var content
signal on_interact_interactable(content)

func _process(delta: float) -> void:
	if raycast.is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			prompt.text = collider.prompt_message
			if Input.is_action_just_pressed("interact"):
				content = collider.content
				emit_signal("on_interact_interactable",content) #signal is sent to the player's message panel
				if collider.trigger_next_zone:
					pass #add behaviour for triggering next zone here
	else:
		prompt.text = ""

#get what the raycast is looking at. see if it inherits from interactable.
