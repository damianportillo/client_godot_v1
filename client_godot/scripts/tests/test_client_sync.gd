extends SceneTree

## Pruebas de integración del cliente Godot 4 (headless).
## Cobertura:
##   1. Carga de escenas y estructura de la escena principal.
##   2. Modulación determinista Día/Noche.
##   3. Inicialización de AgentNode y colores por profesión.
##   4. Contrato real con el backend FastAPI (/api/clock, /api/characters, /api/houses).

func _init() -> void:
	print("=== INICIANDO PRUEBAS DE INTEGRACIÓN DEL CLIENTE GODOT 4 ===")
	var failures: int = 0

	failures += _test_scene_structure()
	failures += _test_day_night()
	failures += _test_agent_node()
	failures += _test_clock_contract()
	failures += _test_house_location_contract()
	failures += _test_world_sync_configuration()

	if failures == 0:
		print("=== TODAS LAS PRUEBAS DEL CLIENTE GODOT 4 APROBADAS SATISFACTORIAMENTE ===")
		quit(0)
	else:
		printerr("=== %d PRUEBA(S) DEL CLIENTE GODOT 4 FALLARON ===" % failures)
		quit(1)

func _check(condition: bool, message: String, failures: int) -> int:
	if condition:
		print("✓ " + message)
		return failures
	printerr("✗ FALLO: " + message)
	return failures + 1

func _test_scene_structure() -> int:
	var failures: int = 0
	var main_scene = load("res://scenes/main.tscn")
	failures = _check(main_scene != null, "main.tscn cargada correctamente.", failures)
	if main_scene == null:
		return failures

	var agent_scene = load("res://scenes/agent_node.tscn")
	failures = _check(agent_scene != null, "agent_node.tscn cargada correctamente.", failures)

	var main_instance = main_scene.instantiate()
	failures = _check(main_instance != null, "main.tscn instanciada.", failures)
	if main_instance == null:
		return failures

	failures = _check(main_instance.get_node_or_null("DayNightCycle") != null, "Nodo DayNightCycle presente.", failures)
	var world = main_instance.get_node_or_null("World")
	failures = _check(world != null, "Nodo World presente.", failures)
	if world:
		var locations = world.get_node_or_null("InteractiveLocations")
		failures = _check(locations != null, "World/InteractiveLocations presente.", failures)
		if locations:
			failures = _check(locations.get_child_count() == 9, "Se esperan 9 áreas interactivas; encontradas: %d." % locations.get_child_count(), failures)
			for area in locations.get_children():
				var location_name: String = String(area.name).to_lower()
				failures = _check(main_instance.LOCATIONS.has(location_name), "Catálogo lógico definido para %s." % location_name, failures)
				if main_instance.LOCATIONS.has(location_name):
					failures = _check(area.position == main_instance.LOCATIONS[location_name], "Coordenadas alineadas para %s." % location_name, failures)

	var hud = main_instance.get_node_or_null("HUDMain")
	failures = _check(hud != null, "Instancia HUDMain presente.", failures)
	if hud:
		failures = _check(hud.get_node_or_null("TopBar/HBox/ClockContainer/TimeLabel") != null, "HUDMain expone reloj en la ruta actual.", failures)
		failures = _check(hud.get_node_or_null("TopBar/HBox/RightContainer/StatusLabel") != null, "HUDMain expone estado de conexión.", failures)
		failures = _check(hud.get_node_or_null("CommunityMetricsModal") != null, "HUDMain expone modal de métricas.", failures)

	main_instance.free()
	return failures

func _test_day_night() -> int:
	var failures: int = 0
	var dn_script = load("res://scripts/day_night_cycle.gd").new()
	if dn_script == null:
		return _check(false, "day_night_cycle.gd cargado.", failures)

	dn_script.current_hour_float = 12.0
	dn_script._apply_lighting()
	failures = _check(dn_script.color == dn_script.day_color, "Iluminación de mediodía = color de día.", failures)

	dn_script.current_hour_float = 23.0
	dn_script._apply_lighting()
	failures = _check(dn_script.color == dn_script.night_color, "Iluminación de noche = color nocturno.", failures)

	dn_script.free()
	return failures

