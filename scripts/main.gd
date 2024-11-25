extends Node2D

var character_names = [
	"Arden",
	"Allyn",
	"Blythe",
	"Cira",
	"Anya",
	"Valyn",
	"Kael",
	"Lyric",
	"Eris",
	"Soren",
	"Elyse",
	"Lily",
	"Ilyra",
	"Auric",
	"Finnian",
	"Veya",
	"Thorne",
	"Selis",
	"Alaric",
	"Nimra",
	"Kieran",
	"Elowen",
	"Aurelia",
	"Draven",
	"Mireya",
	"Talon",
	"Sylas",
	"Zara",
	"Brenna"
]

@onready var start_button: Button = $CanvasLayer/Control/Button

@export var num_npcs: int = 5
@export var num_tasks: int = 8
@export var task_spawn_margin = 35
@export var task_spawn_min_distance = 75

var tasks: Array[Task] = []
var npcs: Array[NpcAgent] = []
var viewport_rect: Vector2

@onready var npc_scene: PackedScene = preload("res://scenes/npc_agent.tscn")
@onready var task_scene: PackedScene = preload("res://scenes/task.tscn")


func _ready() -> void:
	viewport_rect = get_viewport_rect().size


func start_game() -> void:
	start_button.visible = false
	spawn_tasks(num_tasks)
	spawn_npcs()


func _on_button_pressed() -> void:
	start_game()


func spawn_npcs() -> void:
	for i in range(num_npcs):
		var npc: NpcAgent = npc_scene.instantiate()
		npc.current_task = tasks.pick_random()
		
		var random_index = randi() % character_names.size()
		var assigned_name = character_names.pop_at(random_index)
		npc.char_name = assigned_name
		npc.get_node("Label").text = assigned_name
		
		var npc_spawn_pos := Vector2(
			randi() % int(viewport_rect.x - 10),
			randi() % int(viewport_rect.y)
		)
		npc.position = npc_spawn_pos
		
		npcs.append(npc)
		add_child(npc)
		assign_task_to_npc(npc)


func spawn_tasks(count: int = 1):
	for i in range(count):
		var task = task_scene.instantiate()
		var task_spawn_pos: Vector2
		var valid_position = false

		while not valid_position:
			task_spawn_pos = Vector2(
				task_spawn_margin + randi() % int(viewport_rect.x - 2 * task_spawn_margin),
				task_spawn_margin + randi() % int(viewport_rect.y - 2 * task_spawn_margin)
			)

			valid_position = true
			for existing_task in tasks:
				if task_spawn_pos.distance_to(existing_task.position) < task_spawn_min_distance:
					valid_position = false
					break

		task.position = task_spawn_pos
		tasks.append(task)
		add_child(task)



func assign_task_to_npc(npc: NpcAgent):
	for task in tasks:
		if not task.is_completed and not task.is_in_progress:
			npc.assign_task(task)
			task.is_in_progress = true
			task.connect("task_completed", _on_task_completed)
			break


func _on_task_completed(task: Task):
	tasks.erase(task)
	task.queue_free()

	spawn_tasks(1)

	for npc in npcs:
		if npc.current_task == task:
			assign_task_to_npc(npc)
