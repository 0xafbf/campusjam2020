extends KinematicBody2D

var jump: bool = false
var input: Vector2

export var gravity: float = 400
var velocity: Vector2 = Vector2.ZERO
export var jump_speed = 1000

export var speed: float = 50
export var air_jump: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		jump = true

func _process(delta):
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor() or air_jump:
		if jump:
			velocity.y = -jump_speed
		
	jump = false
	
	var given_velocity = input * speed
	velocity.x = given_velocity.x
	
	var new_velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity = new_velocity
	
"""
	move_and_slide(linear_velocity: Vector2, up_direction: Vector2 = Vector2( 0, 0 ), stop_on_slope: bool = false, max_slides: int = 4, floor_max_angle: float = 0.785398, infinite_inertia: bool = true)
"""
