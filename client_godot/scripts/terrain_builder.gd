extends Node2D

## FASE 1 — Renovación gráfica (placeholder procedural).
## Construye el suelo con TileMapLayer a partir de `assets/tilesets/terrain_main.png`
## y agrega props (árboles, bancos, faroles, flores, fuente) desde el atlas de props.
## El pueblo está en el centro y está rodeado de geografía natural:
##  - Cordillera de montañas en los bordes superiores e inferiores
##  - Bosque denso en los laterales izquierdo y derecho
##  - Río que cruza el pueblo de este a oeste
##  - Campos de cultivo y praderas en las zonas intermedias
## Respeta la distribución funcional original (calle H y calle V + Plaza Central).
## El arte final de Antigravity reemplaza estas texturas sin cambiar el layout.

const TILE: int = 16
const TERRAIN_TEX_PATH: String = "res://assets/tilesets/terrain_main.png"
const PROPS_TEX_PATH: String = "res://assets/props/props_main.png"
const FOUNTAIN_TEX_PATH: String = "res://assets/props/fountain.png"

const GRASS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
const CLOVER: Array[Vector2i] = [Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]
const DIRT: Vector2i = Vector2i(0, 1)
const COBBLE: Vector2i = Vector2i(0, 2)
const STONE: Array[Vector2i] = [Vector2i(0, 3), Vector2i(1, 3)]
const VEREDA: Vector2i = Vector2i(2, 3)
const WATER: Vector2i = Vector2i(0, 4)

const ROAD_COLS_V1: Array[int] = [4]
const ROAD_COLS_V2: Array[int] = [14, 15]
const ROAD_COLS_V3: Array[int] = [23]
const ROAD_ROWS_H: Array[int] = [7, 8, 9]
const PLAZA_COLS: Array[int] = [12, 13, 14, 15, 16, 17]
const PLAZA_ROWS: Array[int] = [6, 7, 8, 9, 10]

const WORLD_COLS: int = 80
const WORLD_ROWS: int = 50

const PUEBLO_CENTER_X: int = 40
const PUEBLO_CENTER_Y: int = 25
const PUEBLO_RADIUS_COLS: int = 25
const PUEBLO_RADIUS_ROWS: int = 18

const PROP_REGIONS: Dictionary = {
"tree_big": Rect2(0, 0, 32, 48),
"tree_fruit": Rect2(32, 0, 32, 48),
"bush": Rect2(32, 48, 16, 16),
"bush_flower": Rect2(48, 48, 16, 16),
"flowers_1": Rect2(64, 48, 16, 16),
"flowers_2": Rect2(80, 48, 16, 16),
"barrel": Rect2(96, 48, 16, 16),
"well": Rect2(112, 48, 16, 16),
"planter": Rect2(128, 48, 16, 16),
"lamp": Rect2(144, 48, 16, 32),
"fence": Rect2(160, 48, 16, 16),
"bench": Rect2(176, 48, 32, 16),
}

const PROPS_PUEBLO: Array = [
["tree_big", Vector2(20, 42), false],
["tree_fruit", Vector2(20, 250), true],
["tree_big", Vector2(460, 40), true],
["tree_fruit", Vector2(462, 244), false],
["tree_big", Vector2(470, 130), true],
["tree_fruit", Vector2(14, 146), false],
["tree_fruit", Vector2(30, 206), false],
["tree_big", Vector2(452, 60), false],
["tree_big", Vector2(140, 30), false],
["tree_fruit", Vector2(180, 40), true],
["tree_big", Vector2(330, 38), true],
["tree_fruit", Vector2(452, 200), false],
["tree_big", Vector2(132, 258), true],
["tree_fruit", Vector2(322, 252), false],
["tree_big", Vector2(448, 130), false],
["fence", Vector2(84, 96), false],
["fence", Vector2(84, 112), false],
["fence", Vector2(84, 80), false],
["fence", Vector2(100, 80), false],
["fence", Vector2(116, 80), false],
["fence", Vector2(132, 80), false],
["fence", Vector2(132, 96), false],
["fence", Vector2(132, 112), false],
["planter", Vector2(108, 110), false],
["planter", Vector2(124, 126), true],
["bush", Vector2(84, 128), false],
["flowers_1", Vector2(60, 118), false],
["flowers_2", Vector2(150, 62), false],
["well", Vector2(204, 112), false],
["barrel", Vector2(216, 124), false],
["flowers_1", Vector2(190, 118), false],
["flowers_2", Vector2(230, 118), false],
["lamp", Vector2(64, 104), false],
["lamp", Vector2(64, 172), false],
["lamp", Vector2(384, 104), false],
["lamp", Vector2(384, 172), false],
["bench", Vector2(238, 168), false],
["bench", Vector2(238, 100), true],
["planter", Vector2(198, 156), false],
["planter", Vector2(282, 156), true],
["planter", Vector2(198, 108), false],
["planter", Vector2(282, 108), true],
]



