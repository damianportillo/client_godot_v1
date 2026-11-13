extends Node

## Test para validar las fases gráficas implementadas
## FASES 3-6: Iluminación, HUD, Efectos Ambientales, Optimización

func _ready() -> void:
	# Iniciar pruebas de las fases gráficas
	print("Iniciando pruebas de las fases gráficas...")
	
	# Validar fase 3 - Iluminación y ciclo día/noche
	_test_phase_3()
	
	# Validar fase 4 - Rediseño del HUD
	_test_phase_4()
	
	# Validar fase 5 - Efectos ambientales
	_test_phase_5()
	
	# Validar fase 6 - Optimización gráfica
	_test_phase_6()
	
	print("Todas las pruebas de fases gráficas completadas.")

func _test_phase_3() -> void:
	print("Test FASE 3: Iluminación y ciclo día/noche")
	var day_night_cycle = get_node_or_null("../DayNightCycle")
	if day_night_cycle:
		print("✓ Sistema de iluminación encontrado")
		print("  - current_hour_float:", day_night_cycle.current_hour_float)
		print("  - night_factor:", day_night_cycle.night_factor)
		print("  - ambient_darkness_factor:", day_night_cycle.ambient_darkness_factor)
	else:
		print("✗ Sistema de iluminación no encontrado")

func _test_phase_4() -> void:
	print("Test FASE 4: Rediseño del HUD")
	var hud = get_node_or_null("../HUDMain")
	if hud:
		print("✓ HUD encontrado")
		# Verificar que los elementos del HUD existen
		var time_label = hud.get_node_or_null("TopBar/TimeContainer/TimeLabel")
		var status_label = hud.get_node_or_null("TopBar/StatusContainer/StatusLabel")
		if time_label and status_label:
			print("✓ Elementos del HUD encontrados")
		else:
			print("✗ Algunos elementos del HUD no encontrados")
	else:
		print("✗ HUD no encontrado")

func _test_phase_5() -> void:
	print("Test FASE 5: Efectos ambientales")
	var ambient_manager = get_node_or_null("../AmbientEffectsManager")
	if ambient_manager:
		print("✓ Sistema de efectos ambientales encontrado")
		print("  - Wind effects enabled:", ambient_manager.enable_wind_effects)
		print("  - Fog effects enabled:", ambient_manager.enable_fog_effects)
		print("  - Star visibility enabled:", ambient_manager.enable_star_visibility)
	else:
		print("✗ Sistema de efectos ambientales no encontrado")

func _test_phase_6() -> void:
	print("Test FASE 6: Optimización gráfica")
	var graphics_optimizer = get_node_or_null("../GraphicsOptimizer")
	if graphics_optimizer:
		print("✓ Sistema de optimización gráfica encontrado")
		print("  - Texture compression:", graphics_optimizer.enable_texture_compression)
		print("  - Culling:", graphics_optimizer.enable_culling)
		print("  - Batching:", graphics_optimizer.enable_batching)
		print("  - Shader optimization:", graphics_optimizer.enable_shader_optimization)
	else:
		print("✗ Sistema de optimización gráfica no encontrado")

func _test_all_systems() -> void:
	# Test completo de todos los sistemas
	print("Ejecutando test completo de todos los sistemas gráficos...")
	
	# Validar que los nodos principales existen
	var sync_node = get_node_or_null("/root/WorldSync")
	if sync_node:
		print("✓ WorldSync node encontrado")
	else:
		print("✗ WorldSync node no encontrado")
	
	# Verificar la estructura del mundo
	var main_scene = get_tree().current_scene
	if main_scene:
		print("✓ Escena principal encontrada")
		
		# Verificar componentes principales
		var day_night_cycle = main_scene.get_node_or_null("DayNightCycle")
		var lighting_manager = main_scene.get_node_or_null("LightingManager")
		var ambient_effects = main_scene.get_node_or_null("AmbientEffectsManager")
		var graphics_optimizer = main_scene.get_node_or_null("GraphicsOptimizer")
		
		print("  - DayNightCycle:", day_night_cycle != null)
		print("  - LightingManager:", lighting_manager != null)
		print("  - AmbientEffectsManager:", ambient_effects != null)
		print("  - GraphicsOptimizer:", graphics_optimizer != null)
	else:
		print("✗ Escena principal no encontrada")