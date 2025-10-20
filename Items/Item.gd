extends Resource

class_name Item
@export var id: String = ""
@export var name: String = ""
@export var Icon: Texture2D
@export var description: String = ""
@export var item_type: String = ""
@export var stackable: bool = false
@export var grabbable: bool = true
@export var max_stack: int = 1
@export var equip_scene: PackedScene
@export var data: Dictionary = {}

#weapon specific
