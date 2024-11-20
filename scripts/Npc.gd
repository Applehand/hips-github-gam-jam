extends CharacterBody2D
class_name NpcAgent

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var label: Label = $Label

@export var move_speed: float

var char_name: String
var current_task = null




func move_to_task(current_task) -> void:
	pass


func perform_task(current_task) -> void:
	pass
