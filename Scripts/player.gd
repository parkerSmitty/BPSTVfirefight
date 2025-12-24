extends CharacterBody3D
@onready var camera_mount: Node3D = $camera_mount
@onready var visuals = $visuals
@onready var camera: Camera3D = $camera_mount/SpringArm3D/Camera3D
#@onready var inventory_node: Inventory = $InventoryNode
@onready var player_inventory: PlayerInventory = $Node
var equipped_weapon: Node = null


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const SMOOTH_SPEED = 10.0

var SPEED = 3.0
const JUMP_VELOCITY = 4.5
var walking_speed = 3.0
var running_speed = 5.0
var aimed_speed = 1.5
var running := false
var start_run := false
var crouch_speed := 1.5
var crouched := false
@export var sens_horizontal = 0.0005
@export var sens_vertical = 0.0005
@export var min_pitch := deg_to_rad(60)
@export var max_pitch := deg_to_rad(-60)

#aimming and cam stuff
var lean_right := false
var lean_left := false
var run_cam_posR = Vector3(1.0, 0.9,0.0)
var run_cam_posL = Vector3(-1.0, 0.9,0.0)
var crouch_cam_posR = Vector3(1.0,0.07,-1.7)
var crouch_cam_posL = Vector3(-1.0,0.07,-1.7)
var aim_cam_posR = Vector3(0.8, 0.5,-1.7)
var aim_cam_posL = Vector3(-0.8, 0.5,-1.7)
var base_cam_posR = Vector3(1.0,0.9,-0.7)
var base_cam_posL = Vector3(-1.0,0.9,-0.7)
var base_cam_current = base_cam_posR
var previous_aimed := false
var previous_leaned := false
#test these out my brotha VVV
var def_fov := 75.0
var run_fov := 90.0
var aim_fov := 60.0
#test ^^

#gun stuff
@onready var cam_spring: SpringArm3D = $camera_mount/SpringArm3D
var aimed := false
#maybe implement this 
@export var grouping := 0.15
@export var grouping_aimed = 0.05
#maybe maybe maybe ^^^^
var firing := false
@export var fire_rate := 0.10
var ammo = 400
var mag = 200
var canfire := true
@export var gunRayLength := 1000.0

#get some sort of check for ammmo later on.

#BULLLLLET DAAAA
@onready var gun: Node3D = $"visuals/heavy game animations/Armature/Skeleton3D/righthand/containerR/PKMLMG"
@onready var crosshair: Label = $crosshair
@onready var gun_anim = $"visuals/heavy game animations/Armature/Skeleton3D/righthand/containerR/PKMLMG/AnimationPlayer"
@onready var gun_muzzle = $"visuals/heavy game animations/Armature/Skeleton3D/righthand/containerR/PKMLMG/RayCast3D"
@onready var local_muz: Node3D = $local_muz
var BULLET_SCENE = load("res://Scenes/bullet.tscn")
#var instance wtf was this used for?

#character visuals and such
@onready var move_state_machine: AnimationNodeStateMachinePlayback = $"visuals/heavy game animations/AnimationTree".get("parameters/movement/playback")
@onready var heavy_visuals: AnimationTree = $"visuals/heavy game animations/AnimationTree"

#movement
var jumpQueued: bool;
var falling: bool;
var jumping:bool;
@export var locomotionStatePlaybackPath: String;
@export var walkingBlendPath: String;
@export var crouchBlendPath: String;
@export var jumpStateName: String;
@export var fallingStateName: String;
@export var walkingStateName: String;
@export var crouchStateName: String;
@export var sprintStateName: String;

@export var animationTree: AnimationTree;
@export var transitionSpeed: float = 5.0;
@export var speed: float = 5.0;
@export var jumpVelocity: float = 4.5
var currentInput: Vector2;
var currentVelocity: Vector2;

func set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)


func reload():
	print("reload")

func _process(delta):
	var newDelta = currentInput - currentVelocity;
	if (newDelta.length() > transitionSpeed * delta):
		newDelta = newDelta.normalized() * transitionSpeed * delta;
		
	currentVelocity += newDelta;
	if crouched:
		animationTree.set(crouchBlendPath, currentVelocity) 
	else:
		animationTree.set(walkingBlendPath, currentVelocity)
	

