# Auditoría inicial — Neighborhood AI / Cliente Godot

**Fecha:** 2026-11-12  
**Rama de trabajo:** `develope1`  
**Repositorio:** `damianportillo/client_godot_v1`  
**Base:** rama `main`  
**Estado:** auditoría estática preliminar; no se declara compilación ni ejecución verificada.

## 1. Alcance inspeccionado

Se revisaron en GitHub, sobre la rama `develope1`:

- `client_godot/project.godot`
- `client_godot/scenes/main.tscn`
- `client_godot/scenes/gui/hud_main.tscn`
- `client_godot/scripts/main.gd`
- `client_godot/scripts/world_sync.gd`
- `client_godot/scripts/lighting_manager.gd`
- `client_godot/scripts/agent_node.gd`
- `client_godot/scripts/gui/hud_main.gd`
- `client_godot/scripts/day_night_cycle.gd`
- `client_godot/scripts/terrain_builder.gd`
- `client_godot/scripts/graphics_optimizer.gd`
- `client_godot/scripts/tests/test_client_sync.gd`
- `client_godot/export_presets.cfg`
- Inventario de mapas, sprites de habitantes y carpetas de escenas/scripts.

La rama se creó correctamente desde `main`. No se modificó `main`.

## 2. Configuración observada

`project.godot` declara Godot 4.3, renderer GL Compatibility, viewport 960×540, override de ventana 1920×1080, stretch `canvas_items`, aspecto `keep`, filtro de textura `linear`, pixel snapping y un autoload `WorldSync`.

La escena principal carga `main.tscn`, y la escena contiene `MapBackground`, `World/TerrainBuilder`, `World/InteractiveLocations`, `World/Characters`, `LightingManager`, partículas ambientales y `HUDMain`.

Los presets existentes contemplan Windows Desktop y Android ARM64. La configuración de Android declara versión 0.10.0 y código 10.

## 3. Hallazgos prioritarios

### H-01 — Coordenadas de mundo aparentemente inconsistentes (ALTA)

- `main.gd` define ubicaciones lógicas para un viewport 960×540; por ejemplo, plaza (480,270) y casas en coordenadas como (140,140).
- `main.tscn` posiciona las áreas de interacción de casas/plaza en coordenadas como (940,670), (1580,930) y (1280,800).
- `terrain_builder.gd` declara un mundo procedural de 80×50 tiles de 16 px, es decir, 1280×800, y ubica la fuente alrededor de (640,400).
- `MapBackground` está configurado con tamaño 960×540.

Estas referencias no están en el mismo sistema de coordenadas a simple vista. Antes de corregir, hay que confirmar el layout pretendido, las dimensiones reales del mapa activo y la transformación de cámara. Después se debe unificar una única fuente de coordenadas para sprites, áreas clicables, luces, props y ubicaciones.

### H-02 — Pruebas de integración no coinciden con la escena/script actuales (ALTA)

`test_client_sync.gd` busca nodos y métodos como `World/Houses`, `HUD`, `format_clock_text()` y una estructura de HUD antigua. La escena inspeccionada usa `World/InteractiveLocations` y `HUDMain`; `main.gd` no expone `format_clock_text()`.

Esto indica que el test parece corresponder a una estructura anterior. No debe usarse como evidencia de que la versión actual pasa pruebas hasta reconciliar el test con la escena real y ejecutar Godot headless.

### H-03 — El HUD presenta información no respaldada por datos actuales (ALTA)

En `hud_main.gd`:
- El pensamiento del habitante se obtiene de textos fijos por profesión, no de un campo recibido del backend.
- La integridad estructural se muestra como 100 % y “Excelente” de forma fija.
- Los recursos almacenados de locación se muestran desde descripciones constantes.
- El contador de leyes tiene un texto inicial fijo y no se observa en este script una actualización desde un endpoint de leyes.

Esto contradice el principio de fuente única de verdad si se interpreta como información real del simulador. En la renovación deben distinguirse claramente los textos descriptivos de ambientación de los datos reales. No se deben presentar valores inventados como métricas vivas.

### H-04 — Sistema de optimización gráfica mayormente declarativo (MEDIA)

`graphics_optimizer.gd` describe culling, batching y optimización de shaders, pero los métodos principales contienen `pass` o solo mensajes de log. No aparece instanciado en `main.tscn` dentro de la escena revisada. No debe asumirse que esas optimizaciones están implementadas.

