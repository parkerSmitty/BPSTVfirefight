extends Node3D
class_name bullet

var bullet_velocity: Vector3 = Vector3.ZERO
var speed: float = 500
var lifetime: float = 3.0
var age: float = 0.0
var shot_direction: Vector3 = Vector3.ZERO
@onready var raycast: RayCast3D = $RayCast3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	pass

func initialize(start_position: Vector3, direction: Vector3, initial_speed: float) -> void:
	global_position = start_position
	shot_direction = direction.normalized()
	bullet_velocity = shot_direction * initial_speed
	speed = initial_speed
	look_at(global_position + bullet_velocity, Vector3.UP)
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	
	var movement_distance = bullet_velocity.length() * delta
	
	raycast.target_position = bullet_velocity.normalized() * movement_distance
	raycast.target_position = Vector3(0, 0, -movement_distance)
	raycast.force_raycast_update()
	
	
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		global_position = collision_point
		queue_free()
		return
	global_position += bullet_velocity * delta
#everything below is an older implementation. trying something new above 
#@export var speed := 350
#@export var damage = 50
#@export var life_time: float = 5.0
#@onready var ray: RayCast3D = $RayCast3D
#@onready var fx: MeshInstance3D = $Lightdisk
#@onready var bullet: MeshInstance3D = $MeshInstance3D
#@onready var mesh: MeshInstance3D = $MeshInstance3D
#@onready var particles: GPUParticles3D = $GPUParticles3D
#
#
#func _process(delta):
#	position += transform.basis * Vector3(0,0,-speed) * delta
#	if ray.is_colliding():
#		particles.emitting = true
#		mesh.visible = false
#		fx.visible = false
#		await get_tree().create_timer(1.0).timeout
#		queue_free()
##check out Use motion sweeps for this issue of tunneling yo
##var start = previous_position
##var end = position
##
##var params = PhysicsShapeQueryParameters3D.new()
##params.shape = SphereShape3D.new()
##params.shape.radius = 0.1
##params.motion = end - start
##
##var result = get_world_3d().direct_space_state.intersect_shape(params)
##if result.size() > 0:
##    # hit something
##    position = result[0].position
##    queue_free()
#
#func _on_timer_timeout() -> void:
#	queue_free()
#
