extends Node2D

## Ambient particle effects for day/night atmosphere

@export var emitting: bool = true

func _ready() -> void:
	# Configure particles based on time of day
	pass

func set_time_of_day(hour: int) -> void:
	# Adjust particle visibility and colors based on time
	if hour >= 20 or hour < 6:
		# Night time - show firefly-like particles
		visible = true
		modulate = Color(1.0, 1.0, 0.7, 0.6)
	elif hour >= 6 and hour < 8:
		# Dawn - subtle morning mist
		visible = true
		modulate = Color(1.0, 0.95, 0.85, 0.3)
	else:
		# Daytime - minimal particles
		visible = false

