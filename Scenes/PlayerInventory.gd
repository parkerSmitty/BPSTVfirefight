extends Node
class_name PlayerInventory


var items: Array = []
var ammo: Dictionary = {} 

signal inventory_updated


func add_item(item: Node):
	items.append(item)
	emit_signal("inventory_updated")
	print(item.name, " was added to inventory")
	print(item.current_ammo, " shots left in mag")







#^^^^^^^^^^^^^^^ ADDING ITEMS  ^^^^^^^^^^^^^
#VVVVVVVVVVVVVVV ADDING AMMO   VVVVVVVVVVVVVV


func add_ammo(type: String, amount: int):
	ammo[type] = ammo.get(type, 0) + amount
	print("Picked up %d %s ammo. now: %d" % [amount, type, ammo[type]])
	print(ammo)
	

func get_ammount_count(type: String) -> int:
	return ammo.get(type, 0)
	
func remove_ammo(type: String, amount: int):
	if not ammo.has(type):
		return
	ammo[type] = max(ammo[type] - amount, 0)
