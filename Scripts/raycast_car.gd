extends RigidBody3D
class_name RaycastCar

@export var wheels: Array[RaycastWheel]
@export var acceleration := 600.0
@export var max_speed := 20.0
@export var accel_curve : Curve
@export var tire_turn_speed :=2.0
@export var tire_max_turn_degress := 25


@export var total_wheels := 4

@export var skid_marks: Array[GPUParticles3D]

#entering/ exiting the car and switching cameras
@onready var car_zone: Area3D = $CharacterDetect
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@export var driver := false
var interact := false
var can_enter_car := false
var can_exit_car := false
var in_car := false

@onready var driver_seat: Node3D = $DriverSeat
@onready var passenger_seat: Node3D = $PassengerSeat
@onready var driver_side_exit: Node3D = $DriverSideExit
var player_ray := false

var player_ref: Node3D  

#steering
var motor_input := 0
var hand_break := false
var is_slipping := false

func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact = true
	elif event.is_action_released("Interact"):
		interact = false
	if driver:
		if event.is_action_pressed("handbreak"):
			hand_break = true
			is_slipping = true
		elif event.is_action_released("handbreak"):
			hand_break = false
		if event.is_action_pressed("accelerate"):
			motor_input = 1
		elif event.is_action_released("accelerate"):
			motor_input = 0
		if event.is_action_pressed("decelerate"):
			motor_input = -1
		elif event.is_action_released("decelerate"):
			motor_input = 0
		if event.is_action_pressed("esc"):
			get_tree().quit()
	#if event.is_action_pressed("Interact"):
		#enter_car = true

func _basic_steering_rotation(wheel: RaycastWheel, delta: float) -> void:
	if not wheel.is_steer: return
	if not driver: return
	var speed := linear_velocity.length()

	# Scale max turn between full at 0 speed and ~30% at top speed
	var speed_factor := clampf(1.0 - (speed / max_speed), 0.3, 1.0)
	var dynamic_max_turn := deg_to_rad(tire_max_turn_degress * speed_factor)

	var turn_input := Input.get_axis("right", "left") * tire_turn_speed
	if turn_input:
		wheel.rotation.y = clampf(
			wheel.rotation.y + turn_input * delta,
			-dynamic_max_turn, dynamic_max_turn)
	else:
		wheel.rotation.y = move_toward(wheel.rotation.y, 0, tire_turn_speed * delta)

	#var turn_input := Input.get_axis("right", "left") * tire_turn_speed
	#if turn_input:
		#wheel.rotation.y = clampf(wheel.rotation.y + turn_input * delta,
			#deg_to_rad(-tire_max_turn_degress), deg_to_rad(tire_max_turn_degress))
	#else:
		#wheel.rotation.y = move_toward(wheel.rotation.y, 0, tire_turn_speed * delta)
		#


func _physics_process(delta: float) -> void:
	#entering car process 
	if interact and can_enter_car:
		entering_car()
	if in_car:
		player_ref.global_transform.origin = driver_seat.global_transform.origin
		player_ref.global_rotation = driver_seat.global_rotation
	
	if interact and can_exit_car:
		exit_car()
	#wheel process
	var id := 0
	var grounded := false
	for wheel in wheels:
		wheel.apply_wheel_physics(self)
		_basic_steering_rotation(wheel, delta)
		
		if Input.is_action_pressed("break"):
			wheel.is_breaking = true
		else:
			wheel.is_breaking = false
		
		#skid marks
		skid_marks[id].global_position = wheel.get_collision_point() + Vector3.UP * 0.01
		skid_marks[id].look_at(skid_marks[id].global_position + global_basis.z)
		
		
		if not hand_break and wheel.grip_factor < 0.2:
			is_slipping = false
			skid_marks[id].emitting = false
		
		if hand_break and not skid_marks[id].emitting:
			skid_marks[id].emitting = true
		if wheel.is_colliding():
			grounded = true
		id += 1
#is not receiving signal
func receive_signal_from_player():
	player_ray = true
	print("car was hit by ray! the important signal")


func _ready():
	car_zone.body_entered.connect(_on_body_entered)
	car_zone.body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.name == "Player":
		player_ref = body
		can_enter_car = true
		
		 #Input.is_action_just_pressed("Interact") and 
		print("Player entered car zone")

func _on_body_exited(body):
	if body.name == "Player":
		can_enter_car = false
		print("Player exited car zone")



func entering_car():
	if interact and can_enter_car and player_ray and not in_car:
		print("interaction") #Input.is_action_just_pressed("Interact") and 
		camera_3d.make_current()
		interact = false
		driver = true
		#in the future make methods to control these things in the player script
		#so you can fine tune what is and isnt switched off in the player 
		self.add_collision_exception_with(player_ref)
		player_ref.add_collision_exception_with(self)
		print("added collision exception with ", self, player_ref)
		player_ref.set_physics_process(false)
		player_ref.set_process_input(false)
		#var player_rotation = player
		player_ref.global_transform.origin = driver_seat.global_transform.origin
		#player_ref.reparent(self)
		can_exit_car = true
		in_car = true
		


