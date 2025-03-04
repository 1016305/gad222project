extends RayCast3D

@onready var interact_raycast: RayCast3D = $"."
@onready var prompt: Label = $"../../../UI_Crosshair/Prompt"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interact_raycast.is_colliding():
		var collider = get_collider()
		
		if collider is Interactable:
			prompt.text = collider.prompt_message
		
			if Input.is_action_just_pressed("interact"):
				collider.interact(owner)
	else:
		prompt.text = ""
