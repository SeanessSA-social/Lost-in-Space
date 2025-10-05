extends Area2D

@export var show_once := true
var _shown := false

func _ready() -> void:
	print("[Proximity] READY on ", name, " layers=", collision_layer, " mask=", collision_mask)
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(other: Area2D) -> void:
	print("[Proximity] area_entered by: ", other.name, " groups=", other.get_groups())
	if _shown and show_once:
		return

	# Accept either the ship root or a hurtbox child tagged 'player'
	if other.is_in_group("player") or other.name == "Spaceship":
		var dlg := load("res://Dialogue/planet_warning.dialogue")
		if dlg:
			var balloon := DialogueManager.show_dialogue_balloon(dlg, "start")
			#if balloon:
				#balloon.global_position = other.global_position + Vector2(0, -96)
		_shown = true
