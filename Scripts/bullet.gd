extends RigidBody3D

@export var speed: float = 80.0
@export var damage = 50
@export var life_time: float = 15.0

func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = true
	
	linear_velocity = -transform.basis.z * speed
	
	await get_tree().create_timer(life_time).timeout
	queue_free()
	


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.has_method("take_damage"):
		body.take_damage(10)
	queue_free()
