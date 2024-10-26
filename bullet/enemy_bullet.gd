extends Area2D

@export var speed = 1000
@export var damage = 15

# Function to check enemy bullet position at all times	
func _process(delta):
	position += transform.x * speed * delta
	
# Function that deletes bullet once it's left the screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Function to make player take damage when hit by enemy bullet
func _on_body_entered(body):
	if body.name == "Player":
		body.shield -= damage
	queue_free()

# Function to determine position and direction of bullet being fired at player
func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()
