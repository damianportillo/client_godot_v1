# Auditoría técnica inicial — Neighborhood AI (Godot)

**Fecha:** 12 de noviembre de 2026  
**Rama de trabajo:** `develope1`  
**Repositorio:** `damianportillo/client_godot_v1`  
**Alcance revisado:** configuración Godot, escena principal, sincronización, habitantes, iluminación, HUD, terreno, exportación y prueba de integración disponible.

> Este documento registra hallazgos por inspección estática de los archivos de la rama. No representa una ejecución del proyecto: en esta sesión no se dispuso de un runtime Godot, Android SDK/ADB ni backend conectado para ejecutar pruebas o generar builds.

## 1. Resumen

La rama de trabajo existe y contiene el proyecto Godot bajo `client_godot/`. La arquitectura declarada es adecuada como punto de partida: Godot consume el estado del backend y presenta habitantes, ubicaciones, reloj y eventos. Sin embargo, la inspección encontró inconsistencias que conviene resolver antes de una renovación visual extensa.

**Prioridad inmediata:** corregir y probar la coherencia de coordenadas entre mapa, escena, agentes, áreas interactivas e iluminación; actualizar la suite de pruebas para que describa la escena real; y separar datos reales del backend de textos demostrativos del HUD.

## 2. Hallazgos verificados por lectura de código

### H-01 — Sistemas de coordenadas inconsistentes (crítico)

Archivos:
- `client_godot/project.godot`
- `client_godot/scenes/main.tscn`
- `client_godot/scripts/main.gd`
- `client_godot/scripts/lighting_manager.gd`
- `client_godot/scripts/terrain_builder.gd`

Evidencia:
- El viewport está configurado en 960×540.
- `main.tscn` asigna al fondo del mapa un tamaño de 960×540 y usa `neighborhood_map_960.png`.
- `main.gd` define ubicaciones como plaza (480,270), casa_1 (140,140), casa_3 (780,400), entre otras.
- En `main.tscn`, las áreas interactivas aparecen en posiciones como plaza (1280,800), casa_1 (940,670), casa_3 (1580,930), huerto (1000,730) y manantial (1220,770).
- `lighting_manager.gd` utiliza otra serie de posiciones (por ejemplo, plaza/fuente en 480,270 y ventanas de casas entre 140,100 y 780,400).
- `terrain_builder.gd` genera 80×50 celdas de 16 px (1280×800), mientras el fondo está declarado como 960×540.

Impacto probable: habitantes, luces, colisiones y puntos de interés pueden no coincidir con los elementos dibujados; parte de las áreas puede quedar fuera del encuadre o responder en una posición distinta a la esperada.

Acción: definir un único sistema de coordenadas de mundo, documentar escala y origen del arte, y derivar todas las posiciones desde un catálogo común. No aplicar un multiplicador global hasta verificar dimensiones y composición de cada mapa.

### H-02 — Prueba de integración desactualizada respecto de la escena actual (crítico)

Archivo: `client_godot/scripts/tests/test_client_sync.gd`

La prueba busca:
- `World/Houses`, pero la escena actual contiene `World/InteractiveLocations`.
- `HUD`, pero la instancia actual se llama `HUDMain`.
- Rutas del HUD como `TopBar/TimeLabel`, mientras el HUD actual usa `TopBar/HBox/ClockContainer/TimeLabel`.
- Métodos como `main_instance.format_clock_text()`, que no aparecen en el `main.gd` revisado.

Impacto: la prueba no representa la estructura real y no puede considerarse evidencia fiable de regresión hasta actualizarla. La cantidad de pruebas históricas mencionada en el resumen ejecutivo no sustituye una ejecución actual.

Acción: rehacer las pruebas sobre la escena y API actuales, separar pruebas unitarias de integración HTTP, y ejecutar Godot headless para obtener una línea base reproducible.

### H-03 — HUD mezcla métricas dinámicas con contenido estático o demostrativo (alto)

Archivos:
- `client_godot/scripts/gui/hud_main.gd`
- `client_godot/scenes/gui/hud_main.tscn`

