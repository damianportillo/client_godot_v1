extends Node

## WorldSyncManager (Autoload Singleton)
## Consume los endpoints REST de FastAPI para sincronizar el estado del mundo,
## habitantes, viviendas, acontecimientos y escala temporal.

signal world_clock_updated(clock_data: Dictionary)
signal characters_updated(characters_list: Array)
signal houses_updated(houses_list: Array)
signal events_updated(events_list: Array)
signal sync_error(error_message: String)
signal sync_status_changed(connected: bool)

const SYNC_INTERVAL_SEC: float = 1.0 # Consulta periódica cada 1 segundo (sincronizada con el reloj)
const DEFAULT_ANDROID_URL: String = "http://192.168.0.61:8000"
const DEFAULT_DESKTOP_URL: String = "http://192.168.0.61:8000"

# Endpoint dinámico: en Android apunta a la IP LAN de MINER, en PC a loopback.
# Se puede sobreescribir sin tocar código desde project.godot:
#   [neighborhood_ai]
#   api_base_url_android="http://192.168.0.61:8000"
#   api_base_url_desktop="http://192.168.0.61:8000"
var BASE_URL: String = DEFAULT_DESKTOP_URL

var http_clock: HTTPRequest
var http_characters: HTTPRequest
var http_houses: HTTPRequest
var http_events: HTTPRequest

var latest_clock: Dictionary = {}
var latest_characters: Array = []
var latest_houses: Array = []
var latest_events: Array = []

var is_syncing: bool = false
var is_connected: bool = false
var elapsed_timer: float = 0.0
var consecutive_failures: int = 0
var last_success_msec: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	BASE_URL = _resolve_base_url()
	_setup_http_clients()

func _resolve_base_url() -> String:
	var is_android: bool = OS.get_name() == "Android"
	var setting_key: String = "neighborhood_ai/api_base_url_android" if is_android else "neighborhood_ai/api_base_url_desktop"
	var fallback: String = DEFAULT_ANDROID_URL if is_android else DEFAULT_DESKTOP_URL
	var url: String = String(ProjectSettings.get_setting(setting_key, fallback)).strip_edges()
	if url.is_empty():
		url = fallback
	return url.trim_suffix("/")

func _setup_http_clients() -> void:
	http_clock = HTTPRequest.new()
	http_characters = HTTPRequest.new()
	http_houses = HTTPRequest.new()
	http_events = HTTPRequest.new()

	add_child(http_clock)
	add_child(http_characters)
	add_child(http_houses)
	add_child(http_events)

	http_clock.request_completed.connect(_on_clock_request_completed)
	http_characters.request_completed.connect(_on_characters_request_completed)
	http_houses.request_completed.connect(_on_houses_request_completed)
	http_events.request_completed.connect(_on_events_request_completed)

func _process(delta: float) -> void:
	elapsed_timer += delta
	if elapsed_timer >= SYNC_INTERVAL_SEC:
		elapsed_timer = 0.0
		request_full_sync()

func request_full_sync() -> void:
	# Cada endpoint usa su propio HTTPRequest para no serializar la sincronización.
	if http_clock.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_clock.request(BASE_URL + "/api/clock")
	if http_characters.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_characters.request(BASE_URL + "/api/characters")
	if http_houses.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_houses.request(BASE_URL + "/api/houses")
	if http_events.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_events.request(BASE_URL + "/api/events")

func _mark_success() -> void:
	last_success_msec = Time.get_ticks_msec()
	consecutive_failures = 0
	if not is_connected:
		is_connected = true
		sync_status_changed.emit(true)

func _mark_failure(message: String) -> void:
	consecutive_failures += 1
	# Emitir también en el primer fallo: si el servidor está caído al arrancar,
	# el HUD debe salir de "sincronizando..." y mostrar "sin conexión".
	if is_connected or consecutive_failures == 1:
		is_connected = false
		sync_status_changed.emit(false)
	sync_error.emit(message)

func _parse_json_body(result: int, response_code: int, body: PackedByteArray) -> Variant:
	if result != HTTPRequest.RESULT_SUCCESS:
		return null
	if response_code != 200:
		return null
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return null
	return json.get_data()

func _on_clock_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = _parse_json_body(result, response_code, body)
	if data is Dictionary:
		latest_clock = data
		_mark_success()
		world_clock_updated.emit(latest_clock)
	else:
		_mark_failure("Fallo al sincronizar reloj: HTTP " + str(response_code))

func _on_characters_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = _parse_json_body(result, response_code, body)
	if data is Array:
		latest_characters = data
		_mark_success()
		characters_updated.emit(latest_characters)
	else:
		_mark_failure("Fallo al sincronizar personajes: HTTP " + str(response_code))

func _on_houses_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = _parse_json_body(result, response_code, body)
	if data is Array:
		latest_houses = data
		_mark_success()
		houses_updated.emit(latest_houses)
	else:
		_mark_failure("Fallo al sincronizar viviendas: HTTP " + str(response_code))

func _on_events_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = _parse_json_body(result, response_code, body)
	if data is Array:
		latest_events = data
		_mark_success()
		events_updated.emit(latest_events)
	else:
		_mark_failure("Fallo al sincronizar acontecimientos: HTTP " + str(response_code))
