extends CanvasLayer

## Controlador del HUD Principal y Métricas de Neighborhood AI
## - Muestra el reloj oficial de Buenos Aires (Argentina, UTC-3) y fase día/noche.
## - Muestra métricas comunitarias rápidas (población viva, economía circulante, alertas, leyes).
## - Gestiona los modales de inspección interactiva de habitantes y edificios.

signal focus_camera_requested(agent_id: String)
signal modal_visibility_changed(is_open: bool)

@onready var time_label: Label = $TopBar/HBox/ClockContainer/TimeLabel
@onready var clock_icon: Label = $TopBar/HBox/ClockContainer/ClockIcon
@onready var pop_label: Label = $TopBar/HBox/MetricsContainer/PopPill/PopLabel
@onready var eco_label: Label = $TopBar/HBox/MetricsContainer/EcoPill/EcoLabel
@onready var laws_label: Label = $TopBar/HBox/MetricsContainer/LawsPill/LawsLabel
@onready var alert_label: Label = $TopBar/HBox/MetricsContainer/AlertPill/AlertLabel
@onready var status_label: Label = $TopBar/HBox/RightContainer/StatusLabel
@onready var btn_metrics: Button = $TopBar/HBox/RightContainer/BtnMetrics

# Modales
@onready var char_modal: PanelContainer = $CharacterInspectorModal
@onready var char_name: Label = $CharacterInspectorModal/VBox/HeaderHBox/NameTitle
@onready var char_role: Label = $CharacterInspectorModal/VBox/HeaderHBox/RoleBadge
@onready var bar_energy: ProgressBar = $CharacterInspectorModal/VBox/VitalsGrid/EnergyBarBox/EnergyBar
@onready var bar_health: ProgressBar = $CharacterInspectorModal/VBox/VitalsGrid/HealthBarBox/HealthBar
@onready var bar_hunger: ProgressBar = $CharacterInspectorModal/VBox/VitalsGrid/HungerBarBox/HungerBar
@onready var bar_thirst: ProgressBar = $CharacterInspectorModal/VBox/VitalsGrid/ThirstBarBox/ThirstBar
@onready var char_money: Label = $CharacterInspectorModal/VBox/EcoLocHBox/MoneyLabel
@onready var char_loc: Label = $CharacterInspectorModal/VBox/EcoLocHBox/LocLabel
@onready var char_thought: Label = $CharacterInspectorModal/VBox/ThoughtBox/ThoughtText
@onready var char_inv: Label = $CharacterInspectorModal/VBox/InvBox/InvLabel
@onready var btn_close_char: Button = $CharacterInspectorModal/VBox/HeaderHBox/BtnCloseChar
@onready var btn_focus_cam: Button = $CharacterInspectorModal/VBox/FooterHBox/BtnFocusCam

@onready var loc_modal: PanelContainer = $LocationInspectorModal
@onready var loc_title: Label = $LocationInspectorModal/VBox/Header/LocTitle
@onready var loc_resident: Label = $LocationInspectorModal/VBox/LocResident
@onready var loc_integrity: Label = $LocationInspectorModal/VBox/LocIntegrity
@onready var loc_storage: Label = $LocationInspectorModal/VBox/LocStorage
@onready var loc_present: Label = $LocationInspectorModal/VBox/LocPresent
@onready var btn_close_loc: Button = $LocationInspectorModal/VBox/Header/BtnCloseLoc

@onready var comm_modal: PanelContainer = $CommunityMetricsModal
@onready var btn_close_comm: Button = $CommunityMetricsModal/VBox/Header/BtnCloseMetrics

var is_connected: bool = false
var selected_char_id: String = ""
var last_characters: Array = []
var last_houses: Array = []
var last_laws: Array = []

func _ready() -> void:
	btn_metrics.pressed.connect(_on_btn_metrics_pressed)
	btn_close_char.pressed.connect(close_all_modals)
	btn_close_loc.pressed.connect(close_all_modals)
	btn_close_comm.pressed.connect(close_all_modals)
	btn_focus_cam.pressed.connect(_on_focus_camera_pressed)

	var sync_node = get_node_or_null("/root/WorldSync")
	if sync_node:
		sync_node.world_clock_updated.connect(_on_clock_updated)
		sync_node.sync_status_changed.connect(_on_sync_status_changed)
		sync_node.events_updated.connect(_on_events_updated)
		sync_node.characters_updated.connect(_on_characters_updated)
		sync_node.houses_updated.connect(_on_houses_updated)
		_on_sync_status_changed(sync_node.is_connected)


func _on_clock_updated(data: Dictionary) -> void:
	var time_str: String = String(data.get("formatted_time", ""))
	if time_str.is_empty():
		time_str = String(data.get("local_time_argentina", ""))
		if time_str.contains("T"):
			time_str = time_str.get_slice("T", 1).substr(0, 8)
	if time_str.is_empty():
		time_str = "--:--:--"

	var is_day: bool = bool(data.get("is_day", data.get("phase", "day") == "day"))
	clock_icon.text = "☀️" if is_day else "🌙"
	time_label.text = "Buenos Aires: %s (%s)" % [time_str, "DÍA" if is_day else "NOCHE"]


