extends Node2D
class_name Task

@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

@export var task_name: String
@export var duration: float = 3.0

var is_completed: bool = false
var is_in_progress: bool = false
var radius: float

signal task_started
signal task_completed

func _ready() -> void:
	timer.wait_time = duration
	timer.connect("timeout", _on_task_timeout)
	radius = collision_shape.shape.radius

func start_task():
	if not is_completed:
		is_in_progress = true
		emit_signal("task_started", self)
		timer.start()

func _on_task_timeout():
	complete_task()

func complete_task():
	is_completed = true
	is_in_progress = false
	emit_signal("task_completed", self)