Se recomienda medir primero y luego implementar optimizaciones concretas y verificables, evitando añadir un gestor que prometa capacidades inexistentes.

### H-05 — Doble representación o HUD duplicado en la captura (MEDIA)

La captura proporcionada muestra una barra superior compacta y otra barra más grande superpuesta sobre el mapa. La escena actual inspeccionada instancia un `HUDMain`; la causa de la segunda barra no queda demostrada por los archivos revisados. Se debe rastrear si proviene del arte del mapa, otra escena, un build antiguo o una segunda instancia en ejecución antes de tocar el HUD.

### H-06 — Micro-movimiento local de habitantes (MEDIA)

`agent_node.gd` aplica deambulación local aleatoria alrededor de la ubicación base. Aunque puede ser solo una animación visual, debe verificarse que no contradiga la posición/actividad autoritativa del backend ni cause selección o presencia aparente en lugares incorrectos. La renovación debe mantener la posición de simulación como dato del backend y separar claramente la interpolación visual.

### H-07 — Configuración de URL de backend ligada a IP LAN (MEDIA)

`project.godot` y `world_sync.gd` contienen como valor predeterminado `http://192.168.0.61:8000`. La URL es configurable por plataforma desde ProjectSettings, lo cual es positivo, pero debe verificarse que los builds finales no dependan de una IP fija que no corresponda al entorno de destino. No cambiar la URL sin confirmar el servidor y la red de despliegue.

## 4. Riesgos y observaciones adicionales

- `main.gd` conserva un catálogo de ubicaciones y descripciones estáticas. Debe distinguirse configuración visual de estado simulado.
- `world_sync.gd` realiza polling REST cada segundo para reloj, habitantes, casas y eventos. El diseño de sincronización debe mantenerse estable durante la renovación; cualquier cambio requiere pruebas de regresión.
- `agent_node.gd` actualiza agentes recibidos, pero en el fragmento inspeccionado no se aprecia eliminación de nodos para habitantes que desaparezcan del snapshot. Debe revisarse el ciclo de vida y los casos de bajas.
- El gestor de iluminación usa posiciones hardcodeadas para faroles, ventanas y fuente. Esto amplifica el riesgo de desalineación al cambiar el mapa o sus dimensiones.
- Hay múltiples variantes de scripts con sufijos `_new` y `_complete`. Se debe comprobar cuáles están referenciadas y evitar editar archivos inactivos por error.
- Los sprites de roles existen en el inventario de assets; hay seis hojas declaradas por profesión. Su tamaño de archivo es muy pequeño y debe verificarse visualmente la resolución real, distribución de frames y consistencia del atlas antes de ampliar animaciones.

## 5. Decisiones de implementación

1. Preservar FastAPI como única autoridad del mundo.
2. No cambiar contratos REST/WebSocket ni lógica social en esta fase.
3. Resolver primero la fuente de coordenadas y la estructura de escena.
4. Reconciliar los tests con la implementación real antes de usarlos como gate.
5. Separar datos autoritativos, textos decorativos y estados transitorios de UI.
6. Determinar el origen de la barra duplicada de la captura.
7. No declarar optimizaciones sin medición antes/después.
8. Mantener todos los cambios en `develope1`, con commits pequeños y reversibles.

## 6. Próximos pasos obligatorios

- Completar inventario de escenas, recursos y variantes de scripts referenciadas.
- Revisar contratos y payloads reales de FastAPI para reloj, habitantes, casas y eventos.
- Identificar el mapa realmente renderizado y verificar dimensiones de las texturas.
- Reconciliar y ejecutar el conjunto de pruebas Godot.
- Obtener build base y capturas reproducibles en escritorio y Android.
- Presentar una línea base de FPS, memoria, tamaño de APK y errores.
- Corregir primero los defectos críticos que bloqueen la renovación visual.

## 7. Estado de validación

| Validación | Estado |
|---|---|
| Rama `develope1` creada desde `main` | Confirmada |
| Inspección estática de archivos principales | Realizada parcialmente |
| Ejecución Godot headless | Pendiente |
| Tests GDScript | Pendiente |
| Export Windows | Pendiente |
| Export Android | Pendiente |
| Instalación ADB y prueba en dispositivo | Pendiente |
| Regresión contra backend real | Pendiente |

**Importante:** esta auditoría se basa en lectura estática del contenido de GitHub. No afirma que el proyecto compile ni que los defectos enumerados se reproduzcan en ejecución. La siguiente etapa debe verificarlos en Godot antes de aplicar cambios funcionales.
