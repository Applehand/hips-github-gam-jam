extends NpcAgent
class_name Imposter

var is_imposter: bool = true


func _ready() -> void:
	label.text = "Imposter!"


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			print("Imposter has been killed!")
