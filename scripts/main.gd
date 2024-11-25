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


@export var num_npcs: int = 5
@export var num_tasks: int = 8

var tasks: Array[Task]
var npcs: Array[NpcAgent]

var npc_scene: PackedScene = preload("res://scenes/npc_agent.tscn")
var task_scene: PackedScene = preload("res://scenes/task.tscn")


func _ready() -> void:
	var viewport_rect = get_viewport_rect().size
	spawn_tasks(viewport_rect)


func start_game():
	var viewport_rect = get_viewport_rect().size
	spawn_npcs(viewport_rect)


func _on_button_pressed() -> void:
	start_game()


func spawn_npcs(viewport_rect: Vector2):
	for i in range(num_npcs):
		var npc: NpcAgent = npc_scene.instantiate()
		npc.current_task = tasks.pick_random()
		
		var random_index = randi() % character_names.size()
		var assigned_name = character_names.pop_at(random_index)
		npc.char_name = assigned_name
		npc.get_node("Label").text = assigned_name
		
		npcs.append(npc)
		add_child(npc)
		
		var npc_spawn_pos := Vector2(
			randi() % int(viewport_rect.x - 10),
			randi() % int(viewport_rect.y)
		)
		npc.position = npc_spawn_pos


func spawn_tasks(viewport_rect: Vector2):
	var margin = 35
	var min_distance = 75

	for i in range(num_tasks):
		var task = task_scene.instantiate()
		var task_spawn_pos: Vector2
		var valid_position = false

		while not valid_position:
			task_spawn_pos = Vector2(
				margin + randi() % int(viewport_rect.x - 2 * margin),
				margin + randi() % int(viewport_rect.y - 2 * margin)
			)

			valid_position = true
			for existing_task in tasks:
				if task_spawn_pos.distance_to(existing_task.position) < min_distance:
					valid_position = false
					break

		task.position = task_spawn_pos
		tasks.append(task)
		add_child(task)
