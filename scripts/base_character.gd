extends CharacterBody2D
class_name BaseCharacter


const SPEED = 300.0
const JUMP_VELOCITY = -200.0 * 1.5
const DOWN_ACCELERATION = 1000.0 * 1.5
const JUMP_ACCELERATION = -3000.0 * 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var starting_jump := false
var timer

func _init():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.set_wait_time(1)
	timer.connect("timeout", self._on_timer_timeout)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and starting_jump:
		velocity.y += JUMP_ACCELERATION * delta
	
	if Input.is_action_pressed("ui_down") and not is_on_floor():
		velocity.y += DOWN_ACCELERATION * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		starting_jump = true
		timer.start(0.1)
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func _on_timer_timeout():
	starting_jump = false
	
