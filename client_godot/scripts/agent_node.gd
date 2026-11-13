extends CharacterBody2D
class_name AgentNode

## Representación visual e interpolación de movimiento de un habitante autónomo.
## - Animación 4 direcciones con Spritesheet oficial (char_<rol>.png).
## - Burbuja de acción flotante (ActionBubble) que refleja la actividad en tiempo real.
## - Micro-movimientos orgánicos (Living Idle / Wander) para dar vida al barrio.
## - Detección táctil y de mouse para inspección de datos.

signal agent_clicked(character_id: String)

@export var character_id: String = ""
@export var character_name: String = ""
@export var profession: String = ""
@export var move_speed: float = 65.0

var base_target_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var current_location_name: String = ""
var is_moving: bool = false
var is_selected: bool = false

var energy: float = 100.0
var hunger: float = 0.0
var thirst: float = 0.0
var health: float = 100.0
var money: float = 100.0
var raw_data: Dictionary = {}

# Micro-movimiento orgánico (Living Idle)
var wander_timer: float = 0.0
var next_wander_time: float = 4.0
var wander_offset: Vector2 = Vector2.ZERO
var current_action_icon: String = "🌾"

@onready var sprite: AnimatedSprite2D = get_node_or_null("Visual/AnimatedSprite")
@onready var name_label: Label = get_node_or_null("UI/NameLabel")
@onready var action_bubble: PanelContainer = get_node_or_null("UI/ActionBubble")
@onready var action_icon: Label = get_node_or_null("UI/ActionBubble/ActionIcon")
@onready var selection_ring: Line2D = get_node_or_null("SelectionRing")
@onready var touch_area: Area2D = get_node_or_null("TouchArea")

# Colores característicos por profesión
const DEFAULT_COLOR: Color = Color("d9d9d9")
const PROFESSION_COLORS: Dictionary = {
	"Proveedor de agua": Color("3a86ff"),
	"Proveedor de alimentos": Color("ffbe0b"),
	"Médico": Color("fb5607"),
	"Constructor": Color("8338ec"),
	"Policía": Color("0077b6"),
	"Político": Color("ff006e"),
}

const ROLE_SHEETS: Dictionary = {
	"Proveedor de alimentos": "res://assets/characters/char_alimentos.png",
	"Proveedor de agua": "res://assets/characters/char_agua.png",
	"Médico": "res://assets/characters/char_medico.png",
	"Constructor": "res://assets/characters/char_constructor.png",
	"Policía": "res://assets/characters/char_policia.png",
	"Político": "res://assets/characters/char_politico.png",
}
const WALK_FPS: float = 8.0
const _DIRS: Array[String] = ["down", "up", "left", "right"]

static var _frames_cache: Dictionary = {}

func _ready() -> void:
	target_position = global_position
	base_target_position = global_position
	_apply_role_sheet()
	_update_labels()
	_update_action_bubble()

	if touch_area:
		touch_area.input_event.connect(_on_touch_input)

	# Asignar tiempo aleatorio para que los agentes no caminen sincronizados
	next_wander_time = randf_range(3.0, 7.0)


func initialize(data: Dictionary, world_coords: Vector2) -> void:
	character_id = String(data.get("id", ""))
	character_name = String(data.get("name", ""))
	profession = String(data.get("profession", ""))
	current_location_name = String(data.get("current_location", "plaza"))
	raw_data = data

	global_position = world_coords
	base_target_position = world_coords
	target_position = world_coords

	update_state(data, world_coords)


func update_state(data: Dictionary, new_coords: Vector2) -> void:
	raw_data = data
	energy = float(data.get("energy", energy))
	hunger = float(data.get("hunger", hunger))
	thirst = float(data.get("thirst", thirst))
	health = float(data.get("health", health))
	money = float(data.get("money", money))
	current_location_name = String(data.get("current_location", current_location_name))

	# Si la locación cambió drásticamente, actualizar base_target_position
	if base_target_position.distance_to(new_coords) > 25.0:
		base_target_position = new_coords
		target_position = new_coords
		wander_offset = Vector2.ZERO

	_update_labels()
	_update_action_bubble()


func set_selected(val: bool) -> void:
	is_selected = val
	if selection_ring:
		selection_ring.visible = val


func _update_labels() -> void:
	if name_label:
		name_label.text = character_name
		name_label.add_theme_color_override("font_color",
			PROFESSION_COLORS.get(profession, DEFAULT_COLOR).lerp(Color.WHITE, 0.45))


