extends RigidBody3D

@export var ammo_type: String = ""
@export var amount: int = 0



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("player entered")
		var inv = body.get_player_inventory()
		inv.add_ammo(ammo_type, amount)
		queue_free()
