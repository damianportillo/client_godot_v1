# Guía de Estilo — Renovación Gráfica Neighborhood AI

## Referencia principal
`client_godot/examples/Plaza Mayor_ Comunidad en Calma.png` (el resto de las imágenes de `examples/` define la paleta y el nocturno).

## Reglas técnicas innegociables
- Proyecto mantiene **480×270 lógicos** (30×17 tiles de 16×16), `viewport stretch`, filtro **Nearest** y **GL Compatibility**.
- Todo el arte se dibuja en grilla de **16×16 px por celda** (múltiplos de 16 para piezas grandes, ej. casa 5×5 tiles = 80×80 px de base + volado de techo).
- Sin filtros, sin escalado no entero, sin gradientes suaves (ruido primeros planos vs fondo).
- Los PNG se exportan **exactamente al tamaño especificado en `FASE1_assets_spec.md`** (framewidth/frameheight enteros), fondo transparente (alpha), sin líneas de guía.
- Colores planos con 2–3 niveles de sombra/luz por material (paleta del párrafo siguiente). Máximo ~24 colores por hoja.

## Paleta base (extraída del mock)
| Material | Claro | Base | Sombra |
|---|---|---|---|
| Césped | `#8fd163` | `#78bd4f` | `#5da03f` |
| Césped decorativo (tréboles) | `#7fc255` | `#6db14a` | `#54a03a` |
| Camino de tierra/adoquín (junta clara) | `#e6d6b3` | `#cdb493` | `#a98d68` |
| Adoquines | `#cfcabb` | `#b8b2a4` | `#8f8a7e` |
| Piedra plaza / borde fuente | `#d8d3c6` | `#b8b2a4` | `#7f7a6e` |
| Agua | `#a8e6f0` | `#6fc7dd` | `#3f9fb8` |
| Madera banco/cerca | `#c98c4b` | `#a8683a` | `#7a4a26` |
| Paredes casa | `#f7f2e4` | `#e7dcc0` | `#c9bfa4` |
| Teja roja | `#e05c46` | `#c4463c` | `#9a3530` |
| Teja azul | `#5f8fd6` | `#4a6fb0` | `#34508a` |
| Teja fucsia | `#d972b5` | `#b55894` | `#8a3f6e` |
| Techos madera | `#d09a5f` | `#b0773f` | `#8a5a33` |
| Ventana noche cálida | `#ffdc8a` | `#f2b459` | `#c98a3c` |
| Campana/final | — (negro suave) | `#2e2b26` | — |

## Identidad por profesión (decals / banners / detalles)
| Profesión | Detalle de fachada / banner |
|---|---|
| Proveedor de alimentos | Cesta de hortalizas / toldo amarillo |
| Proveedor de agua | Barril / tonel junto a la puerta |
| Médico | Cruz verde-blanca en cartel |
| Constructor | Herramientas y tablas apoyadas |
| Policía | Escudo azul colgado |
| Político | Banner comunal (panfleto/lazo) |

Colores de agente (cuerpo/ropa) se mantienen legibles sobre el mapa, más saturados y diferenciados que la paleta ambiental.

## Convención de frames de personajes (Fase 2)
- Sprite sheet por personaje, frames **16×16** (dibujado hasta 12×15 efectiva), fila = dirección:
  - Fila 1: abajo · Fila 2: arriba · Fila 3: izquierda · Fila 4: derecha.
- 4 frames por dirección (idle es frame 1 de la fila de caminar, o 6 frames si se quiere parada explícita).
- Nombre de archivo: `char_<rol>.png` (rol en minúscula, sin acentos): `provider_alimentos`, `provider_agua`, `medico`, `constructor`, `policia`, `politico`.

## Convención de ficheros
- `tilesets/terrain_main.png`, `props/props_main.png`, `props/houses.png`...
- Nombres de archivo pastel en minúscula con `_`.
- Toda atribución de packs externos va en `assets/attribution/CREDITS.md`.
