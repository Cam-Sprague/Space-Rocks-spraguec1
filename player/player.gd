extends RigidBody2D

enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT

@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25
@export var max_shield = 100.0
@export var shield_regen = 5.0

signal lives_changed
signal dead
signal shield_changed

var reset_pos = false
var lives = 0: set = set_lives
var can_shoot = true
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO
var shield = 0: set = set_shield

# Function that initializes the player into INIT mode before the game starts
func _ready():
	$Sprite2D.hide()
	change_state(INIT)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate
	
# Function getting the players input as they play the game and regening shields
func _process(delta):
	get_input()
	shield += shield_regen * delta
	
# Function to control player rotation/forward movement
func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
# Function to allow the player to wrap around the screen when they hit an edge
# and resets position at the beginning of new games
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrap(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false
		
# Function to take player out of INVULNERABLE once invulnerability time has 
# ran out
func _on_invulnerability_timer_timeout():
	change_state(ALIVE)

# Function to detect when player collides with rock and makes them lose shield
func _on_body_entered(body: Node):
	if body.is_in_group("rocks"):
		shield -= body.size * 25
		body.explode()
		
# Function to keep track of gun cooldown so there is a delay between shots
func _on_gun_cooldown_timeout():
	can_shoot = true
	
# Function to change states of the player
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate.a = 1.0
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.hide()
			$EngineSound.stop()
			linear_velocity = Vector2.ZERO
			dead.emit()
	state = new_state

# Function to set the amount of player lives, when hitting zero changes player
# to DEAD state
func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	shield = max_shield
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)
	
# Function to get player input, playing corresponding sounds
func get_input():
	$Exhaust.emitting = false
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		$Exhaust.emitting = true
		thrust = transform.x * engine_power
		if not $EngineSound.playing:
			$EngineSound.play()
	else: 
		$EngineSound.stop()
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	print("State: ", state, "Rotation Dir: ", rotation_dir)
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

# Function to allow player to shoot lasers, ensuring they can't shoot during
# INVULNERABLE state
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
	$LaserSound.play()

# Function to reset player on new game start
func reset():
	reset_pos = true
	$Sprite2D.show()
	lives = 3
	change_state(ALIVE)

# Function to explode player when they die
func explode():
	$Explosion.show()
	$Explosion/AnimationPlayer.play("Explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()
	
# Function to set health/shield
func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield / max_shield)
	if shield <= 0:
		lives -= 1
		explode()
