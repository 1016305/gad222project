extends Area3D

var final_message_read: bool = false
var big_text_shown: bool = false
@onready var player: CharacterBody3D = $"../../../../player"
@onready var timer: Timer = $Timer
@onready var airlock_area: Area3D = $"../airlock area"

func _set_final_message_read():
	final_message_read = true

func _on_body_entered(body: Node3D) -> void:
	if final_message_read && !big_text_shown:
		player.toggle_final_message()
		timer.start()
		big_text_shown = true
func _on_timer_timeout() -> void:
	timer.stop()
	player.toggle_final_message()
	airlock_area.can_do_ending_toggle()
