extends Node2D

## FASE 3 — LightingManager: encendido progresivo de PointLight2D.
## - Faroles (Decoration/…): luz amarilla cálida al anochecer.
## - Ventanas de las 6 casas: luz cálida de interior por la noche.
## - Fuente: halo azul-cian sutil.
## - Plaza Mayor: abatimiento suave central por la noche.
## Sin sombras dinámicas (GL Compatibility + Android).
## Se alimenta del ciclo real de Buenos Aires vía DayNightCycle.night_factor.

const LAMP_COLOR := Color(1.0, 0.78, 0.42)
const WINDOW_COLOR := Color(1.0, 0.70, 0.38)
const FOUNTAIN_COLOR := Color(0.55, 0.85, 1.0)
const PLAZA_COLOR := Color(1.0, 0.86, 0.62)

var _lamp_lights: Array[PointLight2D] = []
var _window_lights: Array[PointLight2D] = []
var _fountain_light: PointLight2D = null
var _plaza_light: PointLight2D = null
var _cycle: CanvasModulate = null


func _ready() -> void:
	_cycle = get_node_or_null("../DayNightCycle")
	_build_all_lights()
	_apply(0.0)  # estado diurno seguro por defecto


func _process(_delta: float) -> void:
	if _cycle:
		_apply(_cycle.night_factor)


func _make_light_texture() -> Texture2D:
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 128
	tex.height = 128
	return tex


func _build_all_lights() -> void:
	var tex := _make_light_texture()

	# Faroles en esquinas y avenidas principales
	var lamp_positions: Array[Vector2] = [
		Vector2(384, 192),
		Vector2(576, 192),
		Vector2(384, 356),
		Vector2(576, 356),
		Vector2(128, 208),
		Vector2(128, 344),
		Vector2(768, 208),
		Vector2(384, 172)
	]
	for pos in lamp_positions:
		var l := _make_light(tex, LAMP_COLOR, 0.85, 0.65)
		l.position = pos
		add_child(l)
		_lamp_lights.append(l)

	# Ventanas cálidas iluminadas en las 6 viviendas
	var house_positions: Array[Vector2] = [
		Vector2(140, 140),   # Casa 1
		Vector2(140, 380),  # Casa 2
		Vector2(780, 400), # Casa 3
		Vector2(340, 100),  # Casa 4
		Vector2(780, 140),  # Casa 5
		Vector2(620, 100)   # Casa 6
	]
	for hpos in house_positions:
		var l := _make_light(tex, WINDOW_COLOR, 0.80, 0.45)
		l.position = hpos + Vector2(0, 4)
		add_child(l)
		_window_lights.append(l)

	# Fuente central: resplandor cian sutil
	_fountain_light = _make_light(tex, FOUNTAIN_COLOR, 0.60, 0.50)
	_fountain_light.position = Vector2(480, 270)
	add_child(_fountain_light)

	# Plaza Mayor: iluminación ambiental cálida central
	_plaza_light = _make_light(tex, PLAZA_COLOR, 0.50, 1.40)
	_plaza_light.position = Vector2(480, 270)
	add_child(_plaza_light)


func _make_light(tex: Texture2D, color: Color, energy: float, scale: float) -> PointLight2D:
	var l := PointLight2D.new()
	l.texture = tex
	l.color = color
	l.energy = energy
	l.texture_scale = scale
	l.shadow_enabled = false     # implica GL Compatibility-first / Android
	l.blend_mode = Light2D.BLEND_MODE_ADD
	return l


## Aplica el encendido progresivo según night_factor (0 día — 1 noche).
func _apply(nf: float) -> void:
	# Faroles: arrancan al anochecer (nf 0.25 → 0.65)
	var lamp_e := _ramp(nf, 0.25, 0.65, 0.0, 1.1)
	for l in _lamp_lights:
		l.energy = lamp_e

	# Ventanas: iluminación interior desde el atardecer más profundo
	var win_e := _ramp(nf, 0.55, 0.95, 0.0, 0.85)
	for l in _window_lights:
		l.energy = win_e

	# Fuente: resplandor frío solo en noche avanzada
	if _fountain_light:
		_fountain_light.energy = _ramp(nf, 0.7, 1.0, 0.0, 0.55)
	if _plaza_light:
		_plaza_light.energy = _ramp(nf, 0.4, 0.9, 0.0, 0.35)


static func _ramp(v: float, a: float, b: float, out_min: float, out_max: float) -> float:
	var t := clampf((v - a) / maxf(0.0001, b - a), 0.0, 1.0)
	# easing suave (smoothstep)
	t = t * t * (3.0 - 2.0 * t)
	return lerpf(out_min, out_max, t)