Evidencia:
- Se declara `laws_label`, pero el script revisado no lo actualiza.
- La lista de ordenanzas de `LawsList` y el resumen de la comunidad están escritos directamente en la escena.
- `loc_integrity` se muestra como 100 % sin obtener ese valor del backend.
- El pensamiento del habitante se genera mediante textos por profesión, no desde un campo real del payload.
- Los valores de ejemplo del HUD pueden dar la impresión de ser métricas actuales.

Impacto: el usuario puede interpretar información de muestra como estado real del mundo.

Acción: clasificar cada campo como dato API, cálculo derivado permitido o placeholder. Los placeholders deben eliminarse de la interfaz de producción o identificarse explícitamente como no disponibles. No inventar datos que el backend no entregue.

### H-04 — Presencia de habitantes en ubicaciones puede no resolverse correctamente (alto)

Archivo: `client_godot/scripts/gui/hud_main.gd`

El inspector de ubicación compara `current_location` con la clave visual (`casa_1`, etc.). El cliente resuelve las ubicaciones de vivienda mediante `casa_<UUID>` y un mapa UUID → número de casa en `main.gd`; el inspector del HUD no reutiliza esa resolución. Por eso la lista de presentes puede quedar vacía en viviendas aunque el habitante esté allí.

Acción: centralizar la resolución de ubicación y usarla tanto para posicionamiento como para inspección. Conservar el UUID como identidad del recurso y no inferir presencia a partir de nombres parciales.

### H-05 — Polling REST muy frecuente y sin política visible de backoff (medio)

Archivo: `client_godot/scripts/world_sync.gd`

El cliente consulta cuatro endpoints (`/api/clock`, `/api/characters`, `/api/houses`, `/api/events`) cada segundo. Ante errores, vuelve a intentar con el mismo intervalo; no se observa backoff exponencial ni diferenciación de frecuencia por tipo de dato.

Acción: medir carga y latencia antes de cambiarlo. Después, introducir una política conservadora de reintentos/backoff y evitar solicitudes solapadas, manteniendo intactos los contratos y la autoridad del backend.

### H-06 — Optimizador gráfico contiene funciones declaradas pero no implementadas (medio)

Archivo: `client_godot/scripts/graphics_optimizer.gd`

Las rutinas de culling y optimización de shaders terminan en `pass`; los métodos de compresión, batching y validación se limitan principalmente a mensajes. El control de calidad ajusta un nivel interno, pero `_apply_quality_settings()` solo imprime el nivel.

Acción: no tratar este script como optimizador operativo. Medir primero el perfil real; implementar únicamente optimizaciones comprobables y retirar o renombrar las opciones que no hacen lo que anuncian.

### H-07 — Los sprites de habitantes son recursos extremadamente pequeños; validar atlas y animaciones (medio)

Archivos: `client_godot/scripts/agent_node.gd`, `client_godot/assets/characters/`

El script construye atlas de celdas 16×16 y espera cuatro filas direccionales y cuatro columnas para caminar. Los recursos listados tienen tamaños de archivo inferiores a 1 KB, lo cual no determina por sí solo sus dimensiones reales. Deben verificarse dimensiones, transparencia, orden de frames y legibilidad en el dispositivo.

Acción: inspeccionar los PNG originales y validar que cada spritesheet cumple exactamente el contrato de atlas. No asumir que un archivo pequeño es defectuoso sin medir sus dimensiones.

### H-08 — Configuración de exportación y endpoints requieren saneamiento (alto)

Archivos:
- `client_godot/export_presets.cfg`
- `client_godot/project.godot`
- `client_godot/scripts/world_sync.gd`

Evidencia:
- Los presets exportan Windows y Android, pero el preset Android referencia una ruta local de keystore de depuración en el equipo del desarrollador.
- Las URLs Android y Desktop se encuentran fijadas a una IP LAN concreta en `project.godot`, y los fallbacks del script repiten esa dirección.
- El preset Android declara versión 0.10.0 y código 10.

