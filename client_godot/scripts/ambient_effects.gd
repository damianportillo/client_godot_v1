extends Node2D

## FASE 5: Efectos Ambientales
## Implementación de partículas y efectos visuales para mejorar la experiencia del jugador.
## Se enfoca en efectos que funcionen bien en Android (GL Compatibility).

# Configuración de efectos ambientales
@export var enable_wind_effects: bool = true
@export var enable_fog_effects: bool = true
@export var enable_star_visibility: bool = true

# Efecto de partículas para viento
var wind_particles: GPUParticles2D = null
# Efecto de niebla
var fog_effect: Sprite2D = null
# Estrellas nocturnas
var stars: Sprite2D = null

func _ready() -> void:
	_initialize_ambient_effects()

func _initialize_ambient_effects() -> void:
	# Crear efectos ambientales basados en la hora del día
	var day_night_cycle = get_node_or_null("../DayNightCycle")
	if day_night_cycle:
		# Configurar efectos de viento
		if enable_wind_effects:
			_create_wind_effect()
		
		# Configurar niebla
		if enable_fog_effects:
			_create_fog_effect()
		
		# Configurar estrellas nocturnas
		if enable_star_visibility:
			_create_stars_effect()

func _create_wind_effect() -> void:
	# Crear partículas de viento (simplificado para Android)
	var wind_tex = preload("res://assets/particles/wind_particle.png")
	
	# Verificar si ya existe una partícula de viento
	if wind_particles == null:
		wind_particles = GPUParticles2D.new()
		wind_particles.texture = wind_tex
		wind_particles.emitting = true
		wind_particles.amount = 100
		wind_particles.lifetime = 2.0
		wind_particles.gravity = Vector2(0, 0)
		wind_particles.speed = 50
		wind_particles.angle = 0
		wind_particles.angle_curve = 0
		wind_particles.scale_curve = 1.0
		wind_particles.color = Color(1, 1, 1, 0.5)
		wind_particles.process_material = null
		
		add_child(wind_particles)

func _create_fog_effect() -> void:
	# Crear efecto de niebla para la noche
	if fog_effect == null:
		fog_effect = Sprite2D.new()
		fog_effect.texture = preload("res://assets/environment/fog.png")
		fog_effect.modulate = Color(1, 1, 1, 0.3) # Transparencia inicial
		fog_effect.position = Vector2(240, 135) # Centro del mundo
		fog_effect.z_index = -10 # Detrás de todo
		add_child(fog_effect)

func _create_stars_effect() -> void:
	# Crear estrellas nocturnas
	if stars == null:
		stars = Sprite2D.new()
		stars.texture = preload("res://assets/environment/stars.png")
		stars.modulate = Color(1, 1, 1, 0.7) # Transparencia inicial
		stars.position = Vector2(240, 135) # Centro del mundo
		stars.z_index = -20 # Detrás de todo
		add_child(stars)

func _process(delta: float) -> void:
	# Actualizar efectos ambientales basados en el ciclo día/noche
	var day_night_cycle = get_node_or_null("../DayNightCycle")
	if day_night_cycle:
		var night_factor = day_night_cycle.night_factor
		
		# Controlar visibilidad de estrellas
		if stars != null:
			stars.modulate.a = 1.0 - night_factor # Más brillantes por la noche
			
		# Controlar niebla
		if fog_effect != null:
			fog_effect.modulate.a = night_factor * 0.5 # Niebla más densa por la noche

func _on_world_clock_updated(clock_data: Dictionary) -> void:
	# Actualizar efectos cuando cambia el tiempo
	var day_night_cycle = get_node_or_null("../DayNightCycle")
	if day_night_cycle:
		var night_factor = day_night_cycle.night_factor
		
		# Ajustar efectos según el factor de noche
		if wind_particles != null:
			wind_particles.amount = 100 + (night_factor * 50) # Más partículas por la noche
			
		if fog_effect != null:
			fog_effect.modulate.a = night_factor * 0.5 # Más niebla por la noche

func _on_day_night_cycle_updated() -> void:
	# Manejar actualizaciones del ciclo día/noche
	pass