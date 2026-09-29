import Score
import QtQuick
import "Geometry.js" as Geom
import "Ingest.js" as Ingest
import "Model.js" as Model
import "ZoneEngine.js" as ZE

// Tracking Zones — 2D/3D interactive zones over tracked entities.
// Inputs: up to four sources (lists of maps, device subtrees, vec lists, flat floats…), each calibrated
// in the editor (Show UI). Outputs per-zone state, events, enriched entities and flat vectors.
Script {
    id: root

    // Each inlet accepts one source (entity list, device subtree, bare geometry) OR several sources
    // at once as a map {name: payload} (e.g. a device container with one child per sensor). All
    // sources arriving on an inlet share that inlet's calibration, so group sensors of the same
    // kind per inlet: inlet 1 = camera boxes, inlet 2 = centroid tracking, inlet 3 = BlackTrax...
    ValueInlet { id: src1; objectName: "Source 1" }
    ValueInlet { id: src2; objectName: "Source 2" }
    ValueInlet { id: src3; objectName: "Source 3" }
    ValueInlet { id: src4; objectName: "Source 4" }
    ValueInlet { id: cmdIn; objectName: "Command" }
    LineEdit { id: setIn; objectName: "Active Set"; text: "" }
    Toggle { id: bypass; objectName: "Bypass"; checked: false }
    Toggle { id: simIn; objectName: "Simulation"; checked: true }
    Impulse { id: resetBtn; objectName: "Reset Counters"; onImpulse: root.engine.resetCounters() }

    ValueOutlet { id: outZones; objectName: "Zones" }
    ValueOutlet { id: outEvents; objectName: "Events" }
    ValueOutlet { id: outEntities; objectName: "Entities" }
    ValueOutlet { id: outCounts; objectName: "Counts" }
    ValueOutlet { id: outOccupied; objectName: "Occupied" }
    ValueOutlet { id: outActivity; objectName: "Activity" }
    ValueOutlet { id: outTree; objectName: "Tree" }
    ValueOutlet { id: outCount; objectName: "Count" }
    ValueOutlet { id: outHeat; objectName: "Heatmap" }
    ValueOutlet { id: outPairs; objectName: "Proximity" }
    // Simple event outlets: one event type each, payload format chosen in the Output pane.
    ValueOutlet { id: outEnter; objectName: "Enter" }
    ValueOutlet { id: outLeave; objectName: "Leave" }
    ValueOutlet { id: outDwell; objectName: "Dwell" }
    ValueOutlet { id: outCross; objectName: "Cross" }
    ValueOutlet { id: outOccupancy; objectName: "Occupancy" }
    ValueOutlet { id: outLocation; objectName: "Location" }

    property var engine: new ZE.Engine()
    property var doc: Model.defaultDoc()
    property var calibrators: []
    property var simEntities: []
    property real lastUiT: -1
    property real lastT: 0
    property bool running: false
    // recording / playback
    property var recording: null        // { frames: [{t, inputs}], t0 }
    property var playback: null         // { frames, loop, speed, playing, pos, idx, lastT }
    property var lastInputs: []
    property var uiPrefs: ({ keypoints: false, sourceMonitor: true })

    readonly property real flicksPerSecond: 705600000

    function applyDoc(d, fromUi) {
        doc = Model.normalizeDoc(d);
        calibrators = doc.sources.map(function (s) { return Ingest.makeCalibrator(s); });
        engine.setDoc(doc);
    }

    loadState: function (state) {
        if (state && state.tzDoc) {
            try { applyDoc(typeof state.tzDoc === "string" ? JSON.parse(state.tzDoc) : state.tzDoc); return; } catch (e) { console.log("tracking-zones: bad state", e); }
        }
        applyDoc(Model.defaultDoc());
    }
    stateUpdated: function (k, v) {
        if (k === "tzDoc") { try { applyDoc(typeof v === "string" ? JSON.parse(v) : v); } catch (e) { console.log("tracking-zones: bad state update", e); } }
    }

    uiEvent: function (m) {
        if (!m || !m.type) return;
        switch (m.type) {
        case "doc": try { applyDoc(typeof m.doc === "string" ? JSON.parse(m.doc) : m.doc); } catch (e) { console.log("tracking-zones: bad live doc", e); } break; // live (uncommitted) edit
        case "sim": simEntities = m.entities || []; break;
        case "simClear": simEntities = []; break;
        case "resetCounters": engine.resetCounters(m.zone || null); break;
        case "clearEntities": engine.clearEntities(); simEntities = []; break;
        case "record":
            if (m.action === "start") { recording = { frames: [], t0: lastT }; }
            else if (m.action === "stop") { if (recording) { var fr = recording.frames; recording = null; uiSend({ type: "recording", frames: fr }); } }
            break;
        case "playback":
            playback = { frames: m.frames || [], loop: !!m.loop, speed: m.speed || 1, playing: !!m.play, pos: 0, lastT: lastT, duration: (m.frames && m.frames.length) ? m.frames[m.frames.length - 1].t : 0 };
            engine.clearEntities();
            break;
        case "playbackControl":
            if (!playback) break;
            if (m.action === "play") { playback.playing = true; playback.lastT = lastT; }
            else if (m.action === "pause") playback.playing = false;
            else if (m.action === "stop") { playback.playing = false; playback.pos = 0; engine.clearEntities(); }
            else if (m.action === "seek") { playback.pos = Math.max(0, Math.min(playback.duration, m.position || 0)); playback.lastT = lastT; }
            else if (m.action === "loop") playback.loop = !!m.value;
            else if (m.action === "speed") playback.speed = m.value || 1;
            else if (m.action === "close") { playback = null; engine.clearEntities(); }
            break;
        case "requestSnapshot": lastUiT = -1; break;
        case "prefs": uiPrefs = { keypoints: !!m.keypoints, sourceMonitor: m.sourceMonitor === undefined ? true : !!m.sourceMonitor }; break;
        }
    }

    function lastMessage(inlet) {
        var vs = inlet.values;
        if (vs && vs.length) return vs[vs.length - 1].value;
        return inlet.value;
    }

    // per-inlet diagnostics for the Source monitor pane (cheap: strings only, preview built at UI rate)
    property var sourceInfo: [null, null, null, null]
    property var lastRaw: [undefined, undefined, undefined, undefined]
    function classify(v) {
        if (typeof v === "string") return "JSON string";
        if (Ingest.isVec(v)) return "single point";
        if (Ingest.isList(v)) {
            if (!v.length) return "empty list";
            var f = v[0];
            if (typeof f === "number") return "flat floats (" + v.length + ")";
            if (Ingest.isVec(f)) return "list of vectors (" + v.length + ")";
            if (Ingest.isList(f)) return "list of lists (" + v.length + ")";
            if (typeof f === "object" && f !== null) return "list of maps (" + v.length + ")";
            return "list (" + v.length + ")";
        }
        if (typeof v === "object" && v !== null) {
            var keys = Object.keys(v);
            if (Ingest.looksLikeEntity(v)) return "one entity map {" + keys.slice(0, 6).join(",") + "}";
            if (isSourceMap(v)) return "map of sources {" + keys.slice(0, 6).join(",") + "}";
            return "map of entities {" + keys.slice(0, 6).join(",") + "}";
        }
        return typeof v;
    }
    function gatherInputs(t) {
        var inputs = [];
        var inlets = [src1, src2, src3, src4];
        var infos = sourceInfo;
        for (var i = 0; i < 4; i++) {
            var s = doc.sources[i];
            var vs = inlets[i].values;
            var info = { inlet: i, enabled: !(!s || s.enabled === false), msgs: vs ? vs.length : 0, kind: "", parsed: 0, ids: [], nan: 0, lastT: -1 };
            if (!info.enabled) { info.kind = "disabled"; infos[i] = info; continue; }
            var v = lastMessage(inlets[i]);
            if (v === undefined || v === null) { info.kind = "no data yet"; infos[i] = info; continue; }
            lastRaw[i] = v;
            info.kind = uiPrefs.sourceMonitor ? classify(v) : "";
            var ents;
            if (isSourceMap(v)) {
                // several sources on one inlet: {name: payload}. All share this inlet's calibration;
                // ids are prefixed with the sub-source name so trackers cannot collide.
                ents = [];
                for (var name in v) {
                    var pl = v[name];
                    if (pl && typeof pl === "object" && (pl.active === false || pl.tracked === false)) continue;
                    var sub = Ingest.parseEntities(pl, s);
                    for (var q = 0; q < sub.length; q++) { sub[q].id = name + "." + sub[q].id; ents.push(sub[q]); }
                }
            } else {
                ents = Ingest.parseEntities(v, s);
            }
            var cal = calibrators[i];
            var kept = [];
            for (var j = 0; j < ents.length; j++) {
                cal.apply(ents[j]);
                var p = ents[j].pos;
                if (!isFinite(p[0]) || !isFinite(p[1]) || !isFinite(p[2])) { info.nan++; continue; }   // never feed NaN to the engine
                kept.push(ents[j]);
                if (uiPrefs.sourceMonitor && info.ids.length < 8) info.ids.push(ents[j].id + " @ " + p[0].toFixed(2) + "," + p[1].toFixed(2) + "," + p[2].toFixed(2));
            }
            info.parsed = ents.length; info.lastT = t;
            infos[i] = info;
            inputs.push({ src: i, entities: kept });
        }
        return inputs;
    }
    function sourceInfoForUi() {
        var out = [];
        for (var i = 0; i < 4; i++) {
            var inf = sourceInfo[i] || { inlet: i, enabled: true, msgs: 0, kind: "no data yet", parsed: 0, ids: [], nan: 0, lastT: -1 };
            var prev = "";
            try { var r = lastRaw[i]; if (r !== undefined) { prev = typeof r === "string" ? r : JSON.stringify(r); if (prev.length > 600) prev = prev.substr(0, 600) + " ..."; } } catch (e) { prev = "(unprintable: " + e + ")"; }
            out.push({ inlet: inf.inlet, enabled: inf.enabled, msgs: inf.msgs, kind: inf.kind, parsed: inf.parsed, ids: inf.ids.join("\n"), nan: inf.nan, lastT: inf.lastT, preview: prev });
        }
        return out;
    }
    // A map whose values are all containers (lists or maps) of entities: {name: payload}.
    // A map whose values are themselves entities (PSN/TUIO/Leap subtrees: {t0: {position...}},
    // {left: {palm...}}) is NOT a source map; parseEntities handles it as one source.
    function isSourceMap(v) {
        if (typeof v !== "object" || v === null || Ingest.isList(v) || Ingest.isVec(v)) return false;
        if (Ingest.looksLikeEntity(v)) return false;
        var keys = Object.keys(v); if (!keys.length) return false;
        for (var i = 0; i < keys.length; i++) {
            var x = v[keys[i]];
            if (Ingest.isList(x)) continue;
            if (typeof x === "object" && x !== null && !Ingest.isVec(x)) { if (Ingest.looksLikeEntity(x)) return false; continue; }
            return false;
        }
        return true;
    }

    function playbackInputs(t) {
        var pb = playback; if (!pb || !pb.frames.length) return [];
        if (pb.playing) {
            pb.pos += (t - pb.lastT) * pb.speed; pb.lastT = t;
            if (pb.pos > pb.duration) { if (pb.loop) { pb.pos = pb.duration > 0 ? pb.pos % pb.duration : 0; engine.clearEntities(); } else { pb.pos = pb.duration; pb.playing = false; } }
        }
        // find frame at pos (binary search)
        var fr = pb.frames, lo = 0, hi = fr.length - 1;
        while (lo < hi) { var mid = (lo + hi + 1) >> 1; if (fr[mid].t <= pb.pos) lo = mid; else hi = mid - 1; }
        var f = fr[lo];
        // inject as recorded (already calibrated, world space) — clone to avoid mutation
        return (f.inputs || []).map(function (inp) { return { src: inp.src, entities: JSON.parse(JSON.stringify(inp.entities)) }; });
    }

    function v3(a) { return Qt.vector3d(a[0], a[1], a[2]); }

    function convertOutputsInPlace(res) {
        // arrays of 3 for positions become vec3 so downstream nodes get vec3f (the snapshot has already been taken)
        var zs = res.zones;
        for (var i = 0; i < zs.length; i++) { var z = zs[i]; z.centroid = v3(z.centroid); var per = z.per_id; if (per) for (var j = 0; j < per.length; j++) per[j].pos = v3(per[j].pos); }
        var es = res.entities;
        for (var k = 0; k < es.length; k++) { var e = es[k]; e.pos = v3(e.pos); e.vel = v3(e.vel); }
    }

    property real perfTickMs: 0
    property real perfEngineMs: 0
    property int perfTicks: 0
    property real perfLastT: 0
    property real perfHz: 0

    tick: function (token, state) {
        var w0 = Util.timestamp();
        var t = token.date / flicksPerSecond;
        if (t < lastT) { /* transport jumped back: keep monotonic engine time */ t = lastT + (state.buffer_size / state.sample_rate); }
        lastT = t;
        // Commands are messages, not retained source state: replaying a previous doc command
        // would overwrite live editor changes (including the event masks) on every tick.
        var commands = cmdIn.values;
        if (commands && commands.length) {
            var cmd = commands[commands.length - 1].value;
            if (cmd !== undefined && cmd !== null) handleCommand(cmd);
        }
        if (bypass.value) return;

        var inputs = playback ? playbackInputs(t) : gatherInputs(t);
        if (simIn.value && simEntities.length && !playback) {
            inputs.push({ src: 4, entities: simEntities.map(function (e) { return { id: String(e.id), pos: [e.pos[0], e.pos[1], e.pos[2] || 0], vel: e.vel ? e.vel.slice() : null, conf: 1, cls: e.cls || "", name: e.name || "", keypoints: null, kpFormat: "", size: null, height: e.height || 0, heading: e.heading === undefined ? null : e.heading, extra: {} }; }) });
        }
        if (recording) recording.frames.push({ t: t - recording.t0, inputs: inputs.map(function (inp) { return { src: inp.src, entities: inp.entities.map(function (e) { return { id: e.id, pos: e.pos, vel: e.vel, conf: e.conf, cls: e.cls, name: e.name, keypoints: e.keypoints, kpFormat: e.kpFormat, size: e.size, height: e.height, heading: e.heading, extra: {} }; }) }; }) });

        var activeSet = setIn.value && String(setIn.value).length ? String(setIn.value) : doc.settings.activeSet;
        if (engine.doc.settings.activeSet !== activeSet) engine.doc.settings.activeSet = activeSet;

        var w1 = Util.timestamp();
        var res = engine.update(inputs, t);
        var w2 = Util.timestamp();
        perfEngineMs = perfEngineMs * 0.9 + (w2 - w1) * 1000 * 0.1;
        // UI snapshot first (it reads positions as arrays), then convert positions to vec3 in place for the outlets
        perfTicks++;
        if (t - perfLastT >= 1) { perfHz = perfTicks / Math.max(0.001, t - perfLastT); perfTicks = 0; perfLastT = t; }
        var rate = doc.settings.uiRate || 30;
        var snap = null;
        if (lastUiT < 0 || t - lastUiT >= 1 / rate) {
            lastUiT = t;
            snap = engine.snapshot(res, uiPrefs);
            snap.type = "snapshot";
            snap.recording = !!recording; snap.recordingFrames = recording ? recording.frames.length : 0;
            snap.playback = playback ? { pos: playback.pos, duration: playback.duration, playing: playback.playing, loop: playback.loop, speed: playback.speed } : null;
            snap.activeSet = activeSet;
            snap.perf = { tickMs: perfTickMs, engineMs: perfEngineMs, tickHz: perfHz };
            snap.sourceInfo = uiPrefs.sourceMonitor ? sourceInfoForUi() : null;   // off = no JSON previews built
            snap.simCount = (simIn.value && !playback) ? simEntities.length : 0;
        }
        convertOutputsInPlace(res);
        outZones.value = res.zones;
        // bounded: never push more than 256 events in one tick downstream
        if (res.events.length) outEvents.value = res.events.length > 256 ? res.events.slice(0, 256) : res.events;
        outEntities.value = res.entities;
        outCounts.value = res.counts;
        outOccupied.value = res.occupied;
        outActivity.value = res.activity;
        outTree.value = res.tree;
        outCount.value = res.count;
        if (res.heatmap.length) outHeat.value = res.heatmap;
        if (doc.settings.proximity && doc.settings.proximity.enabled) outPairs.value = res.pairs;
        emitSimpleOutputs(res);
        if (snap) uiSend(snap);
        perfTickMs = perfTickMs * 0.9 + (Util.timestamp() - w0) * 1000 * 0.1;
    }
    // Simple event outlets (Enter/Leave/Dwell/Cross/Occupancy: one message per event via addValue)
    // and the Location outlet (per-entity current zone, sent on change by default).
    property string lastLocationJson: ""
    function emitSimpleOutputs(res) {
        var so = doc.settings.outputs;
        if (!so) return;
        var n = Math.min(res.events.length, 256);
        for (var i = 0; i < n; i++) {
            var ev = res.events[i];
            var cfg = null, dst = null;
            switch (ev.type) {
            case "enter": cfg = so.enter; dst = outEnter; break;
            case "exit": cfg = so.exit; dst = outLeave; break;
            case "dwell": cfg = so.dwell; dst = outDwell; break;
            case "cross": cfg = so.cross; dst = outCross; break;
            case "occupied": case "empty": cfg = so.occupancy; dst = outOccupancy; break;
            }
            if (cfg && cfg.enabled) dst.addValue(0, ZE.formatEvent(ev, cfg.format));
        }
        var lc = so.location;
        if (lc && lc.enabled) {
            var loc = ZE.locationOutput(res.entities, lc);
            var lj = JSON.stringify(loc);
            if (lc.onChange === false || lj !== lastLocationJson) { lastLocationJson = lj; outLocation.value = loc; }
        }
    }
    function handleCommand(cmd) {
        if (typeof cmd === "string") {
            if (cmd === "reset") engine.resetCounters();
            else if (cmd === "clear") engine.clearEntities();
            else if (cmd.indexOf("set:") === 0) { doc.settings.activeSet = cmd.substr(4); engine.doc.settings.activeSet = doc.settings.activeSet; }
        } else if (typeof cmd === "object" && cmd !== null) {
            if (cmd.cmd === "doc" && cmd.doc !== undefined) { try { applyDoc(typeof cmd.doc === "string" ? JSON.parse(cmd.doc) : cmd.doc); uiSend({ type: "docLoaded", doc: JSON.stringify(doc) }); } catch (e) { console.log("tracking-zones: bad doc command", e); } }
            else if (cmd.cmd === "ui") { var m = {}; for (var kk in cmd) m[kk] = cmd[kk]; m.type = "uiaction"; uiSend(m); }
            else if (cmd.cmd === "reset") engine.resetCounters(cmd.zone || null);
            else if (cmd.cmd === "clear") engine.clearEntities();
            else if (cmd.cmd === "set") { doc.settings.activeSet = String(cmd.value || ""); engine.doc.settings.activeSet = doc.settings.activeSet; }
            else if (cmd.cmd === "enable" && cmd.zone !== undefined) { for (var i = 0; i < doc.zones.length; i++) if (doc.zones[i].name === cmd.zone || doc.zones[i].id === cmd.zone) doc.zones[i].enabled = !!cmd.value; engine.setDoc(doc); }
        }
    }

    start: function () { running = true; lastUiT = -1; }
    stop: function () { running = false; }
}
