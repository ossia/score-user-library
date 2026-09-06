import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Geometry.js" as Geom
import "Model.js" as Model
import "UiUtil.js" as U
import OssiaUI as S

// Tracking Zones — editor window.
// The document (zones / sources / settings) lives in the process state under key "tzDoc" (JSON).
// Live edits are pushed to the execution with executionSend({type:"doc"}); committed edits go through
// beginUpdateState/updateState/endUpdateState so they are undoable.
Score.ScriptUI {
    id: root
    anchors.fill: parent
    implicitWidth: 1280   // requested window size (honoured by score >= 3.8.3)
    implicitHeight: 860

    // ---------------- document & selection ----------------
    property var doc: Model.defaultDoc()
    property int docVersion: 0
    property var selection: []            // zone ids
    property string selectedId: selection.length ? selection[selection.length - 1] : ""
    property var selectedZone: { docVersion; selection; return zoneById(selectedId); }
    property string tool: "select"
    property string viewMode: "2d"        // 2d | 3d | split
    property string gizmoMode: "move"     // move | rotate | scale (3D gizmo)
    property bool snapping: true
    property real gridStep: 0.5
    property bool showMode: false
    property bool showTrails: true
    property bool showLabels: true
    property bool showHeat: false
    property bool bottomVisible: true
    property int bottomTab: 0
    property real bottomHeight: 240
    property var snapshot: null           // last execution snapshot
    property var zoneStates: ({})         // zone id -> live state (from the last processed snapshot)
    property real lastHandledWall: 0
    property int droppedSnapshots: 0
    property var lastDropped: null
    property bool pendingEvents: false
    property bool showKeypoints: false
    property bool showVelocity: true
    property bool eventMonitorEnabled: true     // when off, incoming events are not appended to the log
    property bool sourceMonitorEnabled: true    // when off, the execution skips the per-inlet diagnostics
    onShowKeypointsChanged: sendPrefs()
    onSourceMonitorEnabledChanged: sendPrefs()
    function sendPrefs() { root.executionSend({ type: "prefs", keypoints: showKeypoints, sourceMonitor: sourceMonitorEnabled }); }
    ListModel { id: eventModel }          // event log rows: {t, type, zone, id, detail}
    property alias eventLog: eventModel
    function eventDetail(ev) { var parts = []; if (ev.direction) parts.push(ev.direction + " (" + ev["in"] + "/" + ev.out + ")"); if (ev.dwell !== undefined) parts.push("dwell " + U.fmt(ev.dwell, 1) + "s"); if (ev.lost) parts.push("lost"); if (ev.count !== undefined) parts.push("count " + ev.count); if (ev.from) parts.push("from " + (ev.from.length !== undefined ? Array.prototype.join.call(ev.from, ",") : ev.from)); if (ev.capacity !== undefined) parts.push(ev.over ? "over capacity" : "back under capacity"); if (ev.other !== undefined) parts.push("with " + ev.other + " " + (ev.state || "") + (ev.dist !== undefined ? " " + U.fmt(ev.dist, 2) + " m" : "")); return parts.join("  "); }
    property int eventLogVersion: 0
    property int evSecond: -1              // event-log rate limiter
    property int evThisSecond: 0
    property int droppedEvents: 0          // rows not shown because of the per-second limit
    property var trails: ({})             // key -> [[x,y],...]
    property real lastSnapshotT: -1
    property real lastSnapshotWall: 0
    property bool liveData: false         // true while snapshots keep arriving (transport running)
    property var perf: ({ tickMs: 0, engineMs: 0, tickHz: 0, snapshotHz: 0, uiFps: 0 })
    property string statusText: ""

    // ---------------- simulation ----------------
    property bool simEnabled: true
    property var simEntities: []          // [{id, pos, vel, heading, kind:"dummy"|"walker", cls, height}]
    property int simVersion: 0
    property real simSpeed: 1.0
    property real simNoise: 0.2
    property var simBounds: ({ x: 0, y: 0, w: 8, h: 6 })
    property int nextSimId: 1
    property string draggingSim: ""

    // ---------------- recording / playback ----------------
    property bool recording: false
    property var playbackInfo: null
    property string recordingsDir: Util.settings("d6966670-f69f-48d0-96f6-72a5e2190cbc").RootPath + "/tracking-zones-recordings"
    property string lastRecordingPath: ""

    // ---------------- state plumbing ----------------
    function parseDoc(v) { try { return Model.normalizeDoc(typeof v === "string" ? JSON.parse(v) : v); } catch (e) { console.log("tracking-zones ui: bad doc", e); return Model.defaultDoc(); } }
    loadState: function (state) {
        if (state && state.tzDoc) doc = parseDoc(state.tzDoc); else doc = Model.defaultDoc();
        docVersion++;
    }
    stateUpdated: function (k, v) {
        if (k === "tzDoc") { doc = parseDoc(v); docVersion++; pruneSelection(); sendLive(); }
    }
    executionEvent: function (m) {
        if (!m || !m.type) return;
        if (m.type === "snapshot") {
            var now = Date.now();
            lastSnapshotWall = now; if (!liveData) liveData = true;
            // always keep the latest events, but only *process* snapshots at the UI rate: if the execution runs faster than
            // the GUI can repaint, the extra snapshots are dropped here instead of piling up in the event loop
            var e0 = Date.now();
            if (m.events && m.events.length && eventMonitorEnabled) {
                // bounded event log: at most maxEventsPerSec rows added per second, at most maxEvents rows kept
                var lim = doc.settings.monitor || { maxEvents: 400, maxEventsPerSec: 100 };
                var sec = Math.floor(now / 1000); if (sec !== evSecond) { evSecond = sec; evThisSecond = 0; }
                for (var i = 0; i < m.events.length; i++) {
                    if (evThisSecond >= (lim.maxEventsPerSec || 100)) { droppedEvents += m.events.length - i; break; }
                    var ev = m.events[i]; evThisSecond++;
                    eventModel.append({ t: ev.t, type: String(ev.type), zone: String(ev.zone || ""), eid: ev.id === undefined || ev.id === "" ? "" : String(ev.id), detail: eventDetail(ev) });
                }
                var maxRows = Math.max(10, lim.maxEvents || 400);
                if (eventModel.count > maxRows) eventModel.remove(0, eventModel.count - maxRows);
                eventLogVersion++; perfAcc.evN += m.events.length;
            }
            perfAcc.evMs += Date.now() - e0;
            if (now - lastHandledWall < 1000 / Math.max(5, doc.settings.uiRate || 30) * 0.9) { droppedSnapshots++; lastDropped = m; return; }
            lastHandledWall = now;
            var w0 = now;
            lastSnapshotT = m.t; snapCount++;
            if (m.perf) perf = { tickMs: m.perf.tickMs, engineMs: m.perf.engineMs, tickHz: m.perf.tickHz, snapshotHz: perf.snapshotHz, uiFps: perf.uiFps };
            recording = !!m.recording; playbackInfo = m.playback || null;
            // zone states by id (one map per snapshot; delegates read it instead of scanning the list)
            var zsMap = {}; if (m.zones) for (var zi = 0; zi < m.zones.length; zi++) zsMap[m.zones[zi].id] = m.zones[zi];
            zoneStates = zsMap;
            snapshot = m;
            if (showTrails) updateTrails(m.entities);
            perfAcc.snapMs += Date.now() - w0; perfAcc.snapN++;
        } else if (m.type === "recording") {
            saveRecording(m.frames);
        } else if (m.type === "uiaction") {
            uiAction(m);
        } else if (m.type === "docLoaded") {
            // a document arrived through the Command inlet: adopt and persist it
            doc = parseDoc(m.doc); selection = []; commit("Load zones");
        }
    }
    // scripted UI actions (used by the tests and by the Command inlet: {cmd:"ui", action:..., ...})
    function uiAction(m) {
        switch (m.action) {
        case "grab": root.grabToImage(function (res) { var ok = res.saveToFile(m.path); console.log("tracking-zones ui: grab", m.path, ok); }); break;
        case "graboverlay": { var ov = root.Overlay.overlay; console.log("tracking-zones ui: overlay children", ov.children.length); if (ov.children.length) ov.children[0].grabToImage(function (res) { var ok = res.saveToFile(m.path); console.log("tracking-zones ui: graboverlay", m.path, ok); }); break; }
        case "select": { var z = doc.zones.filter(function (q) { return q.name === m.name || q.id === m.name; })[0]; selection = z ? [z.id] : []; break; }
        case "tool": tool = m.value; break;
        case "view": viewMode = m.value; break;
        case "gizmo": gizmoMode = m.value; break;
        case "tab": bottomTab = m.value; bottomVisible = true; break;
        case "fit": canvas2d.fitAll(); break;
        case "zoom": canvas2d.ppm = m.value; break;
        case "center": canvas2d.cx = m.x; canvas2d.cy = m.y; break;
        case "walkers": addWalkers(m.value || 5); break;
        case "dummy": addDummy(m.x || 0, m.y || 0); break;
        case "clearSim": clearSim(); break;
        case "showMode": showMode = !!m.value; break;
        case "heat": showHeat = !!m.value; break;
        case "addZone": addZone(m.zoneType || "rect", m.x || 0, m.y || 0); break;
        case "setProp": if (selectedId) setZoneProp(selectedId, m.path, m.value, "Edit"); break;
        case "record": m.value ? startRecording() : stopRecording(); break;
        case "playLast": loadRecording(lastRecordingPath); break;
        case "dumpdoc": Util.writeFile(m.path, JSON.stringify({ doc: doc, selection: selection, tool: tool, sim: simEntities }, null, 1)); break;
        case "synth": synthInput(m.steps || []); break;
        case "dumpstatus": Util.writeFile(m.path, JSON.stringify({ lastRecordingPath: lastRecordingPath, recording: recording, playback: playbackInfo, entities: snapshot ? snapshot.count : 0, zones: doc.zones.length, status: statusText, events: eventModel.count, perf: perf, perfDetail: perfDetail, liveData: liveData, gizmo: { len: view3d.gizmoLen, visible: view3d.gizmoVisible }, stats3d: view3d.stats(), selected: selectedZone ? { name: selectedZone.name, pos: selectedZone.pos, rot: selectedZone.rot, shape: selectedZone.shape } : null, gizmoMode: gizmoMode, viewMode: viewMode, bottomHeight: bottomHeight, bottomTab: bottomTab, sourceInfo: snapshot ? snapshot.sourceInfo : null, droppedEvents: droppedEvents })); break;
        case "undo": Score.Editor.undo(); break;
        case "redo": Score.Editor.redo(); break;
        }
    }

    // In-process synthetic input for tests (QtTest event injection into the 2D canvas). Coordinates are world metres.
    property var synthDriver: null
    function synthInput(steps) {
        try {
            if (!synthDriver) synthDriver = Qt.createQmlObject('import QtTest; TestCase { when: false; name: "tz-synth" }', root, "synth");
            var tc = synthDriver; var it = canvas2d;
            try { if (root.Window.window) root.Window.window.requestActivate(); } catch (e2) {}
            var btn = function (s) { return s.button === "right" ? Qt.RightButton : (s.button === "middle" ? Qt.MiddleButton : Qt.LeftButton); };
            var mods = function (s) { var mm = Qt.NoModifier; if (s.shift) mm |= Qt.ShiftModifier; if (s.ctrl) mm |= Qt.ControlModifier; if (s.alt) mm |= Qt.AltModifier; return mm; };
            for (var i = 0; i < steps.length; i++) {
                var s = steps[i];
                var sx = 0, sy = 0;
                if (s.view === "3d") { it = view3d; if (s.x !== undefined) { var pp = view3d.project(s.x, s.y, s.z || 0); sx = pp[0]; sy = pp[1]; } }
                else if (s.view === "ui") { it = root; }   // absolute window pixels via s.px/s.py
                else { it = canvas2d; if (s.x !== undefined) { sx = it.w2sx(s.x); sy = it.w2sy(s.y); } }
                if (s.px !== undefined) { sx = s.px; sy = s.py; }
                switch (s.t) {
                case "press": tc.mousePress(it, sx, sy, btn(s), mods(s), 10); break;
                case "move": tc.mouseMove(it, sx, sy, 10); break;
                case "release": tc.mouseRelease(it, sx, sy, btn(s), mods(s), 10); break;
                case "click": tc.mouseClick(it, sx, sy, btn(s), mods(s), 10); break;
                case "dblclick": tc.mouseDoubleClickSequence(it, sx, sy, btn(s), mods(s), 10); break;
                case "drag": {
                    var x1 = 0, y1 = 0; var n = s.n || 8;
                    if (s.view !== "3d" && s.x1 !== undefined) { x1 = it.w2sx(s.x1); y1 = it.w2sy(s.y1); }
                    if (s.view === "3d") { var p1 = view3d.project(s.x1, s.y1, s.z1 || 0); x1 = p1[0]; y1 = p1[1]; }
                    if (s.px1 !== undefined) { x1 = s.px1; y1 = s.py1; }
                    if (s.dxPx !== undefined || s.dyPx !== undefined) { x1 = sx + (s.dxPx || 0); y1 = sy + (s.dyPx || 0); }
                    tc.mousePress(it, sx, sy, btn(s), mods(s), 10);
                    for (var k = 1; k <= n; k++) tc.mouseMove(it, sx + (x1 - sx) * k / n, sy + (y1 - sy) * k / n, 10);
                    tc.mouseRelease(it, x1, y1, btn(s), mods(s), 10);
                    break;
                }
                case "key": root.forceActiveFocus(); tc.keyClick(s.key, mods(s), 10); break;
                case "keyraw": tc.keyClick(s.key, mods(s), 10); break;   // to whatever item has focus
                case "tool": tool = s.value; break;
                case "wheel": tc.mouseWheel(it, sx, sy, 0, s.delta || 120, Qt.NoButton, Qt.NoModifier, 10); break;
                }
            }
            console.log("tracking-zones ui: synth done", steps.length, "tool", tool, "zones", doc.zones.length, "mode", canvas2d.mode, "hover", JSON.stringify(canvas2d.hoverW), "focus", root.activeFocus, "win", root.Window.window ? root.Window.window.width : -1);
            statusText = "synth: " + steps.length + " steps done";
        } catch (e) { console.log("tracking-zones ui: synth failed", e); statusText = "synth failed: " + e; }
    }

    function zoneById(id) { if (!id) return null; for (var i = 0; i < doc.zones.length; i++) if (doc.zones[i].id === id) return doc.zones[i]; return null; }
    function zoneIndex(id) { for (var i = 0; i < doc.zones.length; i++) if (doc.zones[i].id === id) return i; return -1; }
    function pruneSelection() { var s = []; for (var i = 0; i < selection.length; i++) if (zoneById(selection[i])) s.push(selection[i]); selection = s; }
    function select(id, additive) {
        if (!id) { selection = []; return; }
        if (additive) { var s = selection.slice(); var k = s.indexOf(id); if (k >= 0) s.splice(k, 1); else s.push(id); selection = s; }
        else selection = [id];
    }
    function isSelected(id) { return selection.indexOf(id) >= 0; }

    function commit(label) {
        if (showMode) return;
        root.beginUpdateState(label || "Edit zones");
        root.updateState("tzDoc", JSON.stringify(doc));
        root.endUpdateState();
        docVersion++;
        sendLive();
    }
    function touch() { docVersion++; liveDirty = true; if (!liveTimer.running) liveTimer.start(); }   // live, uncommitted (coalesced to ~30 Hz)
    property bool liveDirty: false
    Timer { id: liveTimer; interval: 33; repeat: false; onTriggered: { if (root.liveDirty) { root.liveDirty = false; root.sendLive(); } } }
    function sendLive() { liveDirty = false; root.executionSend({ type: "doc", doc: JSON.stringify(doc) }); }

    // ---------------- zone operations ----------------
    function addZone(type, wx, wy, opts) {
        if (showMode) return null;
        var z = Model.makeZone(type, doc.zones.length);
        z.pos = [wx || 0, wy || 0, (type === "box" || type === "sphere" || type === "cylinder") ? (z.shape.d ? z.shape.d / 2 : (z.shape.r || 1)) : 0];
        if (opts) for (var k in opts) z[k] = opts[k];
        if (doc.settings.activeSet) z.set = doc.settings.activeSet;
        doc.zones.push(z);
        selection = [z.id];
        commit("Add " + type);
        return z;
    }
    function addZones(list, label) { if (showMode) return; for (var i = 0; i < list.length; i++) doc.zones.push(list[i]); selection = list.map(function (z) { return z.id; }); commit(label || "Add zones"); }
    function deleteSelected() {
        if (showMode || !selection.length) return;
        doc.zones = doc.zones.filter(function (z) { return !root.isSelected(z.id) || z.locked; });
        selection = []; commit("Delete zones");
    }
    function duplicateSelected() {
        if (showMode || !selection.length) return;
        var added = [];
        for (var i = 0; i < selection.length; i++) { var z = zoneById(selection[i]); if (!z) continue; var c = Model.cloneZone(z); c.id = Model.uid("z"); c.name = U.incrementName(z.name); c.pos = [z.pos[0] + 0.5, z.pos[1] - 0.5, z.pos[2]]; doc.zones.push(c); added.push(c.id); }
        selection = added; commit("Duplicate zones");
    }
    function moveSelected(dx, dy, live) {
        if (showMode) return;
        for (var i = 0; i < selection.length; i++) { var z = zoneById(selection[i]); if (!z || z.locked) continue; z.pos = [z.pos[0] + dx, z.pos[1] + dy, z.pos[2]]; }
        if (live) touch(); else commit("Move zones");
    }
    function setZoneProp(id, path, value, label) {
        if (showMode) return;
        var z = zoneById(id); if (!z) return;
        U.deepSet(z, path, value);
        if (path === "shape.type") { var ns = Model.defaultShape(value); for (var k in ns) if (z.shape[k] === undefined) z.shape[k] = ns[k]; z.shape.type = value; }
        commit(label || ("Edit " + path));
    }
    function setZonePropLive(id, path, value) { var z = zoneById(id); if (!z) return; U.deepSet(z, path, value); touch(); }
    function setSelectedProp(path, value, label) { if (showMode) return; for (var i = 0; i < selection.length; i++) { var z = zoneById(selection[i]); if (z) U.deepSet(z, path, value); } commit(label || ("Edit " + path)); }
    function reorderZone(from, to) { if (showMode || from === to || from < 0 || to < 0 || from >= doc.zones.length || to >= doc.zones.length) return; var z = doc.zones.splice(from, 1)[0]; doc.zones.splice(to, 0, z); commit("Reorder zones"); }
    function setSettings(path, value, label) { if (showMode) return; U.deepSet(doc.settings, path, value); commit(label || "Edit settings"); }
    function setSource(i, path, value, label) { if (showMode) return; var cfg = doc.sources[i]; if (!cfg) return; U.deepSet(cfg, path, value); commit(label || "Edit source"); }
    function sourceCfg(i) { return doc.sources[i]; }
    function sourceKeys() { docVersion; return [0, 1, 2, 3]; }
    function fitView() { canvas2d.fitAll(); }
    function readTextFile(path) { try { return U.bufToString(Util.readFile(path)); } catch (e) { return ""; } }
    function importDoc(jsonText) { try { var d = Model.normalizeDoc(JSON.parse(jsonText)); doc = d; selection = []; commit("Import zones"); } catch (e) { statusText = "Import failed: " + e; } }
    function exportDoc() { return JSON.stringify(doc, null, 2); }
    function zoneSetsList() { docVersion; var s = {}; for (var i = 0; i < doc.zones.length; i++) if (doc.zones[i].set) s[doc.zones[i].set] = true; for (var j = 0; j < doc.sets.length; j++) s[doc.sets[j]] = true; return Object.keys(s); }

    // ---------------- simulation ----------------
    function simSend() { root.executionSend({ type: "sim", entities: simEnabled ? simEntities.map(function (e) { return { id: e.id, pos: e.pos, vel: e.vel || [0, 0, 0], heading: e.heading || 0, cls: e.cls || "", height: e.height || 1.7, name: e.name || "" }; }) : [] }); }
    function addDummy(wx, wy) { var e = { id: "sim" + (nextSimId++), pos: [wx, wy, 0], vel: [0, 0, 0], kind: "dummy", cls: "person", height: 1.7 }; var l = simEntities.slice(); l.push(e); simEntities = l; simVersion++; simSend(); return e; }
    function addWalkers(n) { var l = simEntities.slice(); for (var i = 0; i < n; i++) l.push({ id: "sim" + (nextSimId++), pos: [simBounds.x + (Math.random() - 0.5) * simBounds.w, simBounds.y + (Math.random() - 0.5) * simBounds.h, 0], vel: [0, 0, 0], kind: "walker", cls: "person", height: 1.5 + Math.random() * 0.5, speedMul: 0.6 + Math.random() * 0.8 }); simEntities = l; simVersion++; simSend(); }
    function clearSim() { simEntities = []; simVersion++; root.executionSend({ type: "simClear" }); }
    function removeSim(id) { simEntities = simEntities.filter(function (e) { return e.id !== id; }); simVersion++; simSend(); }
    function simById(id) { for (var i = 0; i < simEntities.length; i++) if (simEntities[i].id === id) return simEntities[i]; return null; }
    Timer {
        id: simTimer; interval: 33; repeat: true; running: root.simEnabled && root.simEntities.length > 0
        onTriggered: {
            var dt = interval / 1000; var l = root.simEntities; var any = false;
            for (var i = 0; i < l.length; i++) { var e = l[i]; if (e.kind === "walker") { U.walkerStep(e, dt, root.simBounds, root.simSpeed, root.simNoise); any = true; } else if (e.id === root.draggingSim) any = true; }
            root.simSend(); if (any) root.simVersion++;
        }
    }
    onSimEnabledChanged: simSend()

    // ---------------- recording / playback ----------------
    function startRecording() { root.executionSend({ type: "record", action: "start" }); }
    function stopRecording() { root.executionSend({ type: "record", action: "stop" }); }
    function saveRecording(frames) {
        var name = "rec-" + new Date().toISOString().replace(/[:.]/g, "-") + ".json";
        var dir = recordingsDir;
        try { if (typeof Util.makeDir === "function") Util.makeDir(dir); } catch (e0) {}
        if (!Util.isDir(dir)) { dir = Util.settings("d6966670-f69f-48d0-96f6-72a5e2190cbc").RootPath; name = "tracking-zones-" + name; }
        var path = dir + "/" + name;
        try { Util.writeFile(path, JSON.stringify({ version: 1, frames: frames })); lastRecordingPath = Util.fileExists(path) ? path : ""; statusText = lastRecordingPath ? ("Saved " + frames.length + " frames to " + path) : ("Could not write " + path); }
        catch (e) { statusText = "Could not save recording: " + e; }
    }
    function loadRecording(path) {
        try {
            var txt = U.bufToString(Util.readFile(path));
            var rec = JSON.parse(txt);
            root.executionSend({ type: "playback", frames: rec.frames || [], loop: true, speed: 1, play: true });
            statusText = "Playing " + (rec.frames || []).length + " frames from " + path;
        } catch (e) { statusText = "Could not load recording: " + e; }
    }
    function playbackControl(action, value) { root.executionSend({ type: "playbackControl", action: action, value: value, position: value }); }

    function updateTrails(entities) {
        var tr = trails; var seen = {};
        for (var i = 0; i < entities.length; i++) { var e = entities[i]; seen[e.key] = true; var a = tr[e.key]; if (!a) a = tr[e.key] = []; a.push([e.pos[0], e.pos[1]]); if (a.length > 40) a.splice(0, a.length - 40); }
        for (var k in tr) if (!seen[k]) delete tr[k];
    }

    // ---------------- liveness + performance measurement ----------------
    property int snapCount: 0
    property int frameCount: 0
    property var perfAcc: ({ snapMs: 0, snapN: 0, paintDynMs: 0, paintDynN: 0, paintStaticMs: 0, paintStaticN: 0, evMs: 0, evN: 0 })
    property string perfDetail: ""
    FrameAnimation { id: frameCounter; running: root.visible; onTriggered: root.frameCount++ }
    Timer {
        id: perfTimer; interval: 1000; repeat: true; running: true
        property real lastWall: Date.now()
        onTriggered: {
            var now = Date.now(); var dt = Math.max(0.001, (now - lastWall) / 1000); lastWall = now;
            root.perf = { tickMs: root.perf.tickMs, engineMs: root.perf.engineMs, tickHz: root.perf.tickHz, uiFps: root.frameCount / dt, snapshotHz: root.snapCount / dt };
            var a = root.perfAcc; root.perfDetail = "snapshot " + (a.snapN ? (a.snapMs / a.snapN).toFixed(1) : "-") + " ms, 2D paint " + (a.paintDynN ? (a.paintDynMs / a.paintDynN).toFixed(1) : "-") + " ms (static " + (a.paintStaticN ? (a.paintStaticMs / a.paintStaticN).toFixed(1) : "-") + "), events " + a.evN + "/s, dropped " + root.droppedSnapshots; root.droppedSnapshots = 0; root.perfAcc = { snapMs: 0, snapN: 0, paintDynMs: 0, paintDynN: 0, paintStaticMs: 0, paintStaticN: 0, evMs: 0, evN: 0 };
            root.frameCount = 0; root.snapCount = 0;
            var live = (now - root.lastSnapshotWall) < 1500;
            if (live !== root.liveData) { root.liveData = live; if (!live) { root.trails = ({}); } }
        }
    }
    readonly property string perfText: "UI " + perf.uiFps.toFixed(0) + " fps, snapshots " + perf.snapshotHz.toFixed(0) + " Hz, exec " + perf.tickHz.toFixed(0) + " Hz " + perf.tickMs.toFixed(2) + " ms/tick (engine " + perf.engineMs.toFixed(2) + ")" + (viewMode !== "2d" ? ", 3D " + view3d.fps.toFixed(0) + " fps" : "") + "   " + perfDetail

    // ---------------- keyboard ----------------
    focus: true
    Keys.onPressed: function (ev) {
        if (ev.key === Qt.Key_Delete || ev.key === Qt.Key_Backspace) { deleteSelected(); ev.accepted = true; }
        else if (ev.key === Qt.Key_Escape) { if (tool !== "select") tool = "select"; else selection = []; canvas2d.cancelDrawing(); ev.accepted = true; }
        else if (ev.key === Qt.Key_D && (ev.modifiers & Qt.ControlModifier)) { duplicateSelected(); ev.accepted = true; }
        else if (ev.key === Qt.Key_Z && (ev.modifiers & Qt.ControlModifier)) { if (ev.modifiers & Qt.ShiftModifier) Score.Editor.redo(); else Score.Editor.undo(); ev.accepted = true; }
        else if (ev.key === Qt.Key_Y && (ev.modifiers & Qt.ControlModifier)) { Score.Editor.redo(); ev.accepted = true; }
        else if (ev.key === Qt.Key_A && (ev.modifiers & Qt.ControlModifier)) { selection = doc.zones.map(function (z) { return z.id; }); ev.accepted = true; }
        else if (ev.key === Qt.Key_Left) { moveSelected(-(ev.modifiers & Qt.ShiftModifier ? 1 : 0.1), 0); ev.accepted = true; }
        else if (ev.key === Qt.Key_Right) { moveSelected((ev.modifiers & Qt.ShiftModifier ? 1 : 0.1), 0); ev.accepted = true; }
        else if (ev.key === Qt.Key_Up) { moveSelected(0, (ev.modifiers & Qt.ShiftModifier ? 1 : 0.1)); ev.accepted = true; }
        else if (ev.key === Qt.Key_Down) { moveSelected(0, -(ev.modifiers & Qt.ShiftModifier ? 1 : 0.1)); ev.accepted = true; }
        else if (ev.key === Qt.Key_F) { canvas2d.fitAll(); ev.accepted = true; }
        else if (ev.key === Qt.Key_G) { snapping = !snapping; ev.accepted = true; }
        else if (ev.key === Qt.Key_1) { tool = "select"; ev.accepted = true; }
        else if (ev.key === Qt.Key_2) { tool = "rect"; ev.accepted = true; }
        else if (ev.key === Qt.Key_3) { tool = "circle"; ev.accepted = true; }
        else if (ev.key === Qt.Key_4) { tool = "polygon"; ev.accepted = true; }
        else if (ev.key === Qt.Key_5) { tool = "line"; ev.accepted = true; }
        else if (ev.key === Qt.Key_6) { tool = "path"; ev.accepted = true; }
        else if (ev.key === Qt.Key_7) { tool = "sim"; ev.accepted = true; }
        else if (ev.key === Qt.Key_W) { gizmoMode = "move"; ev.accepted = true; }
        else if (ev.key === Qt.Key_E) { gizmoMode = "rotate"; ev.accepted = true; }
        else if (ev.key === Qt.Key_R) { gizmoMode = "scale"; ev.accepted = true; }
        else if (ev.key === Qt.Key_Tab) { viewMode = viewMode === "2d" ? "3d" : (viewMode === "3d" ? "split" : "2d"); ev.accepted = true; }
    }

    Component.onCompleted: { root.forceActiveFocus(); sendPrefs(); }

    // ---------------- layout ----------------
    // The score skin now lives in the shared OssiaUI kit, so this editor and the
    // mapper / text / presentation editors cannot drift apart.
    S.ThemedPage {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            TZToolbar { id: toolbar; owner: root; Layout.fillWidth: true }

            SplitView {
                Layout.fillWidth: true; Layout.fillHeight: true
                orientation: Qt.Horizontal

                TZZoneList { owner: root; SplitView.preferredWidth: 210; SplitView.minimumWidth: 150 }

                Item {
                    id: centre
                    SplitView.fillWidth: true; SplitView.fillHeight: true
                    SplitView.minimumWidth: 300
                    clip: true
                    property real splitRatio: 0.5
                    readonly property bool split: root.viewMode === "split"
                    TZCanvas2D { id: canvas2d; owner: root; visible: root.viewMode !== "3d"; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: centre.split ? Math.round(centre.width * centre.splitRatio) - 3 : centre.width }
                    TZView3D { id: view3d; owner: root; visible: root.viewMode !== "2d"; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: centre.split ? centre.width - Math.round(centre.width * centre.splitRatio) - 3 : centre.width }
                    Rectangle {   // draggable divider
                        visible: centre.split; width: 6; anchors.top: parent.top; anchors.bottom: parent.bottom; x: Math.round(centre.width * centre.splitRatio) - 3
                        color: divArea.pressed ? "#c58014" : (divArea.containsMouse ? "#3a3835" : "#252930")
                        MouseArea { id: divArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.SplitHCursor; onPositionChanged: function (m) { if (pressed) { var nx = parent.x + m.x; centre.splitRatio = Math.max(0.2, Math.min(0.8, nx / centre.width)); } } }
                    }
                }

                TZInspector { owner: root; SplitView.preferredWidth: 330; SplitView.minimumWidth: 260; SplitView.maximumWidth: 420 }
            }

            TZBottomPanel { id: bottom; owner: root; Layout.fillWidth: true; Layout.preferredHeight: root.bottomVisible ? root.bottomHeight : 28 }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: root.statusText.length ? root.statusText : (root.liveData && root.snapshot ? ("entities: " + root.snapshot.count + "   zones: " + root.doc.zones.length + (root.snapshot.activeSet ? "   set: " + root.snapshot.activeSet : "") + (root.recording ? "   ● REC " : "") + (root.playbackInfo ? "   ▶ playback " + U.fmtTime(root.playbackInfo.pos) + "/" + U.fmtTime(root.playbackInfo.duration) : "")) : "Transport stopped. Press play in score to see live data. Keys: 1-7 tools, W/E/R gizmo, F fit, Tab view")
                    font.pixelSize: 11; color: palette.placeholderText; elide: Text.ElideRight
                }
                Label { text: root.perfText; font.pixelSize: 10; color: palette.placeholderText; font.family: "monospace" }
            }
            }
    }
}
