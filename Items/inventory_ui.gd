extends Control


@export var inventory_node_path: NodePath #TO MAKE IT WORK CONNECT THIS TO THE ACTUAL INVENTORY YOU CHATGPT USING SON OF A GUN
var inventory: Node = null
var items_list: VBoxContainer #make it look nice later on!
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = get_node(inventory_node_path)
	items_list = $VBoxContainer
#	refresh_ui()
	close()

func clear_items_list():
	for child in items_list.get_children():
		child.queue_free()

#func refresh_ui():
	#clear_items_list()
	#
	#for i in range(inventory.items.size()):
		#var item = inventory.items[i]
		#var button = Button.new()
		#button.text = item.name if item.has_method(name) else "unknown"
		#button.name = str(i) #store index as button name 
		#
		#button.pressed.connect(self._on_item_selected)
		#items_list.add_child(button)
		#

func _on_item_selected():
	var button = get_tree().get_current_scene().get_focus_owner()
	if button:
		var index = int(button.name)
		select_item(index)
		

func select_item(index: int):
	var item = inventory.items[index]
	if item:
		print("Selected", item.name)
		#call equip function here WHENEVER I GET AROUND TO MAKING IT!!! create equip function in inventory

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tab"):
		print("tab")
		if is_open:
			print("closed called")
			close()
		else:
			open()
			print("open called")


func open():
	self.visible = true
	is_open = true


func close():
	visible = false
	is_open = false
