extends KinematicBody2D

var wheelbase : float = 70.0
var max_steering_angle : float = 15.0
var engine_power : float = 1000
var rolling_resistance : float = -0.9
var drag_coefficient : float = -0.001
var braking_power : float = -450
var reverse_max_speed : float = 250
var slip_speed : float = 400
var traction_low : float = 0.05
var traction_high : float = 0.4

var acceleration : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO
var steering_angle : float = 0.0

func _ready():
	$Camera2D.make_current()

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)

func get_input():
	var steering : float = 0.0
	if Input.is_action_pressed('left'):
		steering -= 1
	if Input.is_action_pressed('right'):
		steering += 1
	steering_angle = steering * deg2rad(max_steering_angle)
	
	if Input.is_action_pressed('forward'):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed('back'):
		acceleration = transform.x * braking_power

func apply_friction(delta):
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var fr : Vector2 = velocity * rolling_resistance
	var fd : Vector2 = velocity * velocity.length() * drag_coefficient
	velocity += (fr + fd) * delta

func calculate_steering(delta):
	var rear_wheel_location : Vector2 = position - transform.x * wheelbase / 2.0
	var front_wheel_location : Vector2 = position + transform.x * wheelbase / 2.0
	rear_wheel_location += velocity * delta
	front_wheel_location += velocity.rotated(steering_angle) * delta
	var heading : Vector2 = (front_wheel_location - rear_wheel_location).normalized()
	var traction : float = traction_high
	if velocity.length() > slip_speed:
		traction = traction_low
	var dot : float = heading.dot(velocity.normalized())
	if dot > 0:
		velocity = velocity.linear_interpolate(heading * velocity.length(), traction)
	elif dot < 0:
		velocity = heading * -min(velocity.length(), reverse_max_speed)
	rotation = heading.angle()