func exit_car():
	if interact and can_exit_car and in_car:
		print("car exited")
		driver = false
		interact = false
		in_car = false
		can_exit_car = false
		player_ref.set_physics_process(true)
		player_ref.set_process_input(true)
		var player_cam = get_node("../Player/camera_mount/Camera3D")
		player_cam.make_current()
		print("player layers and masks", player_ref.collision_layer, player_ref.collision_mask)
		print("car layers and masks", self.collision_layer, self.collision_mask)
		print("removed collision exception with ", self, player_ref)
		motor_input = 0
		player_ray = false
		var timer = Timer.new()
		timer.wait_time = 0.2
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_collision_reenable"))
		timer.start()

		player_ref.global_transform.origin = driver_side_exit.global_transform.origin
		#player_ref.rotation = 


func _on_collision_reenable():
	print("collisions added")
	self.remove_collision_exception_with(player_ref)
	player_ref.remove_collision_exception_with(self)


	
	

		#sends player back to main scene.
		#remove_child(player_ref)
		#var main_scene_parent = get_node("/root/World")
		#main_scene_parent.add_child(player_ref)
		#player_ref.global_position = driver_side_exit.global_position
		#var player_cam = get_node("../Player/camera_mount/Camera3D")
		
		#player_ref.call_deferred("remove_collision_exception_with", self) #<- not working player can glide though
		#print("removed collision exception with ", self)
		
		#player_ref.set_physics_process(true)
		#player_ref.set_process_input(true)
		#self.remove_collision_exception_with(player_ref)

#
	#if body.name == "Player":
		#playerinzone = true
		#if interact and playerinzone:
			#print("interaction") #Input.is_action_just_pressed("Interact") and 
			#camera_3d.make_current()
			#driver = true
		#print("Player entered car zone")

#MOVES PLAYER INTO SEAT!!! 
	##moves player into eat position
	#character.global_transform.origin = seat_node.global_transform.origin
	##possibly make character look forward... well see once full model is in use with neck bone 
	#character.look_at(global_transform.origin + transform.basis.z) #<-- makes the character face forward
	#


#func _do_single_wheel_traction(ray: RaycastWheel, idx: int) -> void:
	#if not ray.is_colliding(): return
	#
	#var steer_side_dir := ray.global_basis.x
	#var tire_vel := _get_point_velocity(ray.wheel.global_position)
	#var steering_x_vel := steer_side_dir.dot(tire_vel)
	#
	#var grip_factor := absf(steering_x_vel/tire_vel.length())
	#var x_traction := ray.grip_curve.sample_baked(grip_factor)
	#
	##skid marks 
#
	#
	#
	#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	#var x_force := -steer_side_dir * steering_x_vel *  x_traction * ((mass * gravity)/4.0)
	#
	##z force traction
	#var f_vel := -ray.global_basis.z.dot(tire_vel)
	#var z_traction := 0.05
	#var z_force := global_basis.z * f_vel * z_traction * ((mass*gravity)/4.0)
	##consider using ray.global_basis.z here, might make it more realistic
	#
	#var force_pos := ray.wheel.global_position - global_position
	#apply_force(x_force, force_pos)
	#apply_force(z_force, force_pos)
	#
#
#
#func _do_single_wheel_acceleration(ray: RaycastWheel) -> void:
	#var forward_dir := -ray.global_basis.z
	#var vel := forward_dir.dot(linear_velocity)
	#ray.wheel.rotate_x((-vel * get_process_delta_time())/ray.wheel_radius)
	#
	#if ray.is_colliding() and ray.is_motor:
		#var contact := ray.wheel.global_position
		#var force_pos := contact - global_position
		#
		#if ray.is_motor and motor_input:
			#var speed_ratio := vel / max_speed
			#var ac := accel_curve.sample_baked(speed_ratio)
			#var force_vector := forward_dir * acceleration * motor_input * ac
			#apply_force(force_vector, force_pos)
		#
#
#func _do_single_wheel_suspension(ray: RaycastWheel) -> void:
	#if ray.is_colliding():
		#ray.target_position.y = -(ray.rest_dist + ray.wheel_radius + ray.over_extend)
		#var contact := ray.get_collision_point()
		#var spring_up_dir := ray.global_transform.basis.y
		#var spring_len := ray.global_position.distance_to(contact) - ray.wheel_radius
		#var offset := ray.rest_dist - spring_len
		#
		#
		#ray.wheel.position.y = -spring_len
		#
		#var spring_force := ray.spring_strength * offset
		#
		## damping force = damping * relative velocity 
		#var world_vel := _get_point_velocity(contact)
		#var relative_vel := spring_up_dir.dot(world_vel)
		#var spring_damp_force := ray.spring_damping * relative_vel
		#
		#var force_vector := (spring_force - spring_damp_force) * ray.get_collision_normal()
		#
		#contact = ray.wheel.global_position
		#var force_pos_off := contact - global_position
		#apply_force(force_vector, force_pos_off)
		#
		#
		##DebugDraw.draw_arrow_ray(contact, force_vector, 2.5)
		#
