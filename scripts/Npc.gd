extends CharacterBody2D
class_name NpcAgent

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var avoidance_range: Area2D = $AvoidanceRange

@export var move_speed: float = 100.0
@export var task_radius: float = 10.0

var char_name: String
var current_task: Task = null
var is_moving_to_task: bool = false

func assign_task(task: Task):
	if task == null:
		current_task = null
		is_moving_to_task = false
	else:
		current_task = task
		is_moving_to_task = true


func _physics_process(delta):
	if current_task and is_moving_to_task:
		move_to_task(delta)


func move_to_task(delta):
	if current_task:
		var direction = (current_task.position - position).normalized()
		velocity = direction * move_speed

		if position.distance_to(current_task.position) <= task_radius:
			velocity = Vector2.ZERO
			is_moving_to_task = false
			current_task.start_task()

		move_and_slide()
