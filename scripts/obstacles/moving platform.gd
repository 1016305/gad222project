extends CSGBox3D

@onready var pos_1: Node3D = $"../Pos1"
@onready var pos_2: Node3D = $"../Pos2"

var is_at_1: bool = false
var is_at_2: bool = false
const PLATFORM_SPEED = 2.4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_platform(delta)
	
func move_platform(delta):
	position = pos_1.position - position * (PLATFORM_SPEED * delta)
	if position == pos_1.position:
		is_at_1 = true
	print(is_at_1)
