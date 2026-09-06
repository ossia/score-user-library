import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers
import "Geometry.js" as Geom
import "UiUtil.js" as U
import OssiaUI as S

// 3D view: zones as translucent volumes, entities as pins, orbit camera, pick to select,
// TZGizmo3D to move / rotate the selection, drag a zone body to slide it on the floor.
Item {
    id: v3
    property var owner
    clip: true
    property string dragMode: ""          // "gizmo" | "floor"
    property var dragStart: null
    property var dragStartPositions: ({})
    property var dragStartRots: ({})
    property var dragStartShapes: ({})
    property string hoverAxis: ""
    readonly property real fps: view.renderStats ? view.renderStats.fps : 0
    readonly property real gizmoLen: gizmo.len
    function stats() { var s = view.renderStats; if (!s) return null; return { fps: s.fps, frameTime: s.frameTime, renderTime: s.renderTime, syncTime: s.syncTime, renderPrepareTime: s.renderPrepareTime, maxFrameTime: s.maxFrameTime, drawCalls: s.drawCallCount, vertices: s.drawVertexCount, passes: s.renderPassCount, pipelines: s.pipelineCount, extended: s.extendedDataCollectionEnabled, api: s.graphicsApiName }; }
    readonly property bool gizmoVisible: gizmo.visible

    function zoneState(id) { var zs = owner.zoneStates; return zs ? (zs[id] || null) : null; }
    function snapW(v) { return owner.snapping ? U.snapValue(v, owner.gridStep) : v; }

    // scale-gizmo application: s0 is the shape at drag start, k is metres along the axis
    function applyAxisScale(z, s0, axis, k) {
        if (!s0) return;
        var s = z.shape, t = s.type;
        if (axis === "sx") {
            if (t === "rect" || t === "box") s.w = Math.max(0.05, (s0.w || 1) + 2 * k);
            else if (t === "circle") { if (s0.rx || s0.ry) s.rx = Math.max(0.05, (s0.rx || s0.r || 1) + k); else s.r = Math.max(0.05, (s0.r || 1) + k); }
            else if (t === "sphere" || t === "cylinder") s.r = Math.max(0.05, (s0.r || 1) + k);
            else if (s0.points) { var ex = 0.001; for (var i = 0; i < s0.points.length; i++) ex = Math.max(ex, Math.abs(s0.points[i][0])); var fx = Math.max(0.02, (ex + k) / ex); s.points = s0.points.map(function (p) { return [p[0] * fx, p[1]]; }); }
        } else if (axis === "sy") {
            if (t === "rect" || t === "box") s.h = Math.max(0.05, (s0.h || 1) + 2 * k);
            else if (t === "circle") { if (s0.rx || s0.ry) s.ry = Math.max(0.05, (s0.ry || s0.r || 1) + k); else s.r = Math.max(0.05, (s0.r || 1) + k); }
            else if (t === "sphere" || t === "cylinder") s.r = Math.max(0.05, (s0.r || 1) + k);
            else if (s0.points) { var ey = 0.001; for (var j = 0; j < s0.points.length; j++) ey = Math.max(ey, Math.abs(s0.points[j][1])); var fy = Math.max(0.02, (ey + k) / ey); s.points = s0.points.map(function (p) { return [p[0], p[1] * fy]; }); }
        } else { // sz
            if (t === "box" || t === "cylinder") s.d = Math.max(0.05, (s0.d || 1) + 2 * k);
            else if (t === "sphere") s.r = Math.max(0.05, (s0.r || 1) + k);
            else if (s0.useZ) s.zmax = Math.max((s0.zmin || 0) + 0.05, (s0.zmax === undefined ? 2 : s0.zmax) + k);
        }
    }
    function applyUniformScale(z, s0, f) {
        if (!s0) return;
        f = Math.max(0.02, f);
        var s = z.shape, t = s.type;
        if (t === "rect" || t === "box") { s.w = Math.max(0.05, (s0.w || 1) * f); s.h = Math.max(0.05, (s0.h || 1) * f); if (t === "box") s.d = Math.max(0.05, (s0.d || 1) * f); }
        else if (t === "circle") { if (s0.rx) s.rx = Math.max(0.05, s0.rx * f); if (s0.ry) s.ry = Math.max(0.05, s0.ry * f); s.r = Math.max(0.05, (s0.r || 1) * f); }
        else if (t === "sphere") s.r = Math.max(0.05, (s0.r || 1) * f);
        else if (t === "cylinder") { s.r = Math.max(0.05, (s0.r || 1) * f); s.d = Math.max(0.05, (s0.d || 1) * f); }
        else if (s0.points) { s.points = s0.points.map(function (p) { return [p[0] * f, p[1] * f]; }); if (s0.width) s.width = Math.max(0.01, s0.width * f); }
    }

    View3D {
        id: view
        anchors.fill: parent
        camera: camera
        renderStats.extendedDataCollectionEnabled: true
        environment: SceneEnvironment { clearColor: "#141312"; backgroundMode: SceneEnvironment.Color; antialiasingMode: SceneEnvironment.MSAA; antialiasingQuality: SceneEnvironment.Medium }

        Node {
            id: orbitOrigin
            position: Qt.vector3d(0, 0, 0)
            eulerRotation: Qt.vector3d(-35, 0, 0)
            PerspectiveCamera { id: camera; position: Qt.vector3d(0, 0, 14); clipNear: 0.05; clipFar: 500; fieldOfView: 55 }
        }
        DirectionalLight { eulerRotation: Qt.vector3d(-50, 30, 0); brightness: 1.0; ambientColor: "#404040" }
        DirectionalLight { eulerRotation: Qt.vector3d(40, -120, 0); brightness: 0.4 }

        // World root: ossia world is Z-up; Quick3D scene is Y-up. Rotating the root by -90° about X maps world (x,y,z) to scene (x,z,-y).
        Node {
            id: world
            eulerRotation: Qt.vector3d(-90, 0, 0)

            // floor grid
            Model {
                geometry: GridGeometry { property real st: Math.max(0.1, owner.gridStep); property int n: Math.min(201, Math.round(40 / st) + 1); horizontalLines: n; verticalLines: n; horizontalStep: st; verticalStep: st }
                materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#2c2a27" }
                position: Qt.vector3d(0, 0, -0.002)
            }
            // floor plan backdrop (Settings › Floor plan)
            Model {
                id: backdrop3d
                property var bd: { owner.docVersion; return owner.doc.settings.backdrop; }
                visible: bd && bd.path && bd.path.length > 0
                source: "#Rectangle"
                position: bd ? Qt.vector3d(bd.x, bd.y, -0.001) : Qt.vector3d(0, 0, 0)
                eulerRotation: Qt.vector3d(0, 0, bd ? (bd.rotation || 0) : 0)
                scale: bd ? Qt.vector3d(bd.w / 100, bd.h / 100, 1) : Qt.vector3d(1, 1, 1)
                materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; opacity: backdrop3d.bd ? backdrop3d.bd.opacity : 0.5; cullMode: Material.NoCulling
                    diffuseMap: Texture { source: owner.floorPlanUrl } }
            }
            // pickable invisible floor for dragging
            Model {
                id: floorPick
                source: "#Rectangle"
                scale: Qt.vector3d(10, 10, 1)   // 1000 m
                pickable: true
                opacity: 0.0
                materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#000000"; opacity: 0 }
                property bool isFloor: true
            }
            // axes
            Model { source: "#Cube"; scale: Qt.vector3d(0.01, 0.0008, 0.0008); position: Qt.vector3d(0.5, 0, 0); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#d05050" } }
            Model { source: "#Cube"; scale: Qt.vector3d(0.0008, 0.01, 0.0008); position: Qt.vector3d(0, 0.5, 0); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#50d070" } }
            Model { source: "#Cube"; scale: Qt.vector3d(0.0008, 0.0008, 0.01); position: Qt.vector3d(0, 0, 0.5); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#5080e0" } }

            // zones
            Repeater3D {
                model: { owner.docVersion; return owner.doc.zones.length; }
                delegate: Node {
                    id: zoneNode
                    required property int index
                    // rev makes every geometry binding below re-evaluate on live edits: the doc mutates in
                    // place, so zn/s keep the same reference and would never signal by themselves.
                    property int rev: owner.docVersion
                    property var zn: { owner.docVersion; return index < owner.doc.zones.length ? owner.doc.zones[index] : null; }
                    property var st: { owner.zoneStates; return zn ? v3.zoneState(zn.id) : null; }
                    property bool selected: zn ? owner.isSelected(zn.id) : false
                    property color baseCol: { rev; return zn ? (zn.role === "exclude" ? "#d96b6b" : (zn.role === "include" ? "#7fc45a" : zn.color)) : "#888"; }
                    property color col: selected ? Qt.lighter(baseCol, 1.35) : baseCol
                    property real alpha: zn ? (zn.enabled === false ? 0.08 : ((st && st.occupied) ? 0.6 : (selected ? 0.42 : 0.25))) : 0.2
                    visible: zn && zn.visible !== false
                    position: { rev; return zn ? Qt.vector3d(zn.pos[0], zn.pos[1], zn.pos[2]) : Qt.vector3d(0, 0, 0); }
                    eulerRotation: { rev; return zn ? Qt.vector3d(zn.rot[0] || 0, zn.rot[1] || 0, zn.rot[2] || 0) : Qt.vector3d(0, 0, 0); }
                    property var s: zn ? zn.shape : null
                    property bool useZ: { rev; return s ? !!s.useZ : false; }
                    property real zmin: { rev; return s ? (s.zmin || 0) : 0; }
                    property real zmax: { rev; return s ? (s.zmax === undefined ? 2 : s.zmax) : 2; }
                    property real slabH: useZ ? Math.max(0.01, zmax - zmin) : 0.02
                    property real slabZ: useZ ? (zmin + zmax) / 2 : 0

                    Model {   // rect / box
                        visible: zoneNode.s && (zoneNode.s.type === "rect" || zoneNode.s.type === "box")
                        source: "#Cube"; pickable: visible
                        property string zoneId: zoneNode.zn ? zoneNode.zn.id : ""
                        scale: { zoneNode.rev; return zoneNode.s ? Qt.vector3d((zoneNode.s.w || 1) / 100, (zoneNode.s.h || 1) / 100, (zoneNode.s.type === "box" ? (zoneNode.s.d || 1) : zoneNode.slabH) / 100) : Qt.vector3d(0.01, 0.01, 0.01); }
                        position: { zoneNode.rev; return Qt.vector3d(0, 0, zoneNode.s && zoneNode.s.type === "box" ? 0 : zoneNode.slabZ); }
                        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: zoneNode.col; opacity: zoneNode.alpha; cullMode: Material.NoCulling }
                    }
                    Model {   // circle / cylinder
                        visible: zoneNode.s && (zoneNode.s.type === "circle" || zoneNode.s.type === "cylinder")
                        source: "#Cylinder"; pickable: visible
                        property string zoneId: zoneNode.zn ? zoneNode.zn.id : ""
                        eulerRotation: Qt.vector3d(90, 0, 0)
                        scale: { zoneNode.rev; return zoneNode.s ? Qt.vector3d(2 * (zoneNode.s.rx || zoneNode.s.r || 1) / 100, (zoneNode.s.type === "cylinder" ? (zoneNode.s.d || 1) : zoneNode.slabH) / 100, 2 * (zoneNode.s.ry || zoneNode.s.r || 1) / 100) : Qt.vector3d(0.01, 0.01, 0.01); }
                        position: { zoneNode.rev; return Qt.vector3d(0, 0, zoneNode.s && zoneNode.s.type === "cylinder" ? 0 : zoneNode.slabZ); }
                        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: zoneNode.col; opacity: zoneNode.alpha; cullMode: Material.NoCulling }
                    }
                    Model {   // sphere
                        visible: zoneNode.s && zoneNode.s.type === "sphere"
                        source: "#Sphere"; pickable: visible
                        property string zoneId: zoneNode.zn ? zoneNode.zn.id : ""
                        scale: { zoneNode.rev; return zoneNode.s ? Qt.vector3d(2 * (zoneNode.s.r || 1) / 100, 2 * (zoneNode.s.r || 1) / 100, 2 * (zoneNode.s.r || 1) / 100) : Qt.vector3d(0.01, 0.01, 0.01); }
                        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: zoneNode.col; opacity: zoneNode.alpha; cullMode: Material.NoCulling }
                    }
                    Model {   // polygon / prism (extruded)
                        id: polyModel
                        visible: zoneNode.s && (zoneNode.s.type === "polygon" || zoneNode.s.type === "prism")
                        pickable: visible
                        property string zoneId: zoneNode.zn ? zoneNode.zn.id : ""
                        property var mesh: { owner.docVersion; if (!zoneNode.s || !zoneNode.s.points) return { positions: [], indices: [] }; var m = Geom.extrudePolygon(zoneNode.s.points, zoneNode.useZ ? zoneNode.zmin : -0.01, zoneNode.useZ ? zoneNode.zmax : 0.01); var pos = []; for (var i = 0; i < m.positions.length; i += 3) pos.push(Qt.vector3d(m.positions[i], m.positions[i + 1], m.positions[i + 2])); return { positions: pos, indices: m.indices }; }
                        geometry: ProceduralMesh { positions: polyModel.mesh.positions; indexes: polyModel.mesh.indices }
                        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: zoneNode.col; opacity: zoneNode.alpha; cullMode: Material.NoCulling }
                    }
                    Repeater3D {   // line / path segments
                        model: { zoneNode.rev; return zoneNode.s && (zoneNode.s.type === "line" || zoneNode.s.type === "path") && zoneNode.s.points ? Math.max(0, zoneNode.s.points.length - 1) : 0; }
                        delegate: Model {
                            required property int index
                            property var a: { zoneNode.rev; return zoneNode.s.points[index]; }
                            property var b: { zoneNode.rev; return zoneNode.s.points[index + 1]; }
                            property real len: Math.hypot(b[0] - a[0], b[1] - a[1])
                            property real ang: Math.atan2(b[1] - a[1], b[0] - a[0]) * 180 / Math.PI
                            source: "#Cube"; pickable: true
                            property string zoneId: zoneNode.zn ? zoneNode.zn.id : ""
                            position: Qt.vector3d((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, zoneNode.useZ ? zoneNode.slabZ : (zoneNode.s.type === "line" ? 0.5 : 0.01))
                            eulerRotation: Qt.vector3d(0, 0, ang)
                            scale: { zoneNode.rev; return Qt.vector3d(len / 100, (zoneNode.s.type === "path" ? (zoneNode.s.width || 1) : 0.03) / 100, (zoneNode.useZ ? zoneNode.slabH : (zoneNode.s.type === "line" ? 1 : 0.02)) / 100); }
                            materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: zoneNode.col; opacity: zoneNode.s.type === "line" ? 0.35 : zoneNode.alpha; cullMode: Material.NoCulling }
                        }
                    }
                }
            }

            // live entities: a pool of pin nodes updated imperatively per snapshot (no per-entity bindings → cheap at 30 Hz)
            // Shared low-poly geometry + unlit materials keep the vertex count and pipeline count low.
            ProceduralMesh { id: pinSphereGeom; property var m: U.sphereMesh(8, 5); positions: m.positions.map(function (p) { return Qt.vector3d(p[0], p[1], p[2]); }); indexes: m.indices }
            ProceduralMesh { id: pinCylGeom; property var m: U.cylinderMesh(8); positions: m.positions.map(function (p) { return Qt.vector3d(p[0], p[1], p[2]); }); indexes: m.indices }
            Node {
                id: entityPool
                property var nodes: []
                Component {
                    id: pinComp
                    Node {
                        property color col: "#ffffff"
                        property real h: 0
                        property bool inZone: false
                        Model { geometry: pinSphereGeom; scale: Qt.vector3d(0.15, 0.15, 0.15); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: parent.parent.col } }
                        Model { visible: parent.h > 0; geometry: pinCylGeom; scale: Qt.vector3d(0.17, 0.17, parent.h); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: parent.parent.col; opacity: 0.35; cullMode: Material.NoCulling } }
                        Model { visible: parent.inZone; geometry: pinSphereGeom; scale: Qt.vector3d(0.24, 0.24, 0.24); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#ffffff"; opacity: 0.25 } }
                    }
                }
                function apply(ents) {
                    var n = ents ? ents.length : 0;
                    while (nodes.length < n) { var o = pinComp.createObject(entityPool); if (!o) break; nodes.push(o); }
                    for (var i = 0; i < nodes.length; i++) {
                        var nd = nodes[i];
                        if (i >= n) { if (nd.visible) nd.visible = false; continue; }
                        var e = ents[i];
                        nd.position = Qt.vector3d(e.pos[0], e.pos[1], e.pos[2]);
                        nd.col = e.masked ? "#6f7a75" : (e.src === 4 || e.src === "sim" ? "#ffffff" : U.srcColor(e.src));
                        nd.h = e.height > 0 ? e.height : 0;
                        nd.inZone = !!(e.zones && e.zones.length);
                        if (!nd.visible) nd.visible = true;
                    }
                }
                Connections { target: owner; function onSnapshotChanged() { if (v3.visible) entityPool.apply(owner.liveData && owner.snapshot ? owner.snapshot.entities : []); } function onLiveDataChanged() { if (!owner.liveData) entityPool.apply([]); } }
            }
            // simulator ghosts (UI-side positions: visible even when the transport is stopped)
            Repeater3D {
                model: { owner.simVersion; return owner.simEnabled ? owner.simEntities.length : 0; }
                delegate: Node {
                    id: simNode
                    required property int index
                    property var e: { owner.simVersion; return index < owner.simEntities.length ? owner.simEntities[index] : null; }
                    visible: e !== null
                    position: e ? Qt.vector3d(e.pos[0], e.pos[1], e.pos[2] || 0) : Qt.vector3d(0, 0, 0)
                    property real h: e && e.height > 0 ? e.height : 1.7
                    Model { geometry: pinSphereGeom; scale: Qt.vector3d(0.13, 0.13, 0.13); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#ffffff"; opacity: owner.liveData ? 0.35 : 0.9 } }
                    Model { geometry: pinCylGeom; scale: Qt.vector3d(0.15, 0.15, simNode.h); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#ffffff"; opacity: owner.liveData ? 0.12 : 0.3; cullMode: Material.NoCulling } }
                }
            }

            // transform gizmo on the selected zone
            TZGizmo3D {
                id: gizmo
                view: view; camera: camera
                mode: owner.gizmoMode
                visible: owner.selectedZone !== null && !owner.showMode && owner.viewMode !== "2d"
                target: { owner.docVersion; var z = owner.selectedZone; return z ? Qt.vector3d(z.pos[0], z.pos[1], z.pos[2]) : Qt.vector3d(0, 0, 0); }
                targetRotation: { owner.docVersion; var z = owner.selectedZone; return z && z.rot ? Qt.vector3d(z.rot[0] || 0, z.rot[1] || 0, z.rot[2] || 0) : Qt.vector3d(0, 0, 0); }
                onDragStarted: function (axis) {
                    v3.dragStartPositions = {}; v3.dragStartRots = {}; v3.dragStartShapes = {};
                    for (var i = 0; i < owner.selection.length; i++) { var zz = owner.zoneById(owner.selection[i]); if (zz) { v3.dragStartPositions[zz.id] = zz.pos.slice(); v3.dragStartRots[zz.id] = (zz.rot || [0, 0, 0]).slice(); v3.dragStartShapes[zz.id] = JSON.parse(JSON.stringify(zz.shape)); } }
                }
                onDragMoved: function (axis, delta, angle) {
                    for (var i = 0; i < owner.selection.length; i++) {
                        var z = owner.zoneById(owner.selection[i]); if (!z || z.locked) continue;
                        var sp = v3.dragStartPositions[z.id]; if (!sp) continue;
                        if (axis === "rz") { var r0 = v3.dragStartRots[z.id] || [0, 0, 0]; var na = r0[2] + angle; if (owner.snapping) na = Math.round(na / 5) * 5; z.rot = [r0[0], r0[1], na]; }
                        else if (axis === "sx" || axis === "sy" || axis === "sz") v3.applyAxisScale(z, v3.dragStartShapes[z.id], axis, axis === "sx" ? delta.x : (axis === "sy" ? delta.y : delta.z));
                        else if (axis === "suni") v3.applyUniformScale(z, v3.dragStartShapes[z.id], angle);
                        else z.pos = [v3.snapW(sp[0] + delta.x), v3.snapW(sp[1] + delta.y), v3.snapW(sp[2] + delta.z)];
                    }
                    owner.touch();
                }
                onDragEnded: function (axis) { owner.commit(axis === "rz" ? "Rotate zone" : (axis[0] === "s" ? "Resize zone" : "Move zone")); }
            }
        }

        OrbitCameraController { id: orbit; anchors.fill: parent; origin: orbitOrigin; camera: camera; panEnabled: true; xSpeed: 0.25; ySpeed: 0.25 }
    }

    // picking: gizmo handles first, then zones, then the floor; unhandled presses fall through to the orbit controller
    function pickAt(x, y) {
        var res = view.pickAll(x, y);
        var out = { gizmo: "", zone: "", floor: null };
        for (var i = 0; i < res.length; i++) {
            var o = res[i].objectHit; if (!o) continue;
            if (!out.gizmo && o.gizmoAxis !== undefined && o.gizmoAxis !== "") out.gizmo = o.gizmoAxis;
            else if (!out.zone && o.zoneId !== undefined && o.zoneId !== "") out.zone = o.zoneId;
            else if (!out.floor && o.isFloor) { var p = world.mapPositionFromScene(res[i].scenePosition); out.floor = [p.x, p.y, p.z]; }
        }
        return out;
    }
    function floorPoint(x, y) { var r = pickAt(x, y); return r.floor; }
    // world (Z-up) point -> view pixel, for tests and overlays
    function project(x, y, z) { var s = world.mapPositionToScene(Qt.vector3d(x, y, z || 0)); var v = view.mapFrom3DScene(s); return [v.x, v.y]; }

    // right-drag pan (OrbitCameraController only pans with Ctrl+drag)
    property var panLast: null
    function panBy(dx, dy) {
        var dist = camera.position.length();
        var mpp = 2 * dist * Math.tan(camera.fieldOfView * Math.PI / 360) / Math.max(1, view.height);
        var right = camera.mapDirectionToScene(Qt.vector3d(1, 0, 0));
        var up = camera.mapDirectionToScene(Qt.vector3d(0, 1, 0));
        orbitOrigin.position = orbitOrigin.position.minus(right.times(dx * mpp)).plus(up.times(dy * mpp));
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        preventStealing: true
        cursorShape: v3.dragMode.length ? Qt.ClosedHandCursor : (v3.hoverAxis.length ? Qt.OpenHandCursor : Qt.ArrowCursor)
        onPressed: function (m) {
            if (m.button === Qt.RightButton) { v3.dragMode = "pan"; v3.panLast = [m.x, m.y]; m.accepted = true; return; }
            var hit = pickAt(m.x, m.y);
            // creation tools work here too: click the floor to place the shape
            var t = owner.tool;
            if (t !== "select" && t !== "pan" && !owner.showMode) {
                var fp = hit.floor || floorPoint(m.x, m.y);
                if (fp) {
                    if (t === "sim") owner.addDummy(fp[0], fp[1]);
                    else { owner.addZone(t, v3.snapW(fp[0]), v3.snapW(fp[1])); owner.tool = "select"; }
                    m.accepted = true; return;
                }
            }
            if (hit.gizmo && gizmo.visible) {
                owner.forceActiveFocus();
                v3.dragMode = "gizmo"; gizmo.beginDrag(hit.gizmo, m.x, m.y); m.accepted = true; return;
            }
            if (hit.zone) {
                owner.forceActiveFocus();
                if (m.modifiers & Qt.ShiftModifier) owner.select(hit.zone, true); else if (!owner.isSelected(hit.zone)) owner.select(hit.zone, false);
                if (owner.showMode) { m.accepted = true; return; }
                v3.dragMode = "floor"; v3.dragStart = hit.floor || floorPoint(m.x, m.y);
                v3.dragStartPositions = {}; for (var i = 0; i < owner.selection.length; i++) { var zz = owner.zoneById(owner.selection[i]); if (zz) v3.dragStartPositions[zz.id] = zz.pos.slice(); }
                m.accepted = true; return;
            }
            m.accepted = false; // orbit / pan
        }
        onPositionChanged: function (m) {
            if (v3.dragMode === "pan") { if (v3.panLast) v3.panBy(m.x - v3.panLast[0], m.y - v3.panLast[1]); v3.panLast = [m.x, m.y]; return; }
            if (v3.dragMode === "gizmo") { gizmo.updateDrag(m.x, m.y); return; }
            if (v3.dragMode === "floor") {
                if (!v3.dragStart) return;
                var fp = floorPoint(m.x, m.y); if (!fp) return;
                var dx = fp[0] - v3.dragStart[0], dy = fp[1] - v3.dragStart[1];
                for (var i = 0; i < owner.selection.length; i++) { var z = owner.zoneById(owner.selection[i]); if (!z || z.locked) continue; var sp = v3.dragStartPositions[z.id]; if (!sp) continue; z.pos = [v3.snapW(sp[0] + dx), v3.snapW(sp[1] + dy), sp[2]]; }
                owner.touch(); return;
            }
            if (gizmo.visible) { var h = pickAt(m.x, m.y); v3.hoverAxis = h.gizmo; gizmo.hotAxis = h.gizmo; }
        }
        function finishDrag() {
            if (v3.dragMode === "gizmo") gizmo.endDrag();
            else if (v3.dragMode === "floor") owner.commit("Move zone");
            v3.dragMode = ""; v3.dragStart = null; v3.panLast = null;
        }
        onReleased: finishDrag()
        onCanceled: finishDrag()
        onExited: { v3.hoverAxis = ""; if (!v3.dragMode) gizmo.hotAxis = ""; }
    }

    S.SImageDropArea {
        anchors.fill: parent; enabled: !owner.showMode
        onFilesDropped: function(paths, x, y) {
            var point = v3.floorPoint(x, y);
            if (point) owner.applyFloorPlan(paths[0], point);
            else owner.statusText = "Drop the floor plan on the floor";
        }
    }

    // overlay: gizmo mode buttons + selected zone
    Row {
        id: modeRow
        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 6
        spacing: 3
        Repeater {
            model: [["Move", "move", "W"], ["Rotate", "rotate", "E"], ["Scale", "scale", "R"]]
            Rectangle {
                required property var modelData
                width: mt.implicitWidth + 16; height: 22; radius: 3
                color: owner.gizmoMode === modelData[1] ? "#62400a" : (mma.containsMouse ? "#2c2a27" : "#1d1c1a")
                border.color: owner.gizmoMode === modelData[1] ? "#c58014" : "#3a3835"
                Text { id: mt; anchors.centerIn: parent; text: parent.modelData[0]; font.pixelSize: 10; color: "#e6ebe8" }
                MouseArea { id: mma; anchors.fill: parent; hoverEnabled: true; onClicked: owner.gizmoMode = parent.modelData[1] }
                ToolTip.visible: mma.containsMouse; ToolTip.delay: 600; ToolTip.text: modelData[0] + " (" + modelData[2] + ")"
            }
        }
    }
    Label {
        id: zoneLabel
        anchors.left: parent.left; anchors.top: modeRow.bottom; anchors.margins: 6; anchors.topMargin: 3
        visible: owner.selectedZone !== null
        text: owner.selectedZone ? owner.selectedZone.name : ""
        font.pixelSize: 10; color: "#9a958e"
        background: Rectangle { color: "#80141312"; radius: 3 }
        padding: 3
        MouseArea {
            anchors.fill: parent
            enabled: owner.tool === "select" && !owner.showMode
            onDoubleClicked: {
                if (owner.selectedZone) owner.renameZone(owner.selectedId, v3, zoneLabel.x, zoneLabel.y, zoneLabel.width, 10);
            }
        }
    }
    Row {
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 6; spacing: 6
        Label { text: v3.fps > 0 ? (v3.fps.toFixed(0) + " fps") : ""; font.pixelSize: 10; color: "#9a958e"; padding: 3; anchors.verticalCenter: parent.verticalCenter; background: Rectangle { color: "#80141312"; radius: 3 } }
        Button { text: "Reset view"; implicitHeight: 22; font.pixelSize: 10; onClicked: { orbitOrigin.position = Qt.vector3d(0, 0, 0); orbitOrigin.eulerRotation = Qt.vector3d(-35, 0, 0); camera.position = Qt.vector3d(0, 0, 14); } }
    }
}
