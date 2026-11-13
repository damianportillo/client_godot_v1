extends CanvasModulate

## Control de Iluminación y Ciclo Día/Noche (CanvasModulate)
## Mapea determinísticamente la hora local de Buenos Aires (UTC-3) a una gradiente de luz retro.
## FASE 3: expone `current_hour_float` y `night_factor` para que el LightingManager
## encienda faroles/ventanas/fuente progresivamente. Contratos intactos.

@export var day_color: Color = Color(1.0, 0.99, 0.95, 1.0)
@export var sunset_color: Color = Color(0.95, 0.62, 0.38, 1.0)   # atardecer más anaranjado
@export var night_color: Color = Color(0.16, 0.20, 0.40, 1.0)    # azul profundo (cálido aún reconocible)
@export var dawn_color: Color = Color(0.72, 0.62, 0.78, 1.0)     # lila amanecer

var current_hour_float: float = 12.0 # Mediodía por defecto
var night_factor: float = 0.0        # 0 = día pleno, 1 = noche plena (uso del LightingManager)

# Ancho creciente de "oscuridad ambiental": 1 de noche, 0 de día.
@export var ambient_darkness_factor: float = 0.0


func _ready() -> void:
	var sync_node = get_node_or_null("/root/WorldSync")
	if sync_node:
		sync_node.world_clock_updated.connect(_on_world_clock_updated)


func _on_world_clock_updated(clock_data: Dictionary) -> void:
	current_hour_float = hour_from_clock_payload(clock_data, current_hour_float)
	_apply_lighting()


## Extrae la hora local (UTC-3) del payload de /api/clock.
## Contrato real: `local_time_argentina` (ISO-8601), `hour` y `minute`.
func hour_from_clock_payload(clock_data: Dictionary, fallback: float) -> float:
	if clock_data.has("hour"):
		return float(clock_data.get("hour", 0)) + float(clock_data.get("minute", 0)) / 60.0

	var raw: String = String(clock_data.get("local_time_argentina", ""))
	if raw.is_empty():
		raw = String(clock_data.get("formatted_time", ""))
	if raw.contains("T"):
		raw = raw.get_slice("T", 1)
	var parts: PackedStringArray = raw.split(":")
	if parts.size() < 2 or not parts[0].is_valid_int():
		return fallback
	return float(parts[0]) + float(parts[1]) / 60.0


static func compute_night_factor(h: float) -> float:
	# Ancho creciente de "oscuridad ambiental": 1 de noche, 0 de día.
	if h >= 6.0 and h < 18.5:
		return 0.0
	if h >= 21.0 or h < 4.5:
		return 1.0
	if h >= 18.5 and h < 21.0:
		# anochecer: sube gradual durante el atardecer
		return clampf((h - 18.5) / 2.5, 0.0, 1.0)
	if h >= 5.0 and h < 6.0:
		# amanecer: baja de 04:30 a 06:00
		return clampf(1.0 - (h - 4.5 + 24.0 if h < 4.5 else h - 4.5) / 1.5, 0.0, 1.0)
	return 0.0


func _apply_lighting() -> void:
	var target_color: Color = day_color
	var h: float = current_hour_float

	if h >= 6.0 and h < 18.5:
		target_color = day_color
	elif h >= 18.5 and h < 20.0:
		var t: float = (h - 18.5) / 1.5
		target_color = day_color.lerp(sunset_color, t)
	elif h >= 20.0 and h < 21.0:
		var t: float = (h - 20.0) / 1.0
		target_color = sunset_color.lerp(night_color, t)
	elif h >= 21.0 or h < 5.0:
		target_color = night_color
	elif h >= 5.0 and h < 6.0:
		var t: float = (h - 5.0) / 1.0
		target_color = night_color.lerp(dawn_color, t)
	else:
		target_color = day_color

	# Suavizado temporal: evita saltos al recibir ticks de 1 segundo.
	color = color.lerp(target_color, 0.35) if Engine.get_process_frames() > 5 else target_color
	night_factor = compute_night_factor(h)
	ambient_darkness_factor = night_factor