# FASE 1 — Spec de Assets para Antigravity (estilo: mock "Plaza Mayor")

Generar los PNG siguientes (16×16 grid, alpha, paleta de `00_style_guide.md`). No generar mosaicos parcialmente aleatorios: cada tile debe empatalar con sus vecinos (sin costuras).

## terrain_main.png — 256×256 px (16×16 tiles)
Usa este orden en la grilla (celda = 16×16, fila/columna 0-indexed):

| Celda | Contenido |
|---|---|
| F0 C0–C2 | Césped base A / B / C (ruido sutil, sin objetos) |
| F0 C3–C5 | Césped con tréboles/flores pequeñas (decoración de suelo) |
| F1 C0–C2 | Camino adoquinado: tile interior, borde superior, borde lateral |
| F1 C3–C6 | Camino: esquinas interna/externa ×2 (4 tiles), transición césped-camino |
| F2 C0–C5 | Adoquín de plaza (piedra clara) + variaciones, incl. borde curvo |
| F2 C6–C7 | Agua (2 frames si se anima en F5) |
| F3 C0–C5 | Vereda (arcilla clara) interior/bordes/cruces |
| F3 C6–C7 | Reserva |

> Alternativa válida: entrega el atlas en cualquier orden **si además incluís un `terrain_index.png` (256×256) con letras/números por celda** para que yo mapee sin hacer adivinación visual.

## props_main.png — 256×128 px (16×16 tiles, piezas grandes dentro del atlas)
Columna 0 = celda de anclaje inferior. Piezas:
1. Árbol grande (32×48 px, ocupa 2×3 celdas) con copa y tronco.
2. Árbol frutal (32×40 px).
3. Arbusto (16×16) y arbusto con flores (16×16).
4. Flores aisladas (16×16, 2 variantes).
5. Banco de plaza (32×16).
6. Farola (16×32, luminaria de vidrio).
7. Jardinera con flores (16×16).
8. Cerca de madera (16×16, 2 variantes + esquina).
9. Pozo de plaza y tonel de madera (16×16, 2 piezas separadas).
10. Bolsa de canasta (opcional F5).

## houses.png — 480×128 px
Piezas sueltas (una por columna de 96×128), techo 5×5 tiles (80×80) + volado superior 16 px:
- Casa para cada profesión: **alimentos, agua, medico, constructor, policial, comunal**.
- Discriminado: paredes crema texturizadas, techa roja/azul/fucsia/madera según la casa, puerta, 2 ventanas con marcos, chimenea, decal de identidad según el style guide.
- Sombra interna en el borde inferior de la base (2–3 px).
- Deben empatar visualmente entre si (misma técnica, misma luz).

## Para Antigravity — prompts guías
```
16x16 pixel art top-down village tileset, cheerful RPG style, Referencia: Zelda Link's Awakening DX + Stardew Valley,
bright grass greens, warm cobblestone paths with light mortar, stone plaza tiles, no isometric, no light source,
transparent background, flat colors with 2-3 tone shading, no dithering, seamless tiles, grid aligned.
```
```
Pixel art top-down houses, cream textured walls, red/blue/fuchsia tiled roofs with ridge, wooden door, framed windows,
chimney, drop shadow inside bottom edge, transparent background, 96x128 canvas per house, 16px grid aligned.
```

## No hacer
- Sombra direccional global (se agrega el CanvasModulate + luces).
- Firmas, marcos, texto sobre el arte.
- Muy distorsión de perspectiva (top-down orthográfico, no isométrico).
- Tiles con juntas visibles entre sí (para empatalar sin costuras).