func _test_agent_node() -> int:
	var failures: int = 0
	var agent_scene = load("res://scenes/agent_node.tscn")
	if agent_scene == null:
		return _check(false, "agent_node.tscn disponible para instanciar.", failures)

	var agent_inst = agent_scene.instantiate()
	var mock_char_data = {
		"id": "char-test-01",
		"name": "Sofía Benítez",
		"profession": "Proveedor de agua",
		"energy": 90.0,
		"thirst": 20.0,
		"hunger": 15.0,
		"health": 100.0,
		"current_location": "manantial"
	}
	agent_inst.initialize(mock_char_data, Vector2(210, 120))
	failures = _check(agent_inst.character_name == "Sofía Benítez", "Nombre del agente inicializado.", failures)
	failures = _check(agent_inst.profession == "Proveedor de agua", "Profesión del agente inicializada.", failures)
	failures = _check(agent_inst.target_position == Vector2(210, 120), "Posición objetivo del agente aplicada.", failures)

	# Las claves de PROFESSION_COLORS deben coincidir exactamente con el backend
	# (incluyendo acentos), o los agentes quedan todos del color por defecto.
	var expected_professions: Array = [
		"Proveedor de agua",
		"Proveedor de alimentos",
		"Médico",
		"Constructor",
		"Policía",
		"Político",
	]
	for profession in expected_professions:
		failures = _check(
			agent_inst.PROFESSION_COLORS.has(profession),
			"Color definido para la profesión '%s'." % profession,
			failures
		)
	failures = _check(
		agent_inst.PROFESSION_COLORS.get("Médico", Color.BLACK) != agent_inst.DEFAULT_COLOR,
		"'Médico' no cae en el color por defecto.",
		failures
	)
	failures = _check(
		agent_inst.PROFESSION_COLORS.get("Policía", Color.BLACK) != agent_inst.DEFAULT_COLOR,
		"'Policía' no cae en el color por defecto.",
		failures
	)
	failures = _check(
		agent_inst.PROFESSION_COLORS.get("Político", Color.BLACK) != agent_inst.DEFAULT_COLOR,
		"'Político' no cae en el color por defecto.",
		failures
	)

	agent_inst.free()
	return failures

func _test_clock_contract() -> int:
	var failures: int = 0
	var hud_script = load("res://scripts/gui/hud_main.gd")
	failures = _check(hud_script != null, "hud_main.gd cargado.", failures)
	if hud_script == null:
		return failures

	var hud_methods: Array = []
	for entry in hud_script.get_script_method_list():
		hud_methods.append(String(entry.get("name", "")))
	failures = _check(hud_methods.has("_on_clock_updated"), "HUD procesa el payload real del reloj.", failures)

	var dn_script = load("res://scripts/day_night_cycle.gd").new()
	var clock_payload: Dictionary = {
		"world_time_utc": "2026-10-31T06:03:41.717737+00:00",
		"local_time_argentina": "2026-10-31T03:03:41.717745-03:00",
		"is_day": false,
		"phase": "night",
		"hour": 3,
		"minute": 3,
		"second": 41,
		"formatted_time": "03:03:41",
	}
	var hour_from_fields: float = dn_script.hour_from_clock_payload(clock_payload, -1.0)
	failures = _check(is_equal_approx(hour_from_fields, 3.05), "Ciclo día/noche usa hour+minute del payload.", failures)

	var iso_clock: Dictionary = {"local_time_argentina": "2026-10-31T18:30:00-03:00"}
	var hour_from_iso: float = dn_script.hour_from_clock_payload(iso_clock, -1.0)
	failures = _check(is_equal_approx(hour_from_iso, 18.5), "Ciclo día/noche deriva la hora desde ISO.", failures)

	var fallback_hour: float = dn_script.hour_from_clock_payload({}, 7.5)
	failures = _check(is_equal_approx(fallback_hour, 7.5), "Ciclo día/noche respeta el fallback.", failures)
	dn_script.free()
	return failures

