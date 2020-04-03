extends KinematicBody2D

var wheelbase : float = 70.0
var max_steering_angle : float = 15.0
var velocity : Vector2 = Vector2.ZERO
var steering_angle : float = 0.0
var max_speed : float = 500

#func _ready():
	#$Camera2D.make_current()

func _physics_process(delta):
	get_input()
	calculate_steering(delta)
	velocity = move_and_slide(velocity)

func get_input():
	var steering : float = 0.0
	if Input.is_action_pressed('left'):
		steering -= 1
	if Input.is_action_pressed('right'):
		steering += 1
	steering_angle = steering * deg2rad(max_steering_angle)
	
	velocity = Vector2.ZERO
	if Input.is_action_pressed('forward'):
		velocity = transform.x * max_speed

func calculate_steering(delta):
	var rear_wheel_location : Vector2 = position - transform.x * wheelbase / 2.0
	var front_wheel_location : Vector2 = position + transform.x * wheelbase / 2.0
	rear_wheel_location += velocity * delta
	front_wheel_location += velocity.rotated(steering_angle) * delta
	var heading : Vector2 = (front_wheel_location - rear_wheel_location).normalized()
	velocity = heading * velocity.length()
	rotation = heading.angle()
