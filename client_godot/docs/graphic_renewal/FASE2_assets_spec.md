# Especificación de Assets — Renovación Gráfica FASE 2 (Personajes)

## 📌 Resumen Ejecutivo

**Proyecto:** Neighborhood AI - Renovación Gráfica  
**Cliente:** Antigravity Studio  
**Entregable:** Spritesheets de personajes para drop-in replace  
**Tamaño total:** 6 archivos PNG × 64×64 px = 384×64 px por archivo  

---

## 🎯 Objetivo

Generar arte final de personajes en estilo **pixel art chibi** que reemplace los placeholders procedurales actuales (`scripts/generate_placeholder_art.py`) mediante **drop-in replace** sin modificar ningún archivo `.tscn` o `.gd`.  

Los nuevos spritesheets deben ser idénticos en estructura y dimensiones a los actuales para garantizar compatibilidad inmediata con el motor Godot v4.3.

---

## �� Especificaciones Técnicas (Innegociables)

### Dimensiones
- **Tamaño por archivo:** 64×64 píxeles  
- **Formato:** PNG con fondo transparente (alpha puro)
- **Grilla base:** 16×16 px por frame (4×4 frames = 64×64)

### Layout de Frames
Cada sprite sheet contiene **4 direcciones × 4 frames** organizados en una grilla única:

```
┌─────────────────────────────┐
│  Fila 1: DIRECCIÓN ABAJO    │
│  [idle_down] [walk_0]       │
│  [walk_1]   [walk_2]        │
├─────────────────────────────┤
│  Fila 2: DIRECCIÓN ARRIBA   │
│  [idle_up]  [walk_3]        │
│  [walk_4]   [walk_5]        │
├─────────────────────────────┤
│  Fila 3: DIRECCIÓN IZQUIERDA│
│  [idle_left][walk_6]        │
│  [walk_7]   [walk_8]        │
├─────────────────────────────┤
│  Fila 4: DIRECCIÓN DERECHA  │
│  [idle_right][walk_9]       │
│  [walk_10][walk_11]         │
└─────────────────────────────┘
```

**Nota:** Los frames de `idle` usan el frame 0 de cada fila como referencia (estilo walk pero estático).

### Convención de Nombres de Archivo
Nombres en minúscula, sin acentos:

| Nombre del Archivo | Profesión (Español) |
|-------------------|---------------------|
| `char_alimentos.png` | Proveedor de Alimentos |
| `char_agua.png` | Proveedor de Agua |
| `char_medico.png` | Médico |
| `char_constructor.png` | Constructor |
| `char_policia.png` | Policía |
| `char_politico.png` | Político |

---

## 🎨 Personajes - Especificación Individual

### 1. Proveedor de Alimentos (Masculino)

**Nombre:** Mateo Rossi  
**Género:** Masculino  
**Personalidad:** Cálido, generoso, paciente  

