extends CharacterBody3D

var move_dir := Vector3.ZERO
var look_target:= Vector3.ZERO
var wants_jump: bool = false
var wants_shoot: bool = false


enum States {DEFEND,ATTACK,CAPTURE, RETREAT}
var state = States.DEFEND



func _physics_process(delta: float) -> void:
	pass
