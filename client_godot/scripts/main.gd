extends Node2D

## Controlador Central de la Escena Principal (Neighborhood AI)
## Gestiona:
## 1. Visualización del mapa de alta definición (neighborhood_map_480.png).
## 2. Instanciación, sincronización e interactividad táctil/mouse de los 6 agentes.
## 3. Interactividad con el entorno y las 6 viviendas.
## 4. Control de cámara (arrastre, pellizco, límites y centrado suave).
## 5. Coordinación con HUDMain y el ciclo día/noche.

const AGENT_SCENE = preload("res://scenes/agent_node.tscn")
const HOUSE_LOCATION_PREFIX: String = "casa_"

# Coordenadas 2D de las locaciones del barrio (viewport 960x540 = 2x de 480x270)
const LOCATIONS: Dictionary = {
	"plaza": Vector2(480, 270),
	"manantial": Vector2(420, 240),
	"huerto": Vector2(200, 200),
	"comisaria": Vector2(780, 140),
	"dispensario": Vector2(780, 400),
	"casa_1": Vector2(140, 140),    # Casa del Huerto (Mateo Rossi)
	"casa_2": Vector2(140, 380),   # Casa del Manantial (Sofía Benítez)
	"casa_3": Vector2(780, 400),  # Dispensario y Residencia Médica (Lucas Morales)
	"casa_4": Vector2(340, 100),   # Taller del Constructor (Diego Navarro)
	"casa_5": Vector2(780, 140),   # Puesto Policial (Valeria Castro)
	"casa_6": Vector2(620, 100),   # Casa Comunal del Político (Camila Méndez)
}

const LOCATION_DETAILS: Dictionary = {
	"casa_1": {
		"name": "Casa 1: Casa del Huerto",
		"resident": "Mateo Rossi (Proveedor de alimentos)",
		"storage": "Manzanas, pan, semillas y cajas de cosecha."
	},
	"casa_2": {
		"name": "Casa 2: Casa del Manantial",
		"resident": "Sofía Benítez (Proveedor de agua)",
		"storage": "Bidones de agua potable, filtros y recipientes."
	},
	"casa_3": {
		"name": "Casa 3: Dispensario y Residencia Médica",
		"resident": "Lucas Morales (Médico)",
		"storage": "Botiquines, vendas, analgésicos y desinfectante."
	},
	"casa_4": {
		"name": "Casa 4: Taller y Vivienda del Constructor",
		"resident": "Diego Navarro (Constructor)",
		"storage": "Tablones, vigas, herramientas de albañilería y clavos."
	},
	"casa_5": {
		"name": "Casa 5: Puesto y Residencia Policial",
		"resident": "Valeria Castro (Policía)",
		"storage": "Libro de actas, esposas, linterna y silbato de alerta."
	},
	"casa_6": {
		"name": "Casa 6: Casa Comunal del Representante",
		"resident": "Camila Méndez (Político)",
		"storage": "Libros de ordenanzas, actas de asamblea y urna de votos."
	},
	"plaza": {
		"name": "Plaza Mayor y Fuente Central",
		"resident": "Espacio público y asambleario de la comunidad",
		"storage": "Bancos de madera, farolas de hierro y agua de la fuente."
	},
	"huerto": {
		"name": "Huerto Comunitario",
		"resident": "Área de cultivo comunal a cargo de Mateo Rossi",
		"storage": "Surcos de hortalizas, verduras frescas y frutales."
	},
	"manantial": {
		"name": "Manantial Natural de Vertiente",
		"resident": "Fuente natural de agua potable a cargo de Sofía Benítez",
		"storage": "Agua pura de manantial para abastecimiento de todo el barrio."
	}
}

@onready var characters_container: Node2D = get_node_or_null("World/Characters")
@onready var interactive_locations: Node2D = get_node_or_null("World/InteractiveLocations")
@onready var camera: Camera2D = get_node_or_null("Camera2D")
@onready var hud: CanvasLayer = get_node_or_null("HUDMain")

var agent_nodes: Dictionary = {}
var house_numbers: Dictionary = {}
var last_characters_snapshot: Array = []
var selected_agent_id: String = ""

# Control de Cámara Touch / Mouse
var is_dragging_camera: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_start_cam_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	var sync_node = get_node_or_null("/root/WorldSync")
	if sync_node:
		sync_node.characters_updated.connect(_on_characters_updated)
		sync_node.houses_updated.connect(_on_houses_updated)
		sync_node.request_full_sync()

	if hud:
		hud.focus_camera_requested.connect(_on_focus_camera_requested)

	_setup_location_click_areas()


func _setup_location_click_areas() -> void:
	if interactive_locations == null:
		return
	for child in interactive_locations.get_children():
		if child is Area2D:
			child.input_event.connect(_on_location_input_event.bind(String(child.name).to_lower()))


