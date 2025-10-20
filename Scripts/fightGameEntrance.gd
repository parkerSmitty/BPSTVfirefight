extends Node3D

var canFight := false
var interact := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#i made this comment for GIT
#no I made this comment for git
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interact and canFight:
		print("MORTALLLLL KOMBAT")
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact = true
	elif event.is_action_released("Interact"):
		interact = false



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("test your might")
		canFight = true
		
	if Input.is_action_just_pressed("Interact"):
		print("interacted with kombat zone")
		#pull up map picker (current location should be only choice if player hasnt unlocked other locations.
		#but the logic for unlocked maps wont be handled here lol
		pass


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		print("no honor, player left fight entrance")
		canFight = false