#### Vestimenta Característica:
- **Sombrero:** Paja amarillo brillante (#FFD700), ancho ~24px, con sombra inferior
- **Delantal:** Verde medio (#78BD4F), cubre torso principal
- **Piel:** Tono cálido medio (#E8C4A0)
- **Rostro:** Sonrisa amplia, ojos simples negros, expresión amigable

#### Detalles Técnicos:
```
Pelo: Marrón oscuro (#5C4033), corto y despeinado (~12px alto)
Ojos: Dos cuadrados negros (#1A1A1A) de 4×4 px, separados 8px
Boca: Rectángulo curvo negro en línea inferior del rostro
Contorno: Borde negro grueso (#1A1A1A) de 1-2px alrededor de toda la figura
```

---

### 2. Proveedor de Agua (Femenino)

**Nombre:** Sofía Benítez  
**Género:** Femenino  
**Personalidad:** Amable, cuidadosa, tranquila  

#### Vestimenta Característica:
- **Gorro:** Azul claro (#6FC7DD), cilíndrico, ~12px alto
- **Bata:** Celeste suave (#6FC7DD) con mangas amplias
- **Piel:** Tono cálido medio (#E8C4A0)
- **Rostro:** Expresión serena, ojos almendrados, sonrisa sutil

#### Detalles Técnicos:
```
Pelo: Marrón claro (#D2B48C), recogido en moño (~8px superior)
Ojos: Forma almendrada 6×4 px con párpados definidos
Contorno: Borde negro grueso (#1A1A1A) uniforme
```

---

### 3. Médico (Masculino)

**Nombre:** Lucas Morales  
**Género:** Masculino  
**Personalidad:** Compasivo, atento, profesional  

#### Vestimenta Característica:
- **Bata:** Blanca pura (#FFFFFF) con cruz verde médica
- **Cruz:** Verde brillante (#78BD4F), tamaño ~12×12 px en pecho izquierdo
- **Piel:** Tono medio claro (#FFDAB9)
- **Rostro:** Expresión concentrada, cejas ligeramente fruncidas

#### Detalles Técnicos:
```
Pelo: Marrón oscuro (#5C4033), corto y liso (~16px alto)
Gafas: Opcional - dos rectángulos negros sobre ojos (consultar mock)
Cruz médica: Verde (#78BD4F) en posición pecho izquierdo
Contorno: Borde negro grueso (#1A1A1A), bata blanca sin contorno externo
```

---

### 4. Constructor (Masculino)

**Nombre:** Diego Navarro  
**Género:** Masculino  
**Personalidad:** Pragmático, trabajador, decidido  

#### Vestimenta Característica:
- **Casco:** Naranja intenso (#FF8C00) con visera frontal
- **Camisa:** Anaranjada (#FFA500) con mangas largas
- **Piel:** Tono medio oscuro (#D2B48C)
- **Rostro:** Sudor visible, ojos entrecerrados (expresión de trabajo)

#### Detalles Técnicos:
```
Pelo: Marrón oscuro (#5C4033), visiblemente sudado (~14px alto)
Casco: Naranja (#FF8C00) con visera negra proyectando sombra
Herramientas: Opcional - martillo o llave inglesa en mano derecha
Contorno: Borde negro grueso (#1A1A1A), casco con contorno completo
```

---

### 5. Policía (Femenino)

**Nombre:** Valeria Castro  
**Género:** Femenino  
**Personalidad:** Firme, justa, protectora  

#### Vestimenta Característica:
- **Gorra:** Azul marino (#0077B6) con insignia dorada
- **Uniforme:** Azul oscuro (#005A87) con botones plateados
- **Piel:** Tono medio claro (#E8C4A0)
- **Rostro:** Expresión seria y autoritaria, cejas rectas

#### Detalles Técnicos:
```
Pelo: Marrón oscuro (#5C4033) corto bajo gorra (~10px visible)
Insignia: Dorada (#FFD700) en frente de la gorra, ~8×8 px
Botones: Plateados (#C0C0C0) en línea vertical del uniforme
Contorno: Borde negro grueso (#1A1A1A), insignias con detalle dorado
```

---

### 6. Político (Femenino)

**Nombre:** Camila Méndez  
**Género:** Femenino  
**Personalidad:** Carismática, firme, visionaria  

#### Vestimenta Característica:
- **Traje:** Fucsia vibrante (#FF006E) con solapas definidas
- **Blusa:** Blanca (#FFFFFF) bajo el traje
- **Piel:** Tono medio claro (#E8C4A0)
- **Rostro:** Expresión confiada, sonrisa amplia y segura

#### Detalles Técnicos:
```
Pelo: Gris plateado (#D3D3D3), corto y ondulado (~16px alto)
Blusa: Blanca pura visible bajo solapas del traje fucsia
Accesorio: Opcional - collar o broche en cuello (~6×6 px)
Contorno: Borde negro grueso (#1A1A1A), solapas con sombra interna
```

---

## 🎨 Paleta de Colores Oficial

### Personajes (Prioridad Alta)
| Color | Uso | Hexadecimal |
|-------|-----|-------------|
| Blanco puro | Piel muy clara / botones / insignias | `#FFFFFF` |
| Piel media clara | Tonos piel base femeninos | `#E8C4A0` |
| Piel media cálido | Tonos piel base masculinos | `#D2B48C` |
| Marrón oscuro | Pelo castaño / cabello | `#5C4033` |
| Negro | Contorno grueso / pupilas / detalles | `#1A1A1A` |
| Amarillo paja | Sombrero alimentos | `#FFD700` |
| Verde medio | Delantal médico / proveedor alimentos | `#78BD4F` |
| Celeste | Bata proveedor agua | `#6FC7DD` |
| Naranja intenso | Casco constructor | `#FF8C00` |
| Anaranjado | Camisa constructor | `#FFA500` |
| Azul marino | Uniforme policía | `#0077B6` |
| Azul oscuro | Pantalón / uniforme | `#005A87` |
| Fucsia vibrante | Traje político | `#FF006E` |
| Blanco bata | Médico | `#FFFFFF` |
| Gris plateado | Pelo político femenino | `#D3D3D3` |

### Contorno Universal
- **Negro grueso:** `#1A1A1A` - aplicarse a TODOS los personajes para consistencia visual

---

## 🖼️ Referencias Visuales

### Mock Oficial (FASE 1)
**Ubicación:** `client_godot/examples/Plaza Mayor_ Comunidad en Calma.png`  
**Uso:** Definición de paleta ambiental y estilo global del juego

### Propuesta Aprobada FASE 2 (Personajes)
**Ubicación:** `builds/fase2_personajes_propuesta.png`  
**Contenido:** Los 6 personajes con nombres reales, vestimenta y expresiones aprobadas  
**Uso:** Referencia EXACTA de diseño final para el artista

### Preview Animado (Validación de Movimiento)
**Ubicación:** `builds/fase2_preview_chars.png`  
**Contenido:** Los personajes en contexto con UI visible  
**Uso:** Verificar legibilidad sobre fondo verde/azul

---

## 📋 Checklist de Entrega

Antes de entregar los archivos, verificar:

- [ ] Todos los archivos son exactamente **64×64 px** (sin márgenes)
- [ ] Fondo completamente transparente en todos los archivos
- [ ] Contorno negro grueso aplicado a TODOS los personajes
- [ ] Cada personaje tiene las 4 direcciones × 4 frames organizados correctamente
- [ ] Nombres de archivo coinciden exactamente con `ROLE_SHEETS` en `agent_node.gd`
- [ ] Estilo pixel art puro (sin filtros, sin gradientes suaves)
- [ ] Personajes anclados en los pies (no flotando)

---

## 📂 Ubicación Final de Assets

Los archivos generados deben colocarse en:

```
client_godot/assets/characters/
├── char_alimentos.png      ← Proveedor de Alimentos
├── char_agua.png           ← Proveedor de Agua
├── char_medico.png         ← Médico
├── char_constructor.png    ← Constructor
├── char_policia.png        ← Policía
└── char_politico.png       ← Político
```

**Importante:** NO tocar archivos en `client_godot/scenes/` - solo reemplazar assets.

---

## 🧪 Pruebas de Validación

Tras la entrega, se realizará:

1. **Test visual PC:** Ejecutar `client_godot/scenes/preview_characters.tscn`
2. **Test headless GDScript:** Ejecutar `backend/tests/test_client_sync.py`
3. **Test Android:** Instalación APK y verificación de legibilidad nocturna + animación

---

## 📞 Contacto y Entrega

**Entregable final:** ZIP con 6 archivos PNG + este documento  
**Nombre del archivo:** `fase2_personajes_antigravity.zip`  
**Revisión:** 48 horas para correcciones (máximo 1 iteración)  
**Formato preferido:** ZIP o Google Drive compartido

---

## 🔗 Referencias Adicionales

- Guía de estilo completa: `client_godot/docs/graphic_renewal/00_style_guide.md`
- Especificación FASE 1 (escenario): `client_godot/docs/graphic_renewal/FASE1_assets_spec.md`
- STATUS.md del proyecto: `STATUS.md`

---

**Documento generado para:** Antigravity Studio  
**Fecha:** 11 de noviembre de 2026  
**Versión:** 1.0 (Aprobado por Damian)