Acción: verificar configuración de firma y exportación en un entorno autorizado; no publicar secretos ni depender de una ruta local personal. Mantener endpoints configurables por entorno y documentar el procedimiento de despliegue.

## 3. Cambios aplicados en `develope1`

Los siguientes cambios ya están guardados en la rama:

1. **Áreas interactivas:** las nueve áreas de la escena (`casa_1` a `casa_6`, plaza, huerto y manantial) se alinearon con las coordenadas correspondientes de `main.gd`. Esto corrige las posiciones anteriores que quedaban fuera del mapa de 960×540.
2. **Prueba de estructura:** se actualizó para comprobar `World/InteractiveLocations`, `HUDMain` y las rutas reales del HUD. También comprueba que cada área interactiva coincide con el catálogo de coordenadas.
3. **Prueba del reloj:** se eliminó la llamada a `format_clock_text()` en el controlador principal, método que no existe. Ahora se comprueba el método real del HUD y la extracción de hora del ciclo día/noche.
4. **Inspector de ubicación:** se agregó la normalización de ubicaciones `casa_<UUID>` del backend a `casa_<número>` usando el catálogo sincronizado de viviendas.
5. **Datos no disponibles:** el HUD dejó de presentar una integridad estructural ficticia de 100 % y dejó de inventar pensamientos según la profesión. Ahora indica que esos datos no están disponibles cuando el backend no los entrega.

**Estado de validación:** los cambios están confirmados mediante commits de GitHub, pero todavía requieren ejecución con Godot 4.3. No se afirma que las pruebas hayan pasado.

## 4. Riesgos y límites de esta auditoría

1. No se ejecutó el editor ni el motor Godot.
2. No se ejecutó `test_client_sync.gd`.
3. No se generaron APK ni ejecutables.
4. No se comprobó conectividad con FastAPI ni se consultaron payloads en vivo.
5. No se verificó el comportamiento en el dispositivo Android.
6. Los PNG no se inspeccionaron píxel a píxel en esta auditoría estática.
7. No se modificó el backend ni su base de datos.

Por tanto, los impactos descritos son conclusiones estáticas o riesgos probables, no resultados de pruebas de ejecución.

## 5. Orden recomendado de trabajo

| Orden | Trabajo | Criterio de salida |
|---|---|---|
| 1 | Establecer dimensiones y coordenadas canónicas del mundo | Fondo, terreno, casas, puntos, agentes y luces coinciden |
| 2 | Corregir escena y selección/interacción | Todos los puntos de interés responden en su posición visual |
| 3 | Actualizar pruebas de escena, contratos y ubicación | Pruebas ejecutables y alineadas con los nodos reales |
| 4 | Corregir inspector y separar datos reales/placeholders | Ningún valor ficticio se presenta como métrica real |
| 5 | Revisar sincronización y estados de conexión | Sin solicitudes solapadas; reintentos medidos y robustos |
| 6 | Renovar dirección artística, habitantes y entorno | Calidad visual consistente y validada en capturas |
| 7 | Renovar HUD y paneles | Legibilidad en 960×540, Full HD y móvil |
| 8 | Perfilar y optimizar | Objetivos de FPS/memoria medidos en dispositivos reales |
| 9 | Exportar y validar Windows/Android | Builds reproducibles y pruebas funcionales documentadas |

## 6. Regla de cambios

Los cambios se realizan exclusivamente en `develope1`. `main` se mantiene intacta durante el trabajo. Cada bloque debe tener commits pequeños, pruebas y una descripción de impacto. No se modificarán lógica social, decisiones de IA, persistencia ni contratos del backend sin una autorización específica adicional.

## 7. Próximo paso técnico

Comenzar por H-01 y H-02: construir un mapa de coordenadas verificable a partir de las dimensiones reales de los recursos y corregir las pruebas para que validen la escena que realmente se exporta. Antes de una renovación artística masiva, generar una build de referencia y capturas diurna/nocturna en el entorno de ejecución real.
