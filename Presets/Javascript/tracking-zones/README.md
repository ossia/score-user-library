# Tracking Zones

A complete 2D / 3D **tracking-zone** tool for ossia score: draw areas, volumes, tripwires and paths
over a tracked space, feed it people / objects from any tracking source, and get per-zone
state, events and per-entity data out — with a full editor (top view, 3D view, inspector,
sources & calibration, simulator, recorder, monitor).

It is a Javascript process (`tracking-zones.qml` + `tracking-zones.ui.qml`): drop the `.qml`
from the Library (*Presets › Javascript › tracking-zones*) on an interval, open **Show UI**.

## Ports

| Inlet | Type | What to connect |
|---|---|---|
| `Source 1` … `Source 4` | value | any tracking data (see *Inputs*): a single source, **or several sources at once** as a map `{name: payload}` (e.g. bind the inlet to a device container like `local:/tracking` with one child per sensor). Every source arriving on an inlet shares that inlet's calibration card, and its entity ids are prefixed with the sub-source name. Group sensors of the same kind per inlet: inlet 1 camera boxes, inlet 2 centroid tracking, inlet 3 BlackTrax... |
| `Command` | value | `"reset"`, `"clear"`, `"set:<name>"`, or maps: `{cmd:"doc", doc:<json or map>}` (load zones), `{cmd:"set", value:"act2"}`, `{cmd:"enable", zone:"Door", value:false}`, `{cmd:"reset", zone:"Lounge"}`, `{cmd:"ui", action:…}` (drive the editor) |
| `Active Set` | line edit | overrides the active zone set when non-empty (automatable) |
| `Bypass` | toggle | stop evaluating |
| `Simulation` | toggle | inject the editor's virtual entities (dummies / walkers) as source 5 |
| `Reset Counters` | impulse | reset crossings / visits / unique / dwell max / heatmap |

