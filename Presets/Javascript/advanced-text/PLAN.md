# Advanced Text Object for ossia — Complete Implementation Plan

## Architecture Overview

Following the rect-mapper pattern: **two QML files** — `advanced-text.qml` (rendering Script) and `advanced-text.ui.qml` (editor ScriptUI), communicating via `executionSend()`/`uiEvent()`.

**Ports:**
- **TextureOutlet**: rendered text as texture for the visual pipeline
- **TextureInlet** (×1): optional image/video fill source for text masking
- **ValueInlet** `textContent`: dynamic text feed (OSC/data-driven)
- **ValueInlet** `textStyle`: JSON style override for live control
- **FloatSlider** `opacity`: master opacity (0–1)
- **FloatSlider** `writeOn`: write-on/reveal progress (0–1) for typewriter/reveal animation
- **HSVSlider** `colorOverride`: live color tint (useful for OSC/MIDI control)

---

## 1. Text Content

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Text | multiline string | — | Main text content |
| Read from ValueInlet | toggle | — | Use `textContent` inlet instead of static text |
| Text Transform | enum | None / UPPERCASE / lowercase / Title Case | Post-processing on content |

---

## 2. Font Properties

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Font Family | font picker | system fonts | Qt font database via `Qt.fontFamilies()` |
| Font File | file chooser | .ttf/.otf | Load custom font file directly |
| Font Style | enum | Regular/Bold/Italic/BoldItalic | From available styles in chosen family |
| Font Size | float | 1–2000 px | In pixels |
| Font Size Mode | enum | Pixels / Fraction of Height / Auto-Fit | Fraction = relative to output resolution |
| Faux Bold | bool | — | Synthetic bold when font has no bold variant |
| Faux Italic | bool | — | Synthetic italic |
| All Caps | bool | — | |
| Small Caps | bool | — | |
| Underline | bool | — | |
| Strikethrough | bool | — | |

---

## 3. Spacing & Layout

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Tracking | float | -200 – 500 | Uniform inter-character spacing (% of font size) |
| Leading / Line Spacing | float | 0.5 – 5.0 | Multiplier on default line height |
| Word Spacing | float | 0.5 – 5.0 | Multiplier on default word space |
| Horizontal Align | enum | Left / Center / Right / Justify | |
| Vertical Align | enum | Top / Center / Bottom | Within bounding box |
| Text Direction | enum | LTR / RTL / Auto | |
| Writing Mode | enum | Horizontal / Vertical | |
| Word Wrap | bool | — | Wrap within bounding box |
| Bounding Box Width | float | 0–1 | Fraction of output width (0 = no constraint) |
| Bounding Box Height | float | 0–1 | Fraction of output height (0 = no constraint) |

---

## 4. Fill & Color

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Fill Enabled | bool | — | |
| Fill Type | enum | Solid / Linear Gradient / Radial Gradient / Texture | |
| Fill Color | color (RGBA) | — | For solid fill |
| Gradient Start Color | color (RGBA) | — | |
| Gradient End Color | color (RGBA) | — | |
| Gradient Angle | float | 0–360° | For linear gradient |
| Gradient Mapping | enum | Full Text / Per Line / Per Word / Per Character | Where gradient spans |
| Texture Fill Source | int | 0 (from TextureInlet) | Use input texture as fill (text acts as mask) |
| Texture Fill Scale | vec2 | — | UV scale for texture fill |
| Texture Fill Offset | vec2 | — | UV offset for texture fill |

---

## 5. Stroke / Outline (up to 3 layers)

Three independently configurable outline layers, rendered inside-out:

| Property (per layer) | Type | Range/Options | Notes |
|---|---|---|---|
| Enabled | bool | — | |
| Color | color (RGBA) | — | Solid or gradient |
| Color Type | enum | Solid / Linear Gradient / Radial Gradient | |
| Width | float | 0–100 px | |
| Position | enum | Outside / Center / Inside | |
| Join Style | enum | Miter / Round / Bevel | |
| Softness | float | 0–50 px | Blur on the stroke edge |

---

## 6. Shadow (up to 2 layers)

Two independently configurable shadow layers:

| Property (per layer) | Type | Range/Options | Notes |
|---|---|---|---|
| Enabled | bool | — | |
| Color | color (RGBA) | — | |
| Offset X | float | -500 – 500 px | |
| Offset Y | float | -500 – 500 px | |
| Blur | float | 0–200 px | Gaussian blur radius |
| Spread | float | 0–100 px | Expand shadow before blur |
| Opacity | float | 0–1 | |

