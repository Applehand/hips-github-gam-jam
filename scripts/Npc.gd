extends CharacterBody2D
class_name NpcAgent

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var avoidance_range: Area2D = $AvoidanceRange

@export var move_speed: float = 100.0
@export var avoidance_strength: float = 23

var char_name: String
var current_task: Task = null
var npcs_in_avoidance_range: Array[NpcAgent] = []
var is_moving_to_task: bool = false

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			print(self.char_name, " killed!")
		
		if event.button_index == 2:
			print(self.char_name, " cleared!")


func assign_task(task: Task):
	if task == null:
		current_task = null
		is_moving_to_task = false
	else:
		current_task = task
		is_moving_to_task = true


func _physics_process(_delta):
	if current_task and is_moving_to_task:
		move_to_task()


func move_to_task():
	var sep_dist_x: float = 0.0
	var sep_dist_y: float = 0.0

	for npc in npcs_in_avoidance_range:
		var dist_vector = position - npc.position
		var distance = dist_vector.length()
		if distance > 0:
			var normalized_dist = dist_vector.normalized()
			sep_dist_x += normalized_dist.x / distance
			sep_dist_y += normalized_dist.y / distance

	var separation_force = Vector2(sep_dist_x, sep_dist_y) * avoidance_strength

	var task_direction = (current_task.position - position).normalized()

	velocity = (task_direction + separation_force).normalized() * move_speed

	if position.distance_to(current_task.position) <= current_task.radius:
		velocity = Vector2.ZERO
		is_moving_to_task = false
		current_task.start_task()

	move_and_slide()


func _on_avoidance_range_body_entered(body: Node2D) -> void:
	if body is NpcAgent and body != self:
		npcs_in_avoidance_range.append(body)


func _on_avoidance_range_body_exited(body: Node2D) -> void:
	if body is NpcAgent:
		npcs_in_avoidance_range.erase(body)