| Outlet | Type | Content |
|---|---|---|
| `Zones` | list of maps | one map per zone: `id, name, type, active, occupied, count, ids[], all_ids[], entered[], exited[], first_in, last_out, centroid (vec3), nearest, nearest_dist, activity (mean speed), weight (soft zones), idle, occupied_for, dwell_now, dwell_max, dwell_mean, crossings_in, crossings_out, crossings, visits, unique, per_id[{id,u,v,w,r,angle,dist,dwell,progress,offset,weight,speed,pos}]` |
| `Events` | list of maps | only on ticks with events: `{t, type, zone, zone_id, id, src, …}` with type ∈ `enter, exit(dwell, lost), dwell, cross(direction,in,out), occupied, empty, first_in, last_out, count(count,previous), capacity(over), stationary, transition(from[]), proximity(other,dist,state,duration)` |
| `Entities` | list of maps | every tracked entity after calibration: `id, key, src, pos (vec3), vel (vec3), speed, conf, cls, name, state, age, height, heading, stationary, masked, zones[], zone_data{zoneName:{u,v,w,dist,dwell,progress,offset,weight}}` |
| `Counts` / `Occupied` / `Activity` | list of numbers | one value per zone, in zone order — OSC friendly |
| `Tree` | map | `{zoneName: {occupied, count, ids, activity, nearest, crossings_in, crossings_out, dwell_max, weight, idle}}`. Bind this outlet to a **device node** (e.g. `myosc:/zones`) and the map fans out into `/zones/<name>/occupied`, `/zones/<name>/count`, … |
| `Count` | int | number of tracked entities |
| `Heatmap` | list of floats | row-major occupancy grid (Settings › Heatmap) |
| `Proximity` | list of maps | `{a, b, dist}` pairs closer than the proximity distance (Settings › Proximity) |
| `Enter` / `Leave` / `Dwell` / `Cross` | per event | one message per event of that type, pre-filtered so no downstream patching is needed. Payload format per outlet (Output pane): *Zone name* (string), *Entity id* (string), *[zone, id]*, *Map* (`{zone, id, type, src, …}` with `dwell` / `direction` when relevant), *Full event* |
| `Occupancy` | per event | one message when a zone becomes occupied or empty: *[zone, 0/1]*, *Map* (`{zone, occupied, count}`) or *Full event* |
| `Location` | on change | where everybody currently is. *Map* `{id: zone}`, *List* `[[id, zone], …]`, or *Single zone string* (the first entity's zone — the one-performer case). Options: report all zones per entity instead of the topmost, include entities in no zone, send every tick instead of on change |

Maps and lists flow through cables to any node (ExprTK, Pattern applier, Entity To MIDI, JS…).
Maps do **not** travel over OSC/OSCQuery: use the flat `Counts/Occupied/Activity` lists, the
`Tree` fan-out, or the simple event outlets with a string / `[zone, id]` format for network outputs.

### Choosing which events are sent

The **Output** pane (bottom panel) has a checkbox per event type: unchecked types are emitted
nowhere — not on `Events`, not on the simple outlets, not in the monitors. Each zone can
additionally opt out per type in its inspector (*Outputs › Events sent by this zone*): e.g. keep
`count` events only for the one zone driving a display. The state machines always run in full, so
counters, occupancy and the `Zones`/`Tree` outputs are unaffected by these switches.
A dwell threshold crossed while its event is disabled is still consumed for that visit:
re-enabling does not replay it. A new visit can fire again. Dwell durations in zone/entity
telemetry and leave events remain available even when the `dwell` event type is disabled.

## Inputs accepted (per source)

The exact contract, in classification order (all forms are covered by `tests/formats-test.js`, which
sends each one through a real cable):

1. **JSON string** → parsed, then reclassified through the rules below.
2. **Single point**: vec2 / vec3, or a bare `[x,y]` / `[x,y,z]` list → one entity, id `0`.
3. **Lists**:
   * `[[x,y], ...]`, `[[x,y,z], ...]`, `[[x,y,z,conf], ...]` → one entity per element, ids `0,1,2...`
   * `[vec2|vec3, ...]` → same; `[vec4, ...]` → xyz + 4th component as confidence.
   * flat floats `[x,y,x,y,...]` → stride from the source's **Data** setting, else `flatStride`, else
     auto (even length → 2, multiple of 3 and odd → 3).
   * `[{...}, ...]` list of maps → one entity per map (see 5). This covers Point Tracker 2D/3D
     `Tracks`, Pose Detector `Poses` and `Detection`, YOLO / CV blob lists.
   * a nested list inside a list is recursed, ids prefixed `index.id`.
4. **Maps** (in this order):
   * a map that itself looks like one entity (has a position-like key, keypoints, or a box) → one entity;
   * `{name_or_index: entityMap, ...}` (PSN `/trackers`, RTTrP `/trackables`, TUIO `/2Dcur`,
     OpenXR `/controllers`, Leap `/hands` with `{left:{palm...}}`) → one entity per child, id = data id
     or child key; a child that is itself a container is recursed with ids prefixed `key.id`;
   * `{name: payload, ...}` where every value is a **container** (list or map of entities), i.e. a
     **map of sources** → every payload above is ingested through this inlet's calibration and ids
     become `name.id`. This is how one inlet carries several sensors of the same kind.
5. **Entity map keys understood**: position `position|pos|centroid|point|translation|palm|center|centre|xyz|xy|location`;
   id `id|track_id|trackId|session_id|sessionId|pid|uid|uuid|name|slot` (missing/-1 → index);
   confidence `confidence|score|conf|probability|mean_confidence|status|validity`; velocity `velocity|vel|speed_vector`;
   class `class_id|classId|cls|class|label|type_id|class_name`; box `box|bbox|boundingRect|geometry`;
   keypoints `keypoints|landmarks|joints|skeleton`; plus `height`, `orientation|heading`, `age`, `state`,
   `provisional`; `active:false` or `tracked:false` skips the entity.
6. **Boxes**: map forms are self-describing regardless of the Data setting: `{x,y,w,h[,z,d]}` (top-left +
   size), `{x1,y1,x2,y2[,z1,z2]}`, `{xmin,ymin,xmax,ymax[,zmin,zmax]}`. Bare `[x,y,w,h]` /
   `[x1,y1,x2,y2]` / `[x1,y1,z1,x2,y2,z2]` lists need the **Data** setting (`Boxes ...`), since they are
   indistinguishable from points. Box entities get centre as `pos` and keep `size` (also present on the
   `Entities` outlet) for bbox-overlap containment.
7. **Pose keypoints**: full landmark lists — maps with `x,y,z` + `confidence|visibility|score`, nested
   `{position: ...}` maps, or `[x,y,z,c]` arrays — and sparse indexed keypoints (`{kp, x, y}`, scattered
   into COCO-17 slots). Counts 17/18/25/26/32/33/34/133 map to COCO / OpenPose / Body25 / Halpe /
   Azure Kinect / BlazePose / ZED / WholeBody so feet / head / hands anchors find the right joints.
   Keypoints are calibrated through the source like positions.

If an entity map only carries a box (Pose Detector `Detection`, CV blobs), the box centre is the
position; if it only carries keypoints, the position is the average of the confident keypoints.

Calibration per source (editor › *Sources & calibration*): units (m/cm/mm/ft/in/custom), axis
preset (Z-up, Y-up, camera) or custom spec like `x,-z,y`, origin mode (world / normalised 0..1
top-left → scene rectangle in metres / pixels), flips, rigid transform, optional 4-point floor
homography, id mode (from data / by index), id prefix, default class, lost timeout, max jump
(teleport rejection), One-Euro smoothing. Settings › *World transform* moves every source at
once (the "set moved 30 cm" fix).

## Zones

Shapes: rectangle, circle/ellipse, polygon (optionally extruded into a prism with a Z band),
line/tripwire (directional, finite or extended), path (polyline with progress 0..1 and lateral
offset), box, sphere, cylinder. Every zone has:

* **frame** — world, attached to an entity id (moving zone), relative to another zone, or to a source;
* **role** — event zone, *exclude* (mask: entities inside are ignored everywhere), *include* (only
  entities inside an include zone are considered);
* **anchor** (centre, feet, head, hands, any / all keypoints) and **containment** (point, radius overlap,
  bounding-box overlap) — the evaluation point is drawn in the views;
* **filters** — classes, sources, min confidence, min age, height band, speed band, max count;
* **stability** — exit margin (spatial hysteresis), enter/exit delays and frame counts, hold,
  cooldown; lost entities exit implicitly after the source's *lost timeout*;
* **dwell / occupancy** — loiter time, stationary detection, occupied at ≥ N / empty at ≤ M,
  capacity, soft edge (weight 0..1 outside the boundary), selection policy (all / nearest /
  first-in / last-in / oldest N);
* **sets** (only one active at a time, switchable from the toolbar, Settings, the `Active Set`
  port or `{cmd:"set"}`), groups, tags, colour, enabled / visible / locked.

Line zones count crossings per direction (crossing to the *left* of A→B is "in"), confirm a
crossing after N frames on the other side, and only within the segment unless *extended*.

## Editor

* **Toolbar** — tools (1 select, 2 rect, 3 circle, 4 polygon, 5 line, 6 path, box / sphere / cyl,
  7 dummies), *Generate* (grids, radial sectors, stage / door / funnel templates, and camera
  templates for hand tracking: 3×3 segmentation, quadrants, 8 vertical strips, 5 horizontal bands,
  piano keyboard 1 or 2 octaves, XY pad + corner triggers, swipe tripwires, near / mid / far depth
  layers — all sized for the default 4 m × 3 m normalised camera scene,
  plus pies cut in 4 / 6 / 8 / 12 / 16 slices), 2D / 3D / split, fit (F),
  snapping (G) + grid step, trails, labels, speed lines, keypoints, heatmap, **Floor plan…** (load a
  PNG/JPG/SVG plan, scaled in metres, shown in both views), zone set, **Editing locked / unlocked**,
  import / export JSON.
* **Numeric fields** — every number field (inspector, sources, simulator) drags like score's spinboxes:
  drag vertically with acceleration, hold **Ctrl** for fine motion, **right-click to type**, and
  **double-click to reset to the default** (sliders too). Zone transform and shape fields update
  the views live while dragging and commit one undo step on release.
* **3D navigation** — left-drag empty space to orbit, right-drag to pan, wheel to zoom.
* **Performance readout** — the status bar shows UI fps, snapshot rate, execution tick time (total + engine),
  3D fps and the UI handler/paint costs; snapshots are dropped gracefully when the GUI cannot keep up.
* **2D top view** — pan (middle drag), zoom (wheel), grid, scale bar, floor-plan backdrop, live
  entities (trails, velocity, keypoints, ids), zone badges (count + dwell, in/out), handles
  (corners, radius, rotation, vertices; click a midpoint to insert, right-click a vertex to
  remove), marquee, Shift-click multi-select, arrows nudge, Delete, Ctrl-D duplicate,
  Ctrl-Z / Ctrl-Shift-Z undo / redo (every committed edit is an undoable score command).
* **3D view** — zones as translucent volumes, entities as pins (height), simulator ghosts, the floor plan,
  orbit / pan / zoom, click to select, creation tools work here too (click the floor to place a shape),
  and a **transform gizmo** on the selection with Move / Rotate / Scale modes (buttons in the view, keys
  W / E / R): arrows + XY pad move, the ring rotates, cube handles scale per axis, the centre cube scales
  uniformly; dragging a zone body slides it on the floor, and edits follow the mouse live.
  (`TZGizmo3D.qml` is reusable: any View3D + camera, emits dragMoved/dragEnded deltas.)
* **2D handles** — every shape moves, rotates and resizes in the canvas: corner / radius handles, a
  rotation handle on all shapes, and a uniform-scale handle on point-based shapes (polygon, path, line).
* **Inspector** — every zone property above, live read-out; with nothing selected: engine
  settings, world transform, proximity, heatmap, floor-plan backdrop. Simulator bounds live in the
  Simulator pane.
  The backdrop `…` button and toolbar **Floor plan…** open a picker modal to this editor;
  both are disabled while editing is locked.
* **Sources & calibration**, **Simulator & recorder** (dummies you drag, random walkers,
  record every source to JSON, play back with loop / speed / scrub — playback replaces the live
  inlets), **Event monitor** (event log, per-zone counters table, CSV export, reset), **Source monitor**
  (one row per inlet: status / Hz, messages per tick, how the payload was classified, entities parsed,
  entities in the engine, NaN drops, ids with calibrated positions, and the last raw payload of the
  selected inlet: the first place to look when a source "does nothing"), **Output** (the per-type
  event checkboxes, the format of each simple event outlet, and the Location outlet options — see
  *Choosing which events are sent* above).
* **Both monitors have an on/off checkbox in their header** — off, the event log stops collecting and
  the execution skips the per-inlet classification and raw previews (no cost on the audio thread).
* **Limits** — the event log keeps at most *Settings › Event log limits › Max rows* rows and adds at
  most *Max rows/s* per second (extra events are counted and shown as "not listed"); the `Events`
  outlet sends at most 256 events per tick; entities whose calibrated position is not finite are
  dropped and counted in the Source monitor instead of reaching the engine.

## Recipes

* *Point Tracker → Zones*: `Point Tracker 2D/3D › Tracks` → `Source 1`. Ids, velocities and
  confidences come through; use the tracker's smoothing and leave the source smoothing off.
* *PSN / BlackTrax*: add the PSN device, set `Source 2` address to `psn:/trackers`, source axes
  *Y up*, units m.
* *Pose Detector (camera)*: `Poses` → `Source 3`, origin *Normalised 0..1*, scene W×H = the
  floor area seen by the camera (or a 4-point homography from image corners to floor points),
  anchor *feet*.
* *OSC out per zone*: create an OSC device, bind the `Tree` outlet to `osc:/zones`.
* *Trigger a cue*: cable `Enter` (format *Zone name*) straight into whatever should fire — no
  filtering needed; `Events` remains the everything-stream for JS / Entity To MIDI.
* *"Which zone is the performer in?"*: Location outlet, format *Single zone string*.
* *Zone sets per scene*: give zones a `set` ("act1", "act2"…), then automate the `Active Set` port.
* *Authoring without people*: Simulator › +walkers, or record a rehearsal and play it back.

## Files

`tracking-zones.qml` (execution), `tracking-zones.ui.qml` (editor), `TZ*.qml` (editor components),
`ZoneEngine.js` (pure evaluation core), `Geometry.js`, `Ingest.js`, `Model.js`, `UiUtil.js`,
`examples/stage-demo.json` (importable zone document), `tests/` (engine unit tests, integration,
UI / synthetic-input tests — run with `score.exe --script "eval(Score.readFile('…/tests/engine-tests.js'))"`).
