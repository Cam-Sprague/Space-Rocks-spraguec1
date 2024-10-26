extends CanvasLayer

signal start_game

@onready var lives_counter = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message = $VBoxContainer/Message
@onready var start_button = $VBoxContainer/StartButton
@onready var shield_bar = $MarginContainer/HBoxContainer/ShieldBar

# Dictionary that holds the different colors of the shield bar
var bar_textures = {
	"green": preload("res://assets/bar_green_200.png"),
	"yellow": preload("res://assets/bar_yellow_200.png"),
	"red": preload("res://assets/bar_red_200.png")
}

# Function to emit start game once start button is pressed and hides uneccesary
# HUD upon signal being emitted
func _on_start_button_pressed():
	start_button.hide()
	start_game.emit()
	
# Function to hide the wave screen when timer runs out
func _on_timer_timeout():
	message.hide()
	message.text = ""

# Function to show messages like "Game Over", "Paused" and the title screen
func show_message(text):
	message.text = text
	message.show()
	$Timer.start()
	
# Function to update score based on wave
func update_score(value):
	score_label.text = str(value)
	
# Function to remove mini ships that act as lives when lives are lost
func update_lives(value):
	for item in 3:
		lives_counter[item].visible = value > item
		
# Function to display a game over screen
func game_over():
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()
	
# Function to display the shield bar (health) of the player as they get hit
func update_shield(value):
	shield_bar.texture_progress = bar_textures["green"]
	if value < 0.4:
		shield_bar.texture_progress = bar_textures["red"]
	elif value < 0.7:
		shield_bar.texture_progress = bar_textures["yellow"]
	shield_bar.value = value
