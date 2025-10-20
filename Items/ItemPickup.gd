extends RigidBody3D
@onready var Item_mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D


@export var item_data: Item
@export var amount: int = 1

func _ready():
	if item_data and item_data.equip_scene:
		var instance = item_data.equip_scene.instantiate()
		print("instantiated scene: ", instance)
		add_child(instance)
	else:
		print("ITS NOT WORKING")
		


func collect(by_who):
	if by_who.has_method("get_inventory"):
		var inventory = by_who.get_inventory()
		print("inventory =", inventory)
		print("inventory node is of type: ", inventory.get_class())
		print("has add_item()? ", inventory.has_method("add_item"))
		inventory.add_item(item_data, amount)
		queue_free()