func _update_action_bubble() -> void:
	if action_icon == null:
		return

	# Determinar icono según necesidades críticas o actividad del oficio
	if health < 40.0:
		current_action_icon = "❤️‍🩹"
	elif thirst > 70.0:
		current_action_icon = "💧"
	elif hunger > 70.0:
		current_action_icon = "🍞"
	elif energy < 30.0:
		current_action_icon = "💤"
	else:
		match profession:
			"Proveedor de alimentos":
				current_action_icon = "🌾"
			"Proveedor de agua":
				current_action_icon = "🚰"
			"Médico":
				current_action_icon = "🩺"
			"Constructor":
				current_action_icon = "🔨"
			"Policía":
				current_action_icon = "👮"
			"Político":
				current_action_icon = "📜"
			_:
				current_action_icon = "🚶"

	action_icon.text = current_action_icon


func _physics_process(delta: float) -> void:
	# Micro-movimientos de vida (Wander) si está cerca de su base
	wander_timer += delta
	if wander_timer >= next_wander_time:
		wander_timer = 0.0
		next_wander_time = randf_range(4.0, 9.0)
		# Deambular en un radio pequeño de 12 px
		var angle = randf() * TAU
		var dist = randf_range(4.0, 14.0)
		wander_offset = Vector2(cos(angle), sin(angle)) * dist
		target_position = base_target_position + wander_offset

	var dist_to_target: float = global_position.distance_to(target_position)
	if dist_to_target > 2.0:
		is_moving = true
		var dir: Vector2 = (target_position - global_position).normalized()
		velocity = dir * (move_speed * 0.7 if dist_to_target < 18.0 else move_speed)
		move_and_slide()
	else:
		is_moving = false
		velocity = Vector2.ZERO

	_update_animation()
	_animate_bubble(delta)
	_ambient_compensation()


func _animate_bubble(_delta: float) -> void:
	if action_bubble:
		# Flotación suave tipo rebote
		var bounce: float = sin(Time.get_ticks_msec() * 0.005 + hash(character_id) % 100) * 1.5
		action_bubble.position.y = -23.0 + bounce

	if selection_ring and is_selected:
		# Pulso de color y tamaño en el aro de selección
		var pulse: float = 0.8 + 0.2 * sin(Time.get_ticks_msec() * 0.008)
		selection_ring.scale = Vector2(pulse, pulse)


func _on_touch_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		agent_clicked.emit(character_id)
	elif event is InputEventScreenTouch and event.pressed:
		agent_clicked.emit(character_id)


# ----------------------------- Animación -----------------------------

func _apply_role_sheet() -> void:
	if sprite == null or profession == "":
		return
	var frames := _get_or_build_frames(profession)
	if frames == null:
		return
	sprite.sprite_frames = frames
	_update_animation()


func _get_or_build_frames(role: String) -> SpriteFrames:
	if _frames_cache.has(role):
		return _frames_cache[role]
	var path: String = ROLE_SHEETS.get(role, "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for i in _DIRS.size():
		var dir: String = _DIRS[i]
		var idle_name := "idle_" + dir
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, true)
		frames.add_frame(idle_name, _make_atlas(tex, i, 0))

		var walk_name := "walk_" + dir
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, WALK_FPS)
		frames.set_animation_loop(walk_name, true)
		for f in range(4):
			frames.add_frame(walk_name, _make_atlas(tex, i, f))
	_frames_cache[role] = frames
	return frames


func _make_atlas(tex: Texture2D, row: int, col: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(col * 16, row * 16, 16, 16)
	return at


func _dir_name_from_velocity(v: Vector2) -> String:
	if v.length() < 0.01:
		return "down"
	if absf(v.x) >= absf(v.y):
		return "left" if v.x < 0.0 else "right"
	return "up" if v.y < 0.0 else "down"


func _update_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	var prefix := "walk" if is_moving else "idle"
	var anim: String = prefix + "_" + _dir_name_from_velocity(velocity)
	if not sprite.sprite_frames.has_animation(anim):
		return
	if sprite.animation != anim:
		sprite.play(anim)
	elif not sprite.is_playing():
		sprite.play(anim)


func _ambient_compensation() -> void:
	var cycle := get_node_or_null("/root/Main/DayNightCycle") as CanvasModulate
	if cycle == null:
		return
	var c: Color = cycle.color
	var comp := Color(
		clampf(pow(1.0 / maxf(c.r, 0.10), 0.7), 1.0, 2.2),
		clampf(pow(1.0 / maxf(c.g, 0.10), 0.7), 1.0, 2.2),
		clampf(pow(1.0 / maxf(c.b, 0.10), 0.7), 1.0, 2.2),
		1.0)
	self_modulate = self_modulate.lerp(comp, 0.15)
