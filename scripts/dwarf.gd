extends CharacterBody2D
class_name dwarf

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var starting_jump := false
var timer

@onready var ability_detector = $AbilityDetector
@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -200.0 * 1.5
const DOWN_ACCELERATION = 1000.0 * 1.5
const JUMP_ACCELERATION = -3000.0 * 1.5
const CHARACTER_GRAVITY_MULTIPLIER = 1.2

var mult_placeholder = 0
var is_ability_active = false
var looking_right = true

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.set_wait_time(1)
	timer.connect("timeout", self._on_timer_timeout)
	animated_sprite_2d.set_animation("idle")
	animated_sprite_2d.play()




func _physics_process(delta):
	if Input.is_action_just_pressed("dwarf_ability") and ability_detector.has_overlapping_bodies():
		is_ability_active = !is_ability_active
		animated_sprite_2d.set_animation("grip")
		animated_sprite_2d.play()
		velocity.y = 0
	if !is_ability_active:
		if not is_on_floor():
			velocity.y += CHARACTER_GRAVITY_MULTIPLIER * gravity * delta

		# Handle jump.
		if Input.is_action_pressed("dwarf_up") and starting_jump:
			velocity.y += JUMP_ACCELERATION * delta
	
		if Input.is_action_pressed("dwarf_down") and not is_on_floor():
			velocity.y += DOWN_ACCELERATION * delta
		
		if Input.is_action_just_pressed("dwarf_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			starting_jump = true
			timer.start(0.1)
		
		var direction = Input.get_axis("dwarf_left", "dwarf_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if (velocity.x<0 and looking_right) or (velocity.x>0 and !looking_right):
				self.scale.x = -abs(self.scale.x)
				looking_right = !looking_right
		
		if velocity == Vector2.ZERO:
			animated_sprite_2d.set_animation("idle")
		else:
			animated_sprite_2d.set_animation("walk")
		move_and_slide()

func _on_timer_timeout():
	starting_jump = false
	
