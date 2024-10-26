extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2


var follow = PathFollow2D.new()
var target = null

# Function to randomly choose color of enemy and make them follow one of 4 paths
func _ready():
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false
	
# Function to keep enemy on path and remove enemy once they have finished path
func _physics_process(delta):
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	
	if follow.progress_ratio >= 1:
		queue_free()

# Function to shoot at player once gun cooldown has finished
func _on_gun_cooldown_timeout():
	shoot_pulse(3, 0.15)
	
# Collision function to ignore rocks and explode on contact with player
func _on_body_entered(body):
	if body.is_in_group("rocks"):
		return
	explode()
	body.shield -= 50
	
# Function that allows for multiple shots to be fired once the cooldown has been
# lifted
func shoot_pulse(n, delay):
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

# Function to aim at player and shoot at them with some slight spread
func shoot():
	$ShootSound.play()
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)
	
# Function to take damage when shot by player
func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
		
# Function to explode when destroyed by player, removing from game environment
func explode():
	$ExplosionSound.play()
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("Explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
