extends Node2D
class_name Task

@export var task_name: String
@export var duration: float = 3.0
@export var location: Vector2
@export var task_type: String

var is_completed: bool

signal task_started
signal task_completed


func start_task() -> void:
	if not is_completed:
		emit_signal("task_started", self)
		var timer = get_tree().create_timer(duration)
		await timer.timeout
		complete_task()


func complete_task() -> void:
	if not is_completed:
		is_completed = true
		emit_signal("task_completed", self)


func reset_task() -> void:
	is_completed = false


func _on_npc_entered(npc: NpcAgent) -> void:
	pass
