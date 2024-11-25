extends CharacterBody2D
class_name NpcAgent

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label

@export var move_speed: float = 4.0

var char_name: String
var current_task = null


func _ready():
	label.position = Vector2(
		0,
		-30
	)
