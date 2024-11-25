extends Node2D
class_name Task

@onready var timer: Timer = $Timer

@export var task_name: String
@export var duration: float = 3.0

var is_completed: bool = false
var is_in_progress: bool = false

signal task_started
signal task_completed

func _ready() -> void:
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", _on_task_timeout)

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