func _firing():
	#below is a working state, above is a slightly different implementation to reslvoe snaping issue
	#CURRNTLY THE BULLET IS USED FOR DIRECTION
	#UPDATE THIS WHEN VISUALS ARE IN TO USE THE GUN TO AIM DIRECTION 
	#and the BULLET ONLY FLIES IN STRIAGHT LINE WHEREVER GUN IS AIMED.
	canfire = false
	if !gun_anim.is_playing():
		gun_anim.play("shoot")
	var new_bullet:bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	#-gun_muzzle.global_basis.z
	var hit = camera_target()
	var target_position: Vector3
	if hit:
		target_position = hit.position
	else:
		target_position = camera.global_position + (-camera.global_transform.basis.z) * 2000.0
	# Convert target_position → direction vector
	var direction = target_position - gun_muzzle.global_position
	new_bullet.initialize(gun_muzzle.global_position, direction, 200)
	await get_tree().create_timer(0.05).timeout
	canfire = true

func _on_exited_car():
	print("make the player cam current")
	$camera_mount/SpringArm3D/Camera3D.make_current()

func _ready():
	heavy_visuals.active = true
	
	for car in get_parent().get_children():
		if car is RaycastCar:
			car.exited_car.connect(_on_exited_car)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	var car = get_node("../Car")
	car.exited_car.connect(_on_exited_car)

	

func _input(event):
	if event.is_action_pressed("fire") and canfire:
		firing = true
	if event.is_action_released("fire"):
		firing = false
	if event.is_action_pressed("aim"):
		if running:
			print("attempted aim while running")
			is_running()
		aimed = true
	if event.is_action_released("aim"):
		aimed = false
	if event.is_action_pressed("reload"):
		pass
	if event.is_action_pressed("crouch") and !running:
		crouched = !crouched
		#set reload to true and call the reload fucntion elswhere 
		#if equipped_weapon and equipped_weapon.has_method("reload"):
			#equipped_weapon.reload(player_inventory)
	if event.is_action_pressed("Interact"):
		cast_ray_from_camera()
	if event.is_action_pressed("lean right"):
		lean_right = true
	if event.is_action_pressed("lean left"):
		lean_left = true
	if Input.is_action_pressed("esc"):
		get_tree().quit()
	if is_on_floor() && Input.is_action_just_pressed("ui_accept") && !aimed && !crouched:
		BeginJump()
		jumping = true
	if event.is_action_pressed('run'):
		start_run = true
	if event.is_action_released('run'):
		start_run = false
		
	var sensmulti := 10
	if aimed:
		sensmulti = 50
	
	if event is InputEventMouseMotion:
		rotate_y(rad_to_deg(-event.relative.x*sens_horizontal /sensmulti))
		visuals.rotate_y(rad_to_deg(event.relative.x*sens_horizontal/sensmulti))
		camera_mount.rotate_x(rad_to_deg(-event.relative.y*sens_vertical /sensmulti))
		
		var rot = camera_mount.rotation
		rot.x = clamp(rot.x, deg_to_rad(-60), deg_to_rad(60))
		camera_mount.rotation = rot
		
		#camera_mount.rotation_degrees.x = clamp(camera_mount.rotation_degrees.x, rad_to_deg(min_pitch),rad_to_deg(max_pitch))

func camera_target():
	var ray_origin = camera.global_transform.origin
	var ray_dir = -camera.global_transform.basis.z.normalized()
	var ray_end = ray_origin + ray_dir * 1000.0

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self.get_rid()]
	query.collision_mask = 1

	return get_world_3d().direct_space_state.intersect_ray(query)

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
		
#func unaim():
#	cam_spring.position = cam_spring.position.lerp(base_cam_current, 0.05) 
#	print("unaimed")
#
#func aim():
#	if base_cam_current == base_cam_posR:
#		cam_spring.position = aim_cam_posR
#		#cam_spring.position = cam_spring.position.lerp(base_cam_current, 0.05)
#		#cam_spring.position = aim_cam_posR
#	else:
#		#cam_spring.position = aim_cam_posL
#		cam_spring.position = aim_cam_posL
#	print("AIMEDDDD!!") 

