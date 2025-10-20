extends Node3D

@onready var area_3d: Area3D = $Area3D


signal interact_triggered

var player_in_range = false

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		print("Player entered interactable zone")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		print("Player exited interactable zone")

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("Interact"):
		start_poker_game()

func start_poker_game():
	pass