const PROPS_NATURALES: Array = [
["tree_big", Vector2(40, 2), false],
["tree_big", Vector2(30, 3), false],
["tree_big", Vector2(50, 3), false],
["tree_big", Vector2(20, 4), false],
["tree_big", Vector2(60, 4), false],
["tree_big", Vector2(10, 5), false],
["tree_big", Vector2(70, 5), false],
["tree_big", Vector2(5, 6), false],
["tree_big", Vector2(75, 6), false],
["tree_big", Vector2(40, 48), false],
["tree_big", Vector2(30, 47), false],
["tree_big", Vector2(50, 47), false],
["tree_big", Vector2(20, 46), false],
["tree_big", Vector2(60, 46), false],
["tree_big", Vector2(10, 45), false],
["tree_big", Vector2(70, 45), false],
["tree_big", Vector2(2, 10), false],
["tree_big", Vector2(2, 15), false],
["tree_big", Vector2(2, 20), false],
["tree_big", Vector2(2, 25), false],
["tree_big", Vector2(2, 30), false],
["tree_big", Vector2(2, 35), false],
["tree_big", Vector2(4, 12), false],
["tree_big", Vector2(4, 18), false],
["tree_big", Vector2(4, 28), false],
["tree_big", Vector2(4, 38), false],
["bush", Vector2(6, 10), false],
["bush", Vector2(6, 20), false],
["bush", Vector2(6, 30), false],
["bush", Vector2(6, 40), false],
["tree_big", Vector2(78, 10), false],
["tree_big", Vector2(78, 15), false],
["tree_big", Vector2(78, 20), false],
["tree_big", Vector2(78, 25), false],
["tree_big", Vector2(78, 30), false],
["tree_big", Vector2(78, 35), false],
["tree_big", Vector2(76, 12), false],
["tree_big", Vector2(76, 28), false],
["tree_big", Vector2(76, 38), false],
["bush", Vector2(74, 10), false],
["bush", Vector2(74, 20), false],
["bush", Vector2(74, 30), false],
["bush", Vector2(74, 40), false],
["bush_flower", Vector2(15, 8), false],
["bush_flower", Vector2(25, 8), false],
["bush_flower", Vector2(55, 8), false],
["bush_flower", Vector2(65, 8), false],
["bush_flower", Vector2(15, 42), false],
["bush_flower", Vector2(25, 42), false],
["bush_flower", Vector2(55, 42), false],
["bush_flower", Vector2(65, 42), false],
["flowers_1", Vector2(10, 15), false],
["flowers_1", Vector2(70, 15), false],
["flowers_1", Vector2(10, 35), false],
["flowers_1", Vector2(70, 35), false],
["flowers_2", Vector2(20, 12), false],
["flowers_2", Vector2(60, 12), false],
["flowers_2", Vector2(20, 38), false],
["flowers_2", Vector2(60, 38), false],
]




func _ready() -> void:
_build_ground_tiles()
_build_props_pueblo()
_build_naturaleza()
_build_fountain()


## Construye el suelo del mundo ampliado con geografía natural alrededor del pueblo.
func _build_ground_tiles() -> void:
var tile_set := TileSet.new()
tile_set.tile_size = Vector2i(TILE, TILE)
var atlas := TileSetAtlasSource.new()
atlas.texture = load(TERRAIN_TEX_PATH)
atlas.texture_region_size = Vector2i(TILE, TILE)
var used_cells: Array[Vector2i] = []
for cell in GRASS:
used_cells.append(cell)
for cell in CLOVER:
used_cells.append(cell)
for v in [DIRT, COBBLE, WATER, VEREDA]:
used_cells.append(v)
for cell in STONE:
used_cells.append(cell)
for cell in used_cells:
atlas.create_tile(cell)
tile_set.add_source(atlas, 0)

var layer := TileMapLayer.new()
layer.name = "GroundTiles"
layer.tile_set = tile_set
add_child(layer)

var rng := RandomNumberGenerator.new()
rng.seed = 20261110

for x in range(WORLD_COLS):
for y in range(WORLD_ROWS):
var pos := Vector2i(x, y)
var atlas_pos: Vector2i

var en_pueblo := abs(pos.x - PUEBLO_CENTER_X) <= PUEBLO_RADIUS_COLS and abs(pos.y - PUEBLO_CENTER_Y) <= PUEBLO_RADIUS_ROWS