func _on_location_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, loc_name: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_location_selected(loc_name)
	elif event is InputEventScreenTouch and event.pressed:
		_on_location_selected(loc_name)


func _on_location_selected(loc_key: String) -> void:
	# Quitar selección de agentes
	for id in agent_nodes.keys():
		agent_nodes[id].set_selected(false)
	selected_agent_id = ""

	if hud and LOCATION_DETAILS.has(loc_key):
		var d = LOCATION_DETAILS[loc_key]
		hud.open_location_inspector(loc_key, d["name"], d["resident"], d["storage"])


func _on_agent_clicked(char_id: String) -> void:
	selected_agent_id = char_id
	for id in agent_nodes.keys():
		agent_nodes[id].set_selected(id == char_id)
	if hud and agent_nodes.has(char_id):
		hud.open_character_inspector(agent_nodes[char_id].raw_data)


func _on_focus_camera_requested(agent_id: String) -> void:
	if camera and agent_nodes.has(agent_id):
		var target_pos: Vector2 = agent_nodes[agent_id].global_position
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(camera, "position", target_pos, 0.35)


func _on_houses_updated(houses: Array) -> void:
	house_numbers.clear()
	for house in houses:
		if not (house is Dictionary):
			continue
		var house_id: String = String(house.get("id", ""))
		var number: int = int(house.get("house_number", 0))
		if not house_id.is_empty() and number > 0:
			house_numbers[house_id] = number
	if not last_characters_snapshot.is_empty():
		_apply_characters(last_characters_snapshot)


func _on_characters_updated(characters: Array) -> void:
	last_characters_snapshot = characters
	_apply_characters(characters)


func _apply_characters(characters: Array) -> void:
	if characters_container == null:
		return
	for char_data in characters:
		if not (char_data is Dictionary):
			continue
		var char_id: String = String(char_data.get("id", ""))
		if char_id.is_empty():
			continue
		var target_coords: Vector2 = resolve_location(String(char_data.get("current_location", "plaza")))

		# Pequeño offset de dispersión inicial para que no se superpongan
		var seed_offset := Vector2(
			(hash(char_id) % 20) - 10,
			((hash(char_id) / 20) % 16) - 8
		)
		target_coords += seed_offset

		if not agent_nodes.has(char_id):
			var agent_inst = AGENT_SCENE.instantiate()
			characters_container.add_child(agent_inst)
			agent_inst.initialize(char_data, target_coords)
			agent_inst.agent_clicked.connect(_on_agent_clicked)
			agent_nodes[char_id] = agent_inst
		else:
			agent_nodes[char_id].update_state(char_data, target_coords)


func resolve_location(location_name: String) -> Vector2:
	if location_name.is_empty():
		return LOCATIONS["plaza"]
	if LOCATIONS.has(location_name):
		return LOCATIONS[location_name]
	if location_name.begins_with(HOUSE_LOCATION_PREFIX):
		var house_id: String = location_name.substr(HOUSE_LOCATION_PREFIX.length())
		if house_numbers.has(house_id):
			var key := "casa_%d" % int(house_numbers[house_id])
			if LOCATIONS.has(key):
				return LOCATIONS[key]
	return LOCATIONS["plaza"]


# ----------------------------- Controles de Cámara -----------------------------

func _input(event: InputEvent) -> void:
	if camera == null:
		return

	# Si hay un modal abierto y el toque es en el centro, dejar que la UI lo consuma
	if hud and hud.is_any_modal_open():
		if event is InputEventMouseButton and event.pressed:
			# Si el clic no fue dentro del modal, cerramos
			pass

	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging_camera = true
			drag_start_mouse_pos = event.position
			drag_start_cam_pos = camera.position
		else:
			is_dragging_camera = false
		return

	if event is InputEventScreenDrag:
		camera.position -= event.relative / camera.zoom
		_clamp_camera()
		return

	if event is InputEventMagnifyGesture:
		camera.zoom = (camera.zoom * event.factor).clamp(Vector2(0.85, 0.85), Vector2(3.0, 3.0))
		return

	if event is InputEventPanGesture:
		camera.position -= event.delta * 10.0 / camera.zoom
		_clamp_camera()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging_camera = true
				drag_start_mouse_pos = event.position
				drag_start_cam_pos = camera.position
			else:
				is_dragging_camera = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = (camera.zoom * 1.1).clamp(Vector2(0.85, 0.85), Vector2(3.0, 3.0))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = (camera.zoom * 0.9).clamp(Vector2(0.85, 0.85), Vector2(3.0, 3.0))

	elif event is InputEventMouseMotion and is_dragging_camera:
		var diff: Vector2 = (event.position - drag_start_mouse_pos) / camera.zoom
		camera.position = drag_start_cam_pos - diff
		_clamp_camera()


func _clamp_camera() -> void:
	if camera:
		camera.position.x = clampf(camera.position.x, 160.0, 800.0)
		camera.position.y = clampf(camera.position.y, 90.0, 450.0)
