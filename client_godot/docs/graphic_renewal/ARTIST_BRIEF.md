# Brief Ejecutivo — Renovación Gráfica FASE 2

## 📋 Información General

**Cliente:** Antigravity Studio  
**Proyecto:** Neighborhood AI  
**Fase:** Renovación Gráfica (Personajes)  
**Fecha:** 11 de noviembre de 2026  

---

## 🎯 Entregables Esperados

| Archivo | Tamaño | Descripción |
|---------|--------|-------------|
| `char_alimentos.png` | 64×64 px | Proveedor de Alimentos (Mateo Rossi) |
| `char_agua.png` | 64×64 px | Proveedor de Agua (Sofía Benítez) |
| `char_medico.png` | 64×64 px | Médico (Lucas Morales) |
| `char_constructor.png` | 64×64 px | Constructor (Diego Navarro) |
| `char_policia.png` | 64×64 px | Policía (Valeria Castro) |
| `char_politico.png` | 64×64 px | Político (Camila Méndez) |

**Total:** 6 archivos PNG × 64×64 px = 384 KB aprox.

---

## 📁 Ubicación de Entrega

```
client_godot/assets/characters/
├── char_alimentos.png
├── char_agua.png
├── char_medico.png
├── char_constructor.png
├── char_policia.png
└── char_politico.png
```

---

## ⚙️ Especificaciones Técnicas

- **Formato:** PNG con fondo transparente (alpha puro)
- **Dimensiones:** 64×64 píxeles exactos por archivo
- **Estilo:** Pixel art chibi, contorno negro grueso (#1A1A1A)
- **Grilla interna:** 16×16 px por frame (4×4 frames totales)
- **Layout:** Fila 1=abajo, Fila 2=arriba, Fila 3=izquierda, Fila 4=derecha

---

## 📖 Referencias Visuales

| Documento | Ruta |
|-----------|------|
| Mock oficial (paleta + estilo) | `client_godot/examples/Plaza Mayor_ Comunidad en Calma.png` |
| Propuesta aprobada FASE 2 | `builds/fase2_personajes_propuesta.png` |
| Preview animado | `builds/fase2_preview_chars.png` |

---

## 📋 Checklist de Calidad

- [ ] Dimensiones exactas: 64×64 px por archivo
- [ ] Fondo completamente transparente
- [ ] Contorno negro grueso en todos los personajes
- [ ] Nombres de archivo coinciden con `ROLE_SHEETS` en `agent_node.gd`
- [ ] Las 4 direcciones × 4 frames organizados correctamente
- [ ] Estilo pixel art puro (sin filtros, sin gradientes)

---

## 📞 Proceso de Entrega

1. **Revisión inicial:** 48 horas para correcciones
2. **Iteración máxima:** 1 ciclo de revisión permitido
3. **Formato de entrega:** ZIP o Google Drive compartido
4. **Nombre del archivo:** `fase2_personajes_antigravity.zip`

---

## 🧪 Validación Post-Entrega

El cliente realizará:

1. Test visual en PC (`preview_characters.tscn`)
2. Test headless GDScript (`backend/tests/test_client_sync.py`)
3. Pruebas Android (legibilidad nocturna + animación)

---

## 📄 Documentación Adicional

- Especificación técnica completa: `FASE2_assets_spec.md`
- Guía de estilo del proyecto: `00_style_guide.md`
- Estado del proyecto: `STATUS.md`

---

**Documento generado por:** Damian (Neighborhood AI)  
**Versión:** 1.0  
**Contacto:** backend@neighbourhood.ai
