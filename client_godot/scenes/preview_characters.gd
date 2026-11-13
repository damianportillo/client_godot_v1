extends Node2D

## Preview de los 6 personajes (FASE 2). Escena de debug: instancia un
## AgentNode por profesión sobre un fondo de césped y los anima en más o menos
## lugar para verificar spritesheets y animaciones sin depender del backend.

const CHARS := [
	{"profession": "Proveedor de alimentos", "name": "Mateo Rossi"},
	{"profession": "Proveedor de agua", "name": "Sofía Benítez"},
	{"profession": "Médico", "name": "Lucas Morales"},
	{"profession": "Constructor", "name": "Diego Navarro"},
	{"profession": "Policía", "name": "Valeria Castro"},
	{"profession": "Político", "name": "Camila Méndez"},
]

const AGENT_SCENE := preload("res://scenes/agent_node.tscn")


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.47, 0.74, 0.31)
	bg.size = Vector2(480, 270)
	add_child(bg)
	var sep := HSeparator.new()
	sep.position = Vector2(0, 135)
	add_child(sep)
	var i := 0
	for ch in CHARS:
		var a := AGENT_SCENE.instantiate()
		a.initialize({
			"id": "preview_%d" % i,
			"name": ch["name"],
			"profession": ch["profession"],
			"current_location": "plaza",
			"energy": 90, "hunger": 10, "thirst": 10, "health": 100,
		}, Vector2(50 + i * 70, 90))
		add_child(a)
		# alternando: mitad caminando, mitad idle en su lugar
		if i % 2 == 0:
			a.target_position = Vector2(50 + i * 70 + 44, 90)
		i += 1
