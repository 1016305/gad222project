extends Node

@onready var spot_light_3d: SpotLight3D = $"."
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

@onready var player_sounds: AudioStreamPlayer3D = $"../../../player_sounds"
const LIGHT_SWITCH_81967 = preload("res://assets/sounds/light-switch-81967.mp3")

var FLASHLIGHT_ON: bool = false

func _physics_process(delta: float) -> void:
	toggle_flashlight()
	
func toggle_flashlight():
	if Input.is_action_just_pressed("toggle_flashlight"):
		if FLASHLIGHT_ON:
			FLASHLIGHT_ON = false
		elif !FLASHLIGHT_ON:
			FLASHLIGHT_ON = true
		player_sounds.stream = LIGHT_SWITCH_81967
		player_sounds.play(0.0)
	
	if FLASHLIGHT_ON:
		spot_light_3d.light_energy = 10
		omni_light_3d.light_energy = 0.02
	elif !FLASHLIGHT_ON:
		spot_light_3d.light_energy = 0
		omni_light_3d.light_energy = 0
