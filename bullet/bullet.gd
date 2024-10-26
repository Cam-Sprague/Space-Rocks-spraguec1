extends Area2D

@export var speed = 1000

var velocity = Vector2.ZERO

# Function to continously check position of bullets
func _process(delta):
	position += velocity * delta
	
# Function to remove bullets when they exit screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Function to detect collision of bullets when they hit rocks
func _on_body_entered(body: Node2D):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
		
# Function to detect collision of bullets when they hit enemies
func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
		
# Function to move bullet at set speed when fired by player
func start(_transform):
	transform = _transform
	velocity = transform.x * speed
	