---

## 7. Background / Box

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Background Enabled | bool | — | |
| Background Color | color (RGBA) | — | |
| Background Scope | enum | Full Text / Per Line / Per Word | |
| Padding H / V | float | 0–200 px | Horizontal/vertical padding |
| Corner Radius | float | 0–100 px | Rounded corners |
| Border Enabled | bool | — | |
| Border Color | color (RGBA) | — | |
| Border Width | float | 0–20 px | |

---

## 8. Transform

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Position X | float | 0–1 | Fraction of output width |
| Position Y | float | 0–1 | Fraction of output height |
| Anchor | enum | Top-Left / Top-Center / ... / Center / ... / Bottom-Right | 9-point anchor |
| Rotation | float | -360 – 360° | Z-axis rotation |
| Scale X | float | 0.01 – 10 | Horizontal scale |
| Scale Y | float | 0.01 – 10 | Vertical scale |
| Skew X | float | -89 – 89° | Horizontal shear |
| Skew Y | float | -89 – 89° | Vertical shear |

---

## 9. Per-Character Animation

This is the "powerhouse" differentiator. Inspired by After Effects' text animators and Resolume's delay system, but adapted for ossia's timeline-driven + live-control model.

**Character Selector:**

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Scope | enum | Per Character / Per Word / Per Line | Unit of animation |
| Range Start | float | 0–1 | Which characters are affected (animated via timeline) |
| Range End | float | 0–1 | |
| Range Shape | enum | Square / Ramp Up / Ramp Down / Triangle / Smooth | Falloff shape at range edges |
| Range Smoothness | float | 0–1 | Edge softness |
| Order | enum | Forward / Reverse / Random / From Center / To Center | |
| Random Seed | int | — | For random order |
| Stagger / Delay | float | 0–1 | Time offset between successive characters (Resolume-style) |

**Per-Character Properties** (applied within the selector range):

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Position Offset X/Y | float | -500 – 500 px | |
| Rotation | float | -360 – 360° | |
| Scale | float | 0 – 5 | Uniform scale |
| Opacity | float | 0–1 | |
| Fill Color | color | — | Override per character |
| Blur | float | 0–50 | Per-character gaussian blur |
| Character Offset | int | — | Unicode shift (scramble effect) |

---

## 10. Write-On / Reveal

Controlled by the `writeOn` float inlet (0–1), making it trivially automatable from the ossia timeline or external control:

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Write-On Mode | enum | None / Typewriter / Fade / Scale / Slide / Scramble | |
| Write-On Direction | enum | Forward / Reverse / Random / From Center | |
| Write-On Scope | enum | Per Character / Per Word / Per Line | |
| Overlap | int | 1–50 | How many units animate simultaneously |
| Cursor Visible | bool | — | Show blinking cursor (typewriter mode) |
| Cursor Character | string | "▌" | Custom cursor glyph |
| Scramble Iterations | int | 1–20 | How many random characters before settling (for Scramble mode) |

---

## 11. Scrolling / Motion

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Scroll Mode | enum | None / Scroll Up / Scroll Down / Scroll Left / Scroll Right | |
| Scroll Speed | float | 0–1000 px/s | Speed in pixels per second |
| Scroll Sync | enum | Free / Beat-Synced | If beat-synced, use ossia transport |
| Loop | bool | — | Continuous scroll looping |
| Fade Edges | float | 0–0.5 | Fraction of edge to fade out (soft scroll edges) |

---

## 12. Wave Animation

Per-character sinusoidal wave animation driven by elapsed time:

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Enabled | bool | — | |
| Amplitude | float | 1–100 | Units depend on target property |
| Frequency | float | 0.1–20 Hz | |
| Property | enum | posY / posX / rotation / scale / opacity | Which property the wave drives |

---

## 13. Blend & Output

| Property | Type | Range/Options | Notes |
|---|---|---|---|
| Blend Mode | enum | Normal / Add / Multiply / Screen / Overlay / ... | Source blend mode for texture output |
| Premultiply Alpha | bool | — | |
| Output Resolution | enum | Auto / Custom | Auto = inherit from pipeline |
| Custom Width | int | — | |
| Custom Height | int | — | |
| Antialiasing | enum | 1× / 2× / 4× | Supersampling quality |

---

## 14. Presets & Styles (UI-side)

The UI panel should provide:

