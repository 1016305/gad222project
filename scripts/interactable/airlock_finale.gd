extends Area3D

var can_do_ending = false
var has_started_ending = false

@onready var doors_close: Timer = $DoorsClose
@onready var silence: Timer = $Silence
@onready var friends: Timer = $friends
@onready var finale: Timer = $finale

@onready var airlock_door: Area3D = $"../../doors/Airlock_Door"
@export var lights1: Array[SpotLight3D]
@export var lights2: Array[OmniLight3D]
@onready var big_thud: AudioStreamPlayer3D = $big_thud
@export var words: AudioStreamMP3
@export var lightsnoise: AudioStreamMP3
@onready var block_the_door: CSGBox3D = $"block the door"
var block_pos = Vector3(-0.291, -0.198, -3.063)
const CREDITS = preload("res://scenes/credits.tscn")

func can_do_ending_toggle():
	can_do_ending = true

func ending_sequence():
	if can_do_ending && !has_started_ending:
		has_started_ending = true
		doors_close.start()
		block_the_door.position = block_pos

func _on_doors_close_timeout() -> void:
	doors_close.stop()
	airlock_door.get_node("AnimationPlayer").play("big_door_close")
	airlock_door.big_door_sound.play()
	silence.start()

func _on_silence_timeout() -> void:
	silence.stop()
	big_thud.stream = lightsnoise
	big_thud.play()
	for light in lights1:
		light.visible = true
	for light in lights2:
		light.visible = true
	friends.start()

func _on_friends_timeout() -> void:
	friends.stop()
	big_thud.stream = words
	big_thud.play()
	finale.start()

func _on_body_entered(body: Node3D) -> void:
	ending_sequence()


func _on_finale_timeout() -> void:
	finale.stop()
	get_tree().change_scene_to_packed(CREDITS)