func _test_house_location_contract() -> int:
	var failures: int = 0
	var main_scene = load("res://scenes/main.tscn")
	if main_scene == null:
		return _check(false, "main.tscn disponible para probar locaciones.", failures)
	var main_instance = main_scene.instantiate()
	# En un script SceneTree con `-s`, _init corre antes de que el árbol esté listo,
	# así que resolvemos el contenedor explícitamente (mismo path que usa main.gd).
	main_instance.characters_container = main_instance.get_node_or_null("World/Characters")

	# Catálogo real de GET /api/houses (id -> house_number).
	var houses_payload: Array = [
		{"id": "81876357-9a20-41f8-a9f5-58f2fe8d00b3", "house_number": 1},
		{"id": "550ac22b-c7d5-427e-b65f-aae959440af6", "house_number": 2},
		{"id": "1f352bdb-cabb-420e-87a7-4d25ce52733b", "house_number": 3},
		{"id": "5e83f265-45d4-40c1-9ada-b9f84afd9e83", "house_number": 4},
		{"id": "3351b012-2719-4d47-9d21-9bf6a7ced93d", "house_number": 5},
		{"id": "536f0c5d-15d6-4fbc-95ae-3ad1bbd31c17", "house_number": 6},
	]
	main_instance._on_houses_updated(houses_payload)

	# `current_location` del backend es "casa_<uuid>"; debe resolver a la casa lógica.
	var camila_home: Vector2 = main_instance.resolve_location("casa_536f0c5d-15d6-4fbc-95ae-3ad1bbd31c17")
	failures = _check(camila_home == main_instance.LOCATIONS["casa_6"], "casa_<uuid> de Camila resuelve a casa_6.", failures)

	var mateo_home: Vector2 = main_instance.resolve_location("casa_81876357-9a20-41f8-a9f5-58f2fe8d00b3")
	failures = _check(mateo_home == main_instance.LOCATIONS["casa_1"], "casa_<uuid> de Mateo resuelve a casa_1.", failures)

	failures = _check(main_instance.resolve_location("plaza") == main_instance.LOCATIONS["plaza"], "Locación 'plaza' resuelve correctamente.", failures)
	failures = _check(main_instance.resolve_location("casa_desconocida") == main_instance.LOCATIONS["plaza"], "UUID desconocido cae en plaza sin romper.", failures)
	failures = _check(main_instance.resolve_location("") == main_instance.LOCATIONS["plaza"], "Locación vacía cae en plaza sin romper.", failures)

	# Los agentes deben instanciarse en el contenedor correcto.
	var characters_payload: Array = [
		{"id": "80fca5ee-bb31-435f-a434-d56ce590b9ee", "name": "Camila Méndez", "profession": "Político", "current_location": "casa_536f0c5d-15d6-4fbc-95ae-3ad1bbd31c17"},
	]
	main_instance._on_characters_updated(characters_payload)
	failures = _check(main_instance.agent_nodes.size() == 1, "Un agente instanciado desde /api/characters.", failures)
	if main_instance.agent_nodes.has("80fca5ee-bb31-435f-a434-d56ce590b9ee"):
		var node = main_instance.agent_nodes["80fca5ee-bb31-435f-a434-d56ce590b9ee"]
		failures = _check(node.profession == "Político", "Profesión con acento preservada.", failures)
	else:
		failures = _check(false, "El agente de Camila fue registrado por su UUID.", failures)

	main_instance.free()
	return failures

func _test_world_sync_configuration() -> int:
	var failures: int = 0
	var sync_script = load("res://scripts/world_sync.gd")
	failures = _check(sync_script != null, "world_sync.gd cargado.", failures)
	if sync_script == null:
		return failures

	var methods: Array = []
	for entry in sync_script.get_script_method_list():
		methods.append(String(entry.get("name", "")))
	var signals: Array = []
	for entry in sync_script.get_script_signal_list():
		signals.append(String(entry.get("name", "")))

	failures = _check(methods.has("_resolve_base_url"), "WorldSync resuelve el endpoint por plataforma.", failures)
	failures = _check(methods.has("request_full_sync"), "WorldSync expone request_full_sync().", failures)
	failures = _check(not sync_script.get_script_property_list().filter(func(p): return String(p.get("name", "")) == "is_connected").is_empty(), "WorldSync expone estado de conexión.", failures)
	failures = _check(signals.has("sync_status_changed"), "WorldSync emite sync_status_changed.", failures)

	# Los endpoints configurables deben existir en project.godot (o usar el fallback).
	var android_url: String = String(ProjectSettings.get_setting("neighborhood_ai/api_base_url_android", "http://192.168.0.61:8000"))
	var desktop_url: String = String(ProjectSettings.get_setting("neighborhood_ai/api_base_url_desktop", "http://192.168.0.61:8000"))
	failures = _check(android_url.begins_with("http://") or android_url.begins_with("https://"), "Endpoint Android configurado (%s)." % android_url, failures)
	failures = _check(desktop_url.begins_with("http://") or desktop_url.begins_with("https://"), "Endpoint Desktop configurado (%s)." % desktop_url, failures)

	return failures
