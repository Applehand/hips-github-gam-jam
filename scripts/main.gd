extends Node2D

var all_character_names = [
	"Arden", "Allyn", "Blythe", "Cira", "Anya", "Valyn", "Kael", "Lyric",
	"Eris", "Soren", "Elyse", "Lily", "Ilyra", "Auric", "Finnian", "Veya",
	"Thorne", "Selis", "Alaric", "Nimra", "Kieran", "Elowen", "Aurelia",
	"Draven", "Mireya", "Talon", "Sylas", "Zara", "Brenna"
]

var available_character_names = []

var textures = [
	"res://assets/Sprites/NPCsprites/NPCblue.png",
	"res://assets/Sprites/NPCsprites/NPCdarkblue.png",
	"res://assets/Sprites/NPCsprites/NPCdarkpurple.png", 
	"res://assets/Sprites/NPCsprites/NPCgreen.png",
	"res://assets/Sprites/NPCsprites/NPClightblue.png",
	"res://assets/Sprites/NPCsprites/NPClightgreen.png",
	"res://assets/Sprites/NPCsprites/NPClightgrey.png",
	"res://assets/Sprites/NPCsprites/NPClightpink.png",
	"res://assets/Sprites/NPCsprites/NPClightred.png",
	"res://assets/Sprites/NPCsprites/NPCorange.png",
	"res://assets/Sprites/NPCsprites/NPCred.png",
	"res://assets/Sprites/NPCsprites/NPCtan.png"
]

var available_textures = []

@onready var start_button: Button = $CanvasLayer/Control/Button
@onready var game_timer: Timer = $GameTimer
@onready var game_timer_label: Label = $CanvasLayer/Control/GameTimerLabel

@export var game_time_limit: float = 15.0
@export var num_npcs: int = 5
@export var num_tasks: int = 8
@export var task_spawn_margin = 35
@export var task_spawn_min_distance = 75
@export var num_textures = 12

var tasks: Array[Task] = []
var npcs: Array[NpcAgent] = []
var viewport_rect: Vector2

@onready var npc_scene: PackedScene = preload("res://scenes/npc_agent.tscn")
@onready var task_scene: PackedScene = preload("res://scenes/task.tscn")
@onready var imposter_scene: PackedScene = preload("res://scenes/imposter.tscn")


func _ready() -> void:
	game_timer.wait_time = game_time_limit
	viewport_rect = get_viewport_rect().size
	reset_available_character_names()
	available_textures = textures.duplicate()

func reset_available_character_names() -> void:
	available_character_names = all_character_names.duplicate()


func start_game() -> void:
	start_button.visible = false
	spawn_tasks(num_tasks)
	spawn_npcs()
	game_timer.start()


func _on_button_pressed() -> void:
	start_game()


func spawn_npcs() -> void:
	var imposter_index = randi() % num_npcs
	
	for i in range(num_npcs):
		var npc: NpcAgent
		if i == imposter_index:
			npc = imposter_scene.instantiate()
		else:
			npc = npc_scene.instantiate()
		npc.current_task = tasks.pick_random()

		if available_character_names.size() > 0:
			var random_index = randi() % available_character_names.size()
			var assigned_name = available_character_names.pop_at(random_index)
			npc.char_name = assigned_name
			npc.get_node("Label").text = assigned_name

		if available_textures.size() > 0:
			var texture_index = randi() % available_textures.size()
			var texture_path = available_textures[texture_index]
			var texture = load(texture_path)
			
			var sprite = npc.get_node("Sprite2D")
			if sprite:
				sprite.texture = texture

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

		task.task_type = "food" if randi() % 2 == 0 else "conversation"

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

		print("Spawned task of type: ", task.task_type, " at position: ", task.position)


func assign_task_to_npc(npc: NpcAgent):
	for task in tasks:
		if task.task_type == "conversation" and not task.is_completed and task.participants.size() == 1:
			npc.assign_task(task)
			if task.participants.size() == 2:
				task.is_in_progress = true
				task.connect("task_completed", _on_task_completed)
			return

	for task in tasks:
		if task.task_type == "food" and not task.is_completed and task.participants.size() == 0:
			npc.assign_task(task)
			task.is_in_progress = true
			task.connect("task_completed", _on_task_completed)
			return
		elif task.task_type == "conversation" and not task.is_completed and task.participants.size() < 2:
			npc.assign_task(task)
			if task.participants.size() == 2:
				task.is_in_progress = true
				task.connect("task_completed", _on_task_completed)
			return


func _on_task_completed(task: Task):
	tasks.erase(task)
	task.queue_free()

	spawn_tasks(1)

	for npc in npcs:
		if npc.current_task == task:
			assign_task_to_npc(npc)


func _on_game_timer_timeout() -> void:
	start_button.visible = true
	game_timer.stop()

	for npc in npcs:
		npc.queue_free()
	npcs.clear()

	for task in tasks:
		task.queue_free()
	tasks.clear()

	reset_available_character_names()

func _process(_delta: float) -> void:
	if game_timer.is_stopped():
		game_timer_label.text = "FIND THE IMPOSTER!"
	else:
		game_timer_label.text = "Time Left: " + str(int(game_timer.time_left))
