extends CharacterBody2D
class_name dwarf

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var starting_jump := false
var timer

@onready var ability_detector = $anchor/AbilityDetector
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var anchor = $anchor
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

const SPEED = 300.0
const JUMP_VELOCITY = -200.0 * 1.5
const DOWN_ACCELERATION = 1000.0 * 1.5
const JUMP_ACCELERATION = -3000.0 * 1.5
const CHARACTER_GRAVITY_MULTIPLIER = 1.2

var mult_placeholder = 0
var is_ability_active = false
var looking_right = true
var time_since_jump_pressed = 10

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.set_wait_time(1)
	timer.connect("timeout", self._on_timer_timeout)
	animated_sprite_2d.set_animation("idle")
	animated_sprite_2d.play()

func _physics_process(delta):
	if Input.is_action_just_pressed("dwarf_ability"):
		if ability_detector.has_overlapping_bodies():
			is_ability_active = !is_ability_active
			velocity.y = 0
		state_machine.travel("swing")
		animated_sprite_2d.play()
	if !is_ability_active:
		if not is_on_floor():
			velocity.y += CHARACTER_GRAVITY_MULTIPLIER * gravity * delta

		# Handle jump.
		if Input.is_action_pressed("dwarf_up") and starting_jump:
			velocity.y += JUMP_ACCELERATION * delta
	
		if Input.is_action_pressed("dwarf_down") and not is_on_floor():
			velocity.y += DOWN_ACCELERATION * delta
		
		
		time_since_jump_pressed+=1
		if Input.is_action_just_pressed("dwarf_up"):
			time_since_jump_pressed = 0
		
		if time_since_jump_pressed<5 and is_on_floor():
			velocity.y = JUMP_VELOCITY
			starting_jump = true
			timer.start(0.1)
		
		var direction = Input.get_axis("dwarf_left", "dwarf_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if (velocity.x<0 and looking_right) or (velocity.x>0 and !looking_right):
				animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
				anchor.scale.y = - anchor.scale.y
				looking_right = !looking_right
		
		if velocity == Vector2.ZERO:
			state_machine.travel("idle")
			animated_sprite_2d.play()
		else:
			state_machine.travel("walk")
			animated_sprite_2d.play()
		print(global_position, velocity)
		move_and_slide()

func _on_timer_timeout():
	starting_jump = false
	