if _is_plaza(pos):
atlas_pos = STONE[rng.randi_range(0, STONE.size() - 1)]
elif _c(pos.x, ROAD_COLS_V2) or _c(pos.x, ROAD_COLS_V1) or _c(pos.x, ROAD_COLS_V3):
atlas_pos = COBBLE
elif _c(pos.y, ROAD_ROWS_H):
atlas_pos = COBBLE
elif not en_pueblo:
if y < 8:
var roll := rng.randf()
if roll < 0.6:
atlas_pos = STONE[rng.randi_range(0, STONE.size() - 1)]
elif roll < 0.85:
atlas_pos = DIRT
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]
elif y > WORLD_ROWS - 8:
var roll := rng.randf()
if roll < 0.6:
atlas_pos = STONE[rng.randi_range(0, STONE.size() - 1)]
elif roll < 0.85:
atlas_pos = DIRT
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]
elif x < 8:
var roll := rng.randf()
if roll < 0.3:
atlas_pos = CLOVER[rng.randi_range(0, CLOVER.size() - 1)]
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]
elif x > WORLD_COLS - 8:
var roll := rng.randf()
if roll < 0.3:
atlas_pos = CLOVER[rng.randi_range(0, CLOVER.size() - 1)]
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]
elif abs(pos.y - PUEBLO_CENTER_Y) <= 2:
atlas_pos = WATER
else:
var roll := rng.randf()
if roll < 0.25:
atlas_pos = CLOVER[rng.randi_range(0, CLOVER.size() - 1)]
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]
else:
var roll := rng.randf()
if roll < 0.18:
atlas_pos = CLOVER[rng.randi_range(0, CLOVER.size() - 1)]
else:
atlas_pos = GRASS[rng.randi_range(0, GRASS.size() - 1)]

layer.set_cell(pos, 0, atlas_pos)


func _c(i: int, list: Array[int]) -> bool:
return list.has(i)


func _is_plaza(pos: Vector2i) -> bool:
return PLAZA_COLS.has(pos.x) and PLAZA_ROWS.has(pos.y)




## Construye los props del pueblo (casas, faroles, bancos, etc.) en sus posiciones originales.
func _build_props_pueblo() -> void:
var atlas_tex: Texture2D = load(PROPS_TEX_PATH)
var decor := Node2D.new()
decor.name = "DecorationPueblo"
add_child(decor)
for entry in PROPS_PUEBLO:
var prop_name: String = entry[0]
var anchor: Vector2 = entry[1]
var flip: bool = entry[2]
var sprite := Sprite2D.new()
sprite.name = prop_name.to_pascal_case() + "_" + str(anchor)
sprite.texture = atlas_tex
sprite.region_enabled = true
sprite.region_rect = PROP_REGIONS[prop_name]
sprite.centered = true
sprite.offset = Vector2(0, -sprite.region_rect.size.y / 2.0 + 2.0)
sprite.position = anchor
sprite.flip_h = flip
decor.add_child(sprite)


## Construye la geografía natural alrededor del pueblo (árboles, arbustos, flores).
func _build_naturaleza() -> void:
var atlas_tex: Texture2D = load(PROPS_TEX_PATH)
var decor := Node2D.new()
decor.name = "DecorationNatural"
add_child(decor)

var offset := Vector2(400, 265)

for entry in PROPS_NATURALES:
var prop_name: String = entry[0]
var anchor: Vector2 = entry[1]
var flip: bool = entry[2]

var pos_px := anchor * TILE + offset

var sprite := Sprite2D.new()
sprite.name = prop_name.to_pascal_case() + "_natural_" + str(anchor)
sprite.texture = atlas_tex
sprite.region_enabled = true
sprite.region_rect = PROP_REGIONS[prop_name]
sprite.centered = true
sprite.offset = Vector2(0, -sprite.region_rect.size.y / 2.0 + 2.0)
sprite.position = pos_px
sprite.flip_h = flip
decor.add_child(sprite)


func _build_fountain() -> void:
var sprite := Sprite2D.new()
sprite.name = "Fountain"
sprite.texture = load(FOUNTAIN_TEX_PATH)
sprite.position = Vector2(640, 400)
add_child(sprite)
var label := Label.new()
label.name = "PlazaLabel"
label.text = "Plaza Mayor"
label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
label.add_theme_font_size_override("font_size", 9)
label.add_theme_color_override("font_color", Color(0.15, 0.2, 0.15))
label.position = Vector2(604, 423)
label.size = Vector2(72, 16)
add_child(label)

