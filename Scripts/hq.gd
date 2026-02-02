extends Node3D
@onready var area_3d: Area3D = $Area3D
@export var team: String

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("entity entered")


func _on_area_3d_body_exited(body: Node3D) -> void:
	print("entity exited")