- **Style presets**: Save/load complete style configurations as JSON
- **Built-in presets**: ~10 common styles (Clean, Neon Glow, Cinematic Subtitle, Lower Third, Drop Shadow Title, Outline, Gradient Pop, Glitch, Retro, Minimal)
- **Live preview** in the editor panel
- **Copy/paste style** between instances

---

## Implementation Phases

### Phase 1 — Core (MVP) ✅ DONE
- Text content, font properties (family, size, style, bold, italic, underline, strikethrough)
- Fill: solid color + linear/radial gradient
- Single stroke/outline (color, width, join style)
- Single shadow (color, offset X/Y, blur, opacity)
- Background box (color, opacity, padding H/V, corner radius)
- Transform (position, rotation, scale, skew, anchor H/V)
- Word wrap, alignment (H+V), bounding box, line spacing, tracking
- Opacity (design-time + inlet)
- Font selector (editable ComboBox with `Qt.fontFamilies()`)
- Color selector (native ColorDialog + hex TextField)
- Palette-aware UI (Pane with ossia dark palette)

### Phase 2 — Animation ✅ DONE
- Write-on/reveal with 5 modes (typewriter, fade, scale, slide, scramble)
- Write-on direction (forward, reverse, fromCenter, random)
- Write-on overlap control (1–50 simultaneous characters)
- Blinking typewriter cursor
- Scrolling (up/down/left/right, speed, loop, fade edges)
- Per-character wave animation (posY, posX, rotation, scale, opacity)
- Elapsed time tracking for time-based animations
- Continuous repaint when animations active
- Underline/strikethrough working correctly with all write-on modes

### Phase 3 — Advanced ✅ DONE (partial)
- ✅ Multiple stroke layers (up to 3)
- ✅ Multiple shadow layers (up to 2)
- ✅ Full per-character animation (position, rotation, scale, opacity, color, character offset)
- ✅ Stagger/delay model (Resolume-style cascade with scope/order/delay)
- ✅ Gradient mapping scope (full text / per line / per word / per character)
- ✅ Background scope (full text / per line)
- ✅ Background border (color, width)
- ⏭️ Style presets system — skipped (ossia has built-in preset system)
- ✅ Texture fill from TextureInlet (text as mask over video/image via Canvas compositing)
- 🔲 Beat-synced scrolling via ossia transport

---

## Key Design Decisions

1. **All animatable properties exposed as inlets** — ossia's strength is its timeline and external control (OSC/MIDI). Every numeric property should be controllable via inlets, not just internal state. The `writeOn` slider is a prime example: one float drives the entire reveal animation.

2. **Gradient mapping scope** (Full Text / Per Line / Per Word / Per Character) — borrowed from DaVinci's shading system, this is surprisingly impactful for visual variety from a single gradient definition.

3. **Stagger/Delay model** from Resolume rather than After Effects' selector model — Resolume's approach of "every parameter change automatically cascades across characters with a delay" is more intuitive for live/real-time use than AE's complex multi-selector stack.

4. **Texture fill via TextureInlet** — this enables the text to act as a mask over video/generative content, which is a very common VJ/live visual technique and trivial to wire in ossia's node graph.

5. **Scrolling built-in** rather than requiring an external transform node — credit rolls and tickers are so common that having them as a first-class mode avoids repetitive setup.

6. **No 3D extrusion** — this belongs in a separate dedicated 3D text node (using Qt Quick 3D), not in this 2D text powerhouse. Keep this object focused on 2D text rendering excellence.

7. **Canvas 2D rendering** — chosen over Qt Quick Text element for full control over per-character transforms, gradient fills, multi-pass rendering (shadow → stroke → fill), and tracking. The fast line-by-line path is preserved for static text performance.

8. **Two rendering paths** — Fast line-by-line path for static/typewriter text, per-character path activated only when needed (fade/scale/slide/scramble modes, wave animation). This keeps performance optimal for the common case.

---

## Research Sources

Feature set informed by analysis of:
- **DaVinci Resolve Text+**: 8-layer shading system, text-on-path, Write On range, OpenType features
- **Adobe Premiere Pro**: Multiple strokes/shadows, linear/radial gradients, background box with corners
- **Adobe After Effects**: Per-character 3D transforms, Range/Wiggly/Expression selectors, text animators
- **Vegas Pro**: Deformation effects, credit roll generator, animation presets
- **OBS Studio**: Read-from-file, chatlog mode, text transform (caps)
- **TouchDesigner**: Specification DAT, independent X/Y sizing, 35+ blend modes, HDR color spaces
- **Resolume Arena**: BPM-synced delay animation, per-character cascade, neon glow effects
