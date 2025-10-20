#



#this method is no longer in use. it has been simplified to PlayerInventory.gd #what the h was i thinking 







#extends Node
#class_name Inventory
#
#
##an array of {item: item, amount: int}
#var items: Array = []
#var ammo: Dictionary = {} 
#
#signal inventory_updated
#
#func add_item(item: Item, amount: int = 1):
	#if item == null:
		#push_error("tried to add null item to inventory")
	#if item.stackable:
		#for entry in items:
			#if entry.item.id == item.id:
				#item.amount += amount
				#emit_signal("inventory_updated")
				#return
	#if item == null:
		#push_error("tried to add null item to inventory")
	#elif item != null:
		#var item_instance = item.duplicate()
		#items.append({ "item": item_instance, "amount": amount})
		#emit_signal("inventory_updated")
		#print("inventory_updated")
		#print(item.name, " was added to inventory")
		#print(items)
		#
#
#func add_ammo(type: String, amount: int):
	#ammo[type] = ammo.get(type, 0) + amount
	#print("Picked up %d %s ammo. now: %d" % [amount, type, ammo[type]])
	#print(ammo)
	#
#
#func get_ammount_count(type: String) -> int:
	#return ammo.get(type, 0)
	#
#func remove_ammo(type: String, amount: int):
	#if not ammo.has(type):
		#return
	#ammo[type] = max(ammo[type] - amount, 0)
#
##CHECK PHOTOS FOR AMMO PICKUP IN THE WORLD AND FOR RELOAD IN PLAYER SCRIPT!!!!!!!
#
#
	#
#
#func remove_item(item_id: String, amount: int = 1):
	#for entry in items:
		#if entry.item.id == item_id:
			#entry.amount -= amount
			#if entry.amount <= 0:
				#items.erase(entry)
			#emit_signal("inventory_updated")
			#return
#
#func get_items() -> Array:
	#return items
#
#
		#
