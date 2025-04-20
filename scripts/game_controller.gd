extends Node3D

#this script controls progression in the game. when a particular log is picked up, it sends a
#signal to this node, which iterates the level counter by one, each time opening a successive door, deeper into the ship.

var progression_counter = 0
var default_string = "open_door_"
var iterate_string
#@onready var door1: CSGBox3D = $"../doors/CSGBox3D12"
@onready var distant_door_open: AudioStreamPlayer3D = $DistantDoorOpen
@onready var timer: Timer = $Timer

@onready var door_1: Area3D = $"../doors/StairsDoor_Deck1_to_2"
@onready var door_2: Area3D = $"../doors/StairsDoor_Deck2_to_3"
@onready var door_3: Area3D = $"../doors/StairsDoor_Deck3_to_4"
@onready var door_4: Area3D = $"../doors/DoorOpen15_Brig"
@onready var area_3d: Area3D = $"../final sequence/Area3D"


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
	timer.start()
	door_1.open_door_distant()
	distant_door_open.play()
	
func open_door_2():
	door_2.open_door_distant()
	distant_door_open.play()

func open_door_3():
	door_3.open_door_distant()
	distant_door_open.play()

func open_door_4():
	print("door to brig open")
	door_4.unlock()
	
func open_door_5():
	print("trigger volume should have activated")
	area_3d._set_final_message_read()
	