func leanRight():
	if !aimed:
		base_cam_current = base_cam_posR


func leanLeft():
	if !aimed:
		base_cam_current = base_cam_posL


var walk_blend := Vector2.ZERO
var crouch_blend := Vector2.ZERO
var was_on_floor: bool = false
var jump_queued := false
var jump_delay := 0.30  # seconds before actual takeoff
func _physics_process(delta: float) -> void:
	var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
	if canfire and firing:
		_firing()
		

	
	##+++++++++++++++CAMERA STUFF AND ROTATING VISUALS VVV++++++++++++++++++++

	var visual_dir = Vector3(currentInput.x,0, currentInput.y).normalized()
	var current_rot = visuals.global_rotation
	var target_y = camera.global_rotation.y
	var fov_speed = 6.0
	var target_fov
	if aimed:
		target_fov = aim_fov
	elif running:
		target_fov = run_fov
	else:
		target_fov = def_fov
	
	camera.fov = lerp(camera.fov, target_fov, clamp(delta * fov_speed,0,1))
	
	cam_spring.add_excluded_object(self)
	
	if camera.current: # figure this shit out inorder to hide crosshair in car 
		crosshair.is_visible_in_tree()
	if !camera.current:
		pass
	if lean_left != previous_leaned:
		if lean_left:
			leanLeft()
			lean_left = previous_leaned
	if lean_right != previous_leaned:
		if lean_right:
			leanRight()
			lean_right = previous_leaned
	
	var target: Vector3
	if aimed:
		if base_cam_current == base_cam_posR:
			target = aim_cam_posR
		else:
			target = aim_cam_posL
	else:
		target = base_cam_current
	cam_spring.position = cam_spring.position.lerp(target,0.09)
	
		#rotating visuals 
	current_rot.y = lerp_angle(current_rot.y, target_y, delta * 8.0)
	visuals.global_rotation = current_rot
	if aimed or firing:
		current_rot.y = lerp_angle(current_rot.y, target_y, delta * 8.0)
		visuals.global_rotation = current_rot
	
		#if !aimed and !firing: 
			#visuals.rotation.y = lerp_angle(visuals.rotation.y,atan2(-visual_dir.x, -visual_dir.z), delta * SMOOTH_SPEED)
		#change this back to having the character look the direction theyre walking. ^^^^^
		#perhaps add some smoothing so they flow into direction changes or something idk.
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	##++++++++++++++++++CAMERA STUFF AND ROTATING VISUALS ^^^^+++++++++++++++++++++++++
	##====================PLAYER MOVEMENT AND ANIMATION VVV=======================
	
	if !is_on_floor():
		velocity.y -= gravity * delta
		jumpQueued = false
		jumping = true
		if !falling:
			falling = true
			#var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
			playback.travel(fallingStateName)
	else: if falling:
		falling = false
		#var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
		playback.travel(walkingStateName)
		jumping = false
		crouched = false
	
	if jumpQueued:
		velocity.y = jumpVelocity
		jumpQueued = false
		falling = true
	if is_on_floor():
		currentInput = Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(currentInput.x, 0, currentInput.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.z = move_toward(velocity.z,0,SPEED)
	
	#running with a check for jumping to overrider
	#maybe move all these checks to input and change this to a function that is 
	#triggered from the running animation. this will help with movement speed being shifted
	#to running before the player is fully standing, as well as movement speed not shifting
	#before the walk animation fully transfer to running animation
	if start_run and !jumping and currentInput.y < -0.1 and abs(currentInput.x) < 0.1 and is_on_floor():
		SPEED = running_speed
		crouched = false
		running = true
		playback.travel(sprintStateName)
	elif !crouched and !jumping and !aimed:
		SPEED = walking_speed
		running = false
		if is_on_floor():
			playback.travel(walkingStateName)
	
	if aimed and is_on_floor():
		SPEED = aimed_speed
		running = false
		start_run = false
		if crouched:
			playback.travel(crouchStateName)
		else:
			playback.travel(walkingStateName)
	
	if !running and !jumping and crouched and is_on_floor():
		SPEED = crouch_speed
		playback.travel(crouchStateName)
		#animationTree.set(crouchBlendPath, currentVelocity) 
		
		#want to use crouch blendspace here
	
	move_and_slide()

func is_running():
		start_run = !start_run
	

func BeginJump():
	var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
	playback.travel(jumpStateName)

func ExecuteJumpVelocity():
	jumpQueued = true

func get_player_inventory() -> PlayerInventory:
	return $Node



#graveyard, maybe some useful stuff down there
	
	
	#if aimed != previous_aimed:
	#	if aimed:
	#		aim()
	#	else:
	#		unaim()
	#	previous_aimed = aimed
	
	
	#idk what this does? VVV probably redundant 
	#if direction.length() > 0.01:
		#currentInput = currentInput.normalized()
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
		#visuals.global_rotation = current_rot
	#probably redundent^^^
	
	
	# old implementation vVvvv
	#walk_blend = walk_blend.lerp(currentInput, delta * 8.0)
	#heavy_visuals.set("parameters/movement/walk/blend_position", walk_blend)
	#
	#crouch_blend = crouch_blend.lerp(currentInput, delta * 8.0)
	#heavy_visuals.set("parameters/movement/crouch/blend_position", crouch_blend)
	#
	##handle movement like so: landing > crouch > running > aiming > walking
	##if landing: handel landing here
	#if crouched and is_on_floor():
		#SPEED = aimed_speed
		#set_move_state('crouch')
		#if base_cam_current == base_cam_posR:
			#cam_spring.position = cam_spring.position.lerp(crouch_cam_posR, 0.05)
		#else:
			#cam_spring.position = cam_spring.position.lerp(crouch_cam_posL, 0.05)
	#
	#if SPEED != running_speed and !crouched:
		#set_move_state('walk')
#
	##crouch logic and visuals
	#if not running and is_on_floor() and crouched:
		#SPEED = aimed_speed
		#set_move_state('crouch')
		#if base_cam_current == base_cam_posR:
			#cam_spring.position = cam_spring.position.lerp(crouch_cam_posR, 0.05)
		#else:
			#cam_spring.position = cam_spring.position.lerp(crouch_cam_posL, 0.05)
	#
	#if crouched and Input.is_action_pressed("crouch"):
		#set_move_state('walk')
		#SPEED = walking_speed
		#
	#
	##adjusts animing speed
	#if Input.is_action_pressed("run") and !aimed and currentInput.y < -0.1 and abs(currentInput.x) < 0.2:
		#SPEED = running_speed
		#running = true 
		#crouched = false
		#set_move_state('heavy_run')
		#if !aimed:
			#if base_cam_current == base_cam_posR:
				#cam_spring.position = cam_spring.position.lerp(run_cam_posR, 0.05)
			#else:
				#cam_spring.position = cam_spring.position.lerp(run_cam_posL, 0.05)
	#
	#elif !aimed and !crouched:
		#SPEED = walking_speed
		#running = false
		#cam_spring.position = cam_spring.position.lerp(base_cam_current, 0.05)
	#if aimed:
		#SPEED = aimed_speed
	#
	## Handle jump.
	#if !is_on_floor():
		#velocity -= get_gravity() * delta
		#jumpQueued = false
		#if !falling:
			#falling = true
			#var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
			#playback.travel(fallingStateName)
	#else: if falling:
		#falling = false
		#var playback = animationTree.get(locomotionStatePlaybackPath) as AnimationNodeStateMachinePlayback;
		#playback.travel(walkingStateName)
	##put it after the falling handler makes sure that the transition
	##dosnt automactically force it into a falling animation instead of letting the jump animation natually
	##finish
	#if jumpQueued:
		#velocity.y = jumpVelocity
		#jumpQueued = false
		#falling = true
	#
	## Add the gravity.
	#if not is_on_floor():
		#velocity +=  get_gravity() * delta
	##update state 
	#move_and_slide()
	## determine on-floor and vertical motion state
	#
	#
	#
	#
	##GUN ROTATION
	
	


#func get_inventory() -> Inventory:
#	return $InventoryNode