func _on_sync_status_changed(connected: bool) -> void:
	is_connected = connected
	if status_label:
		status_label.text = "🟢 En línea" if connected else "🔴 Sin conexión"
		status_label.modulate = Color(0.65, 1.0, 0.65) if connected else Color(1.0, 0.45, 0.45)


func _on_characters_updated(characters: Array) -> void:
	last_characters = characters
	var total_money: float = 0.0
	var alive_count: int = 0
	for c in characters:
		if not (c is Dictionary):
			continue
		if bool(c.get("is_alive", true)):
			alive_count += 1
		total_money += float(c.get("money", 0.0))

	pop_label.text = "👥 %d/%d Vivos" % [alive_count, characters.size()]
	eco_label.text = "💰 $%d" % int(total_money)

	# Si el modal de personaje está abierto y es el personaje seleccionado, actualizarlo en vivo
	if char_modal.visible and not selected_char_id.is_empty():
		for c in characters:
			if String(c.get("id", "")) == selected_char_id:
				_populate_character_modal(c)
				break


func _on_houses_updated(houses: Array) -> void:
	last_houses = houses


func _on_events_updated(events: Array) -> void:
	var active_events: Array = []
	for ev in events:
		if ev.get("status") in ["active", "escalating", "detected"]:
			active_events.append(String(ev.get("event_type", "")).to_upper())

	if active_events.is_empty():
		alert_label.text = "🕊️ Calma"
		alert_label.modulate = Color(0.7, 1.0, 0.7)
	else:
		alert_label.text = "🚨 " + active_events[0]
		alert_label.modulate = Color(1.0, 0.35, 0.35)


# ----------------------------- Modales de Inspección -----------------------------

func open_character_inspector(char_data: Dictionary) -> void:
	close_all_modals()
	selected_char_id = String(char_data.get("id", ""))
	_populate_character_modal(char_data)
	char_modal.visible = true
	modal_visibility_changed.emit(true)


func _populate_character_modal(c: Dictionary) -> void:
	char_name.text = String(c.get("name", "Habitante"))
	var age: int = int(c.get("age", 30))
	var gen: String = String(c.get("gender", "masculino"))
	var prof: String = String(c.get("profession", "Vecino"))
	char_role.text = "%s • %d años • %s" % [prof, age, gen.capitalize()]

	bar_energy.value = float(c.get("energy", 100.0))
	bar_health.value = float(c.get("health", 100.0))
	bar_hunger.value = float(c.get("hunger", 0.0))
	bar_thirst.value = float(c.get("thirst", 0.0))

	char_money.text = "💵 Fondos: $%.2f" % float(c.get("money", 0.0))
	char_loc.text = "📍 Ubicación: %s" % String(c.get("current_location", "plaza"))

	var inv: Dictionary = c.get("inventory", {})
	if inv.is_empty():
		char_inv.text = "🎒 Inventario: Vacío"
	else:
		var items: Array = []
		for k in inv.keys():
			items.append("%s: %s" % [String(k).capitalize(), str(inv[k])])
		char_inv.text = "🎒 Inventario: " + ", ".join(items)

	# Mostrar únicamente contenido respaldado por el payload del servidor.
	var thought: String = String(c.get("thought", c.get("current_thought", c.get("last_reasoning", ""))))
	if thought.is_empty():
		thought = "No disponible en los datos sincronizados."
	char_thought.text = "🧠 Pensamiento: %s" % thought


func open_location_inspector(loc_key: String, loc_name: String, resident_info: String, storage_info: String) -> void:
	close_all_modals()
	loc_title.text = loc_name
	loc_resident.text = "👤 Residentes: " + resident_info
	loc_integrity.text = "🏗️ Integridad estructural: no disponible"
	loc_storage.text = "📦 Recursos disponibles: " + storage_info

	# Normalizar casa_<UUID> del backend a casa_<número> para el inspector.
	var present: Array = []
	for character in last_characters:
		var raw_location: String = String(character.get("current_location", ""))
		if _resolve_inspector_location(raw_location) == loc_key:
			present.append(String(character.get("name", "")))

	if present.is_empty():
		loc_present.text = "📍 Presentes ahora: Ningún habitante en este instante"
	else:
		loc_present.text = "📍 Presentes ahora: " + ", ".join(present)

	loc_modal.visible = true
	modal_visibility_changed.emit(true)


func _resolve_inspector_location(raw_location: String) -> String:
	if not raw_location.begins_with("casa_"):
		return raw_location

	var house_id: String = raw_location.substr("casa_".length())
	for house in last_houses:
		if not (house is Dictionary):
			continue
		if String(house.get("id", "")) == house_id:
			var house_number: int = int(house.get("house_number", 0))
			if house_number > 0:
				return "casa_%d" % house_number
	return raw_location


func _on_btn_metrics_pressed() -> void:
	if comm_modal.visible:
		comm_modal.visible = false
		modal_visibility_changed.emit(false)
	else:
		close_all_modals()
		comm_modal.visible = true
		modal_visibility_changed.emit(true)


func close_all_modals() -> void:
	char_modal.visible = false
	loc_modal.visible = false
	comm_modal.visible = false
	modal_visibility_changed.emit(false)


func is_any_modal_open() -> bool:
	return char_modal.visible or loc_modal.visible or comm_modal.visible


func _on_focus_camera_pressed() -> void:
	if not selected_char_id.is_empty():
		focus_camera_requested.emit(selected_char_id)
		close_all_modals()
