extends CharacterBody3D
@onready var camera_mount: Node3D = $camera_mount
@onready var visuals = $visuals
@onready var camera: Camera3D = $camera_mount/Camera3D
#@onready var inventory_node: Inventory = $InventoryNode
@onready var player_inventory: PlayerInventory = $Node
var equipped_weapon: Node = null

const SMOOTH_SPEED = 10.0

var SPEED = 3.0
const JUMP_VELOCITY = 4.5
var walking_speed = 3.0
var running_speed = 5.0
var aimed_speed = 1.5
@export var sens_horizontal = 0.0005
@export var sens_vertical = 0.0005

var aimed := false
@export var grouping := 0.15
@export var grouping_aimed = 0.05
var firing := false
@export var fire_rate := 0.10
#get some sort of check for ammmo later on.

func _firing():
	
	
	pass



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	

func _input(event):
	if event.is_action_pressed("aim"):
		aimed = true
		print(aimed)
	if event.is_action_released("aim"):
		aimed = false
		print(aimed)
	if event.is_action_pressed("reload"):
		if equipped_weapon and equipped_weapon.has_method("reload"):
			equipped_weapon.reload(player_inventory)
	if event.is_action_pressed("Interact"):
		cast_ray_from_camera()
	if Input.is_action_pressed("esc"):
		get_tree().quit()
	
	var sensmulti := 10
	if aimed:
		sensmulti = 50
	
	if event is InputEventMouseMotion:
		rotate_y(rad_to_deg(-event.relative.x*sens_horizontal /sensmulti))
		visuals.rotate_y(rad_to_deg(event.relative.x*sens_horizontal/sensmulti))
		camera_mount.rotate_x(rad_to_deg(-event.relative.y*sens_vertical /sensmulti))

#INTERACT FUNCTION
func cast_ray_from_camera():
	var ray_origin = camera.global_transform.origin
	var ray_dir = -camera.global_transform.basis.z.normalized()
	var ray_length = 5.0
	var ray_end = ray_origin + ray_dir * ray_length

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self.get_rid()]
	query.collision_mask = 1
	
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		var collider = result["collider"]
		print("Hit: ", collider.name)
		if collider.is_in_group("vehicles"):
			collider.receive_signal_from_player()
		if result.collider.has_method("collect"): #FIX THIS
			result.collider.collect(self)
		


func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("run") or Input.is_action_just_pressed("ui_accept") and !aimed:
		SPEED = running_speed 
	else:
		SPEED = walking_speed
	if aimed:
		SPEED = aimed_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var visual_dir = Vector3(input_dir.x,0, input_dir.y).normalized()
	if aimed:
		var current_rot = visuals.global_rotation
		var target_y = camera.global_rotation.y
		current_rot.y = lerp_angle(current_rot.y, target_y, delta * 8.0)
		visuals.global_rotation = current_rot
	
	if direction.length() > 0.01:
		input_dir = input_dir.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if !aimed:
			visuals.rotation.y = lerp_angle(visuals.rotation.y,atan2(-visual_dir.x, -visual_dir.z), delta * SMOOTH_SPEED)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func get_player_inventory() -> PlayerInventory:
	return $Node
#func get_inventory() -> Inventory:
#	return $InventoryNode
