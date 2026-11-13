extends Node2D

## Preview conceptual de iluminación (FASE 3): instancia el mapa real y fuerza
## la hora con la variable de entorno PREVIEW_HOUR (día=13, atardecer=19, noche=22).
## Solo para capturas/debug; no altera backend ni WorldSync.

var main_scene: PackedScene = load("res://scenes/main.tscn")


func _ready() -> void:
	var inst := main_scene.instantiate()
	inst.name = "Main"
	add_child(inst)


func _process(_delta: float) -> void:
	var hour := float(OS.get_environment("PREVIEW_HOUR") if OS.get_environment("PREVIEW_HOUR") != "" else "13")
	var dc := get_tree().current_scene.get_node_or_null("Main/DayNightCycle")
	if dc == null:
		dc = get_child(0).get_node_or_null("DayNightCycle")
	if dc:
		dc.current_hour_float = hour
		dc._apply_lighting()
