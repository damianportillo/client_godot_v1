extends CanvasLayer

## FASE 4: Rediseño del HUD
## Implementación de un HUD moderno y más intuitivo para la experiencia del usuario

@onready var time_label: Label = $TopBar/TimeContainer/TimeLabel
@onready var status_label: Label = $TopBar/StatusContainer/StatusLabel
@onready var status_icon: TextureRect = $TopBar/StatusContainer/StatusIcon
@onready var events_label: Label = $TopBar/EventsContainer/EventsLabel
@onready var agent_name_label: Label = $BottomBar/AgentInfoContainer/AgentNameLabel
@onready var agent_profession_label: Label = $BottomBar/AgentInfoContainer/AgentProfessionLabel
@onready var agent_status_label: Label = $BottomBar/AgentInfoContainer/AgentStatusLabel

var is_connected: bool = false
var selected_agent_id: String = ""

func _ready() -> void:
	# Set up the HUD layout and styling
	_update_theme()
	
	# Connect to the world sync node for updates
	var sync_node = get_node_or_null("/root/WorldSync")
	if sync_node:
		sync_node.world_clock_updated.connect(_on_clock_updated)
		sync_node.sync_status_changed.connect(_on_sync_status_changed)
		sync_node.events_updated.connect(_on_events_updated)
	
	# Initialize with default values
	_update_time_label()
	_update_status_label()
	_update_events_label()

func _update_theme() -> void:
	# Apply modern theme styling
	var theme = Theme.new()
	
	# Set up font and colors for the HUD
	var time_font = preload("res://assets/fonts/roboto_bold.ttf")
	var status_font = preload("res://assets/fonts/roboto_regular.ttf")
	
	# Configure label styles
	time_label.add_theme_font_override("font", time_font)
	time_label.add_theme_font_size_override("font_size", 20)
	
	status_label.add_theme_font_override("font", status_font)
	status_label.add_theme_font_size_override("font_size", 16)
	
	events_label.add_theme_font_override("font", status_font)
	events_label.add_theme_font_size_override("font_size", 14)
	
	agent_name_label.add_theme_font_override("font", time_font)
	agent_name_label.add_theme_font_size_override("font_size", 18)
	
	agent_profession_label.add_theme_font_override("font", status_font)
	agent_profession_label.add_theme_font_size_override("font_size", 14)
	
	agent_status_label.add_theme_font_override("font", status_font)
	agent_status_label.add_theme_font_size_override("font_size", 12)

func _on_clock_updated(clock_data: Dictionary) -> void:
	_update_time_label(clock_data)

func _update_time_label(clock_data: Dictionary = {}) -> void:
	if clock_data.is_empty():
		# Default time format
		time_label.text = "06:00"
	else:
		var hour = clock_data.get("hour", 0)
		var minute = clock_data.get("minute", 0)
		time_label.text = "%02d:%02d" % [hour, minute]

func _on_sync_status_changed(is_connected: bool) -> void:
	self.is_connected = is_connected
	_update_status_label()

func _update_status_label() -> void:
	status_label.text = "Conectado" if is_connected else "Desconectado"
	status_icon.texture = preload("res://assets/icons/%s.png" % ("connected" if is_connected else "disconnected"))

func _on_events_updated(events: Array) -> void:
	_update_events_label(events)

func _update_events_label(events: Array = []) -> void:
	if events.size() > 0:
		var event_text = ""
		for i in range(min(3, events.size())):
			event_text += "%s\n" % events[i].get("description", "")
		events_label.text = event_text.trim_suffix("\n")
	else:
		events_label.text = "No hay eventos activos"

func _on_agent_selected(agent_id: String) -> void:
	selected_agent_id = agent_id
	# Load agent details and update the HUD
	var agent_data = _get_agent_data(agent_id)
	if agent_data:
		agent_name_label.text = agent_data.get("name", "Desconocido")
		agent_profession_label.text = agent_data.get("profession", "Sin profesión")
		agent_status_label.text = agent_data.get("status", "Normal")

func _get_agent_data(agent_id: String) -> Dictionary:
	# This would typically fetch data from the backend
	# For now, we'll simulate it with predefined data
	var agents_data = {
		"agent_1": {"name": "Mateo Rossi", "profession": "Huertero", "status": "Trabajando"},
		"agent_2": {"name": "Sofía Benítez", "profession": "Bibliotecaria", "status": "Descansando"},
		"agent_3": {"name": "Lucas Morales", "profession": "Médico", "status": "Atendiendo"},
		"agent_4": {"name": "Diego Navarro", "profession": "Constructor", "status": "Construyendo"},
		"agent_5": {"name": "Valeria Castro", "profession": "Policía", "status": "Patrullando"},
		"agent_6": {"name": "María López", "profession": "Vendedora", "status": "Atendiendo"}
	}
	return agents_data.get(agent_id, {})