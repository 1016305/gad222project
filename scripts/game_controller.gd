extends Node3D

#this script controls progression in the game. when a particular log is picked up, it sends a
#signal to this node, which iterates the level counter by one, each time opening a successive door, deeper into the ship.

var progression_counter = 0
var default_string = "open_door_"
var iterate_string
@onready var door1: CSGBox3D = $"../doors/CSGBox3D12"
@onready var distant_door_open: AudioStreamPlayer3D = $DistantDoorOpen
@onready var timer: Timer = $Timer

#ignore this. all dork ass code bc i was experimenting with calling methods from strings. literally the worst way to handle this. please.
func _iterate_progression_counter() -> void:
	progression_counter += 1
	var i = str(progression_counter)
	iterate_string = default_string + i
	print(iterate_string)
	subfunction()

func subfunction():
	print("subfunction")
	var callable = Callable(self, iterate_string)
	callable.call()

func open_door_1():
	door1.visible = false
	door1.use_collision = false
	timer.start()
	
func open_door_2():
	pass

func open_door_3():
	pass
func play_sound():
	distant_door_open.play()
