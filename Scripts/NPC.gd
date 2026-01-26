extends CharacterBody3D

#the NPC will decide between defending an area, attacking an area, retreating, or entering a vehicle
#if it sees a player with its vision cone, it will change to defending its immediate area via 2 options
#1: fight (crouching, straifing, or standing still)  (chance to throw gernade)
#2: chance to run away or charge (if low heath)
# after the player is dead, ai has safely escaped, or died it will return to the begining of
# its decision life cycle and continue on from there 
#ATTACK go towards enemy control point
#DEFEND, patrtol area
#RETREAT, go towards friendly controlpoint
#VEHIC, get in vehicle 

#states
enum States {ATTACK, DEFEND, RETREAT,FIGHT, VEHIC}
var state: States = States.DEFEND
var previous_state: States
var defending := false
var attacking := false
var retreating := false
var fighting := false
#states

#movement
var walking_speed = 3.0
var running_speed = 5.0
var current_speed = walking_speed
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var thinkie: Timer = $Thinkie

#movement

#health and ragdoll
var health: int = 100
@onready var skeleton_3d: Skeleton3D = $"visuals/heavy game animations/Armature/Skeleton3D"
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $visuals/ragdoll/Armature/ragdoll_skeleton/PhysicalBoneSimulator3D
@onready var physicalBoner: PhysicalBoneSimulator3D = $"visuals/heavy game animations/Armature/Skeleton3D/PhysicalBoneSimulator3D"
var is_dead := false
@onready var armature: Node3D = $"visuals/heavy game animations/Armature"
@onready var rag_doll_skel: Skeleton3D = $Ragdoll/ragdollanim/Armature/ragDollSkel
@onready var rag_doll_physical: PhysicalBoneSimulator3D = $Ragdoll/ragdollanim/Armature/ragDollSkel/PhysicalBoneSimulator3D
@onready var ragdoll: Node3D = $Ragdoll
#health and ragdoll

func _decide_next_state(): #changing states now works, actually program state dependent behavior now
	if health <= 15:
		state = States.RETREAT
func _on_player_detected():
	_decide_next_state()

func _ready() -> void:
	agent.velocity_computed.connect(Callable(_on_velocity_computed))
	thinkie.start()
	thinkie.timeout.connect(_decide_next_state)

func set_movement_target(movement_target: Vector3):
	agent.set_target_position(movement_target)

func _physics_process(delta):
	if health <=0:
		death()
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	if state != previous_state:
		_on_state_exited(previous_state)
		_on_state_entered(state)
		previous_state = state
	
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * current_speed
	if agent.avoidance_enabled:
		agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func _on_state_exited(old_state: States):
	match old_state:
		States.DEFEND:
			defending = false
		States.ATTACK:
			attacking = false
		States.FIGHT:
			fighting = false
		States.RETREAT:
			retreating = false

func _on_state_entered(new_state: States):
	match new_state:
		States.DEFEND:
			_on_defend()
		States.ATTACK:
			_on_attack()
		States.RETREAT:
			_on_retreat()
		States.FIGHT:
			_on_fight()
		States.VEHIC:
			print("car vroom vro")
			
func _on_defend():
	if defending:
		return
	defending = true
	
	while defending:
		print("Defending")
		await get_tree().create_timer(8.0).timeout
	#set_movement_target()
func _on_attack():
	if attacking:
		return
	
	attacking = true
	
	while attacking:
		print("attacking")
		await get_tree().create_timer(8.0).timeout
func _on_fight():
	if fighting:
		return
	
	fighting = true
	
	while fighting:
		print("fighting")
		await get_tree().create_timer(8.0).timeout
func _on_retreat():
	if retreating:
		return
	
	retreating = true
	
	while retreating:
		print("retreating")
		await get_tree().create_timer(8.0).timeout


func hit(damage):
	health -= damage


func death(): #remeber to disable capsule collision when they die, fix this later
	if is_dead:
		return
	print("should print once to show its dead")
	is_dead = true
	
	armature.visible = false
	ragdoll.visible = true
	
	#sets pose to animated pose
	for i in skeleton_3d.get_bone_count():
		var bone_name := skeleton_3d.get_bone_name(i)
		var rag_doll_skel_idx := rag_doll_skel.find_bone(bone_name)
		if rag_doll_skel_idx == -1:
			continue
		
		var pose := skeleton_3d.get_bone_pose(i)
		rag_doll_skel.set_bone_pose(rag_doll_skel_idx, pose)
	
	rag_doll_skel.force_update_all_bone_transforms()
	#
	rag_doll_physical.physical_bones_start_simulation()
	rag_doll_physical.active = true
	
	
	await get_tree().physics_frame
	for child in rag_doll_physical.get_children():
		if child is PhysicalBone3D:
			
			#replace with force from killing object
			child.can_sleep = false
			child.angular_velocity = Vector3(0,0,0)
