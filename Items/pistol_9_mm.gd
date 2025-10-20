extends RigidBody3D

@export var item_data: Item
@export var amount: int = 1
@export var current_ammo: int = 0
#@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


var ammo_type: String = "9mm"
var max_ammo: int = 15



func fire():
	if current_ammo > 0:
		current_ammo -= 1
		print("Bang! [%d%d]" % [current_ammo, max_ammo])
	else:
		print("Click, OUT")

func reload(Inventory):
	var needed = max_ammo - current_ammo
	if needed <= 0:
		print("already full")
		return
	
	var available = Inventory.get_ammo_count(ammo_type)
	var to_reload = min(needed, available)
	
	if to_reload > 0:
		current_ammo += to_reload
		Inventory.remove_ammo(ammo_type, to_reload)
		print("Reloaded %d bullets. [%d/%d]" % [to_reload, current_ammo, max_ammo])
	else:
		print("no ammo in reserve")
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func collect(by_who):
	if by_who.has_method("get_player_inventory"):
		var inventory = by_who.get_player_inventory()
		print("inventory =", inventory)
		print("inventory node is of type: ", inventory.get_class())
		print("has add_item()? ", inventory.has_method("add_item"))
		var clone = self.duplicate(DUPLICATE_USE_INSTANTIATION)
		inventory.add_item(clone)
		queue_free()
