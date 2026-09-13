import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "UiUtil.js" as U

// TZGizmo3D: reusable transform gizmo for QtQuick3D with three modes, like common 3D software.
//
//   mode "move":   arrows along X/Y/Z plus an XY pad. Emits dragMoved(axis, deltaVec3, 0).
//   mode "rotate": ring about Z. Emits dragMoved("rz", 0, angleDeltaDeg).
//   mode "scale":  cube handles on X/Y/Z ("sx","sy","sz", deltaVec3 = metres along the axis)
//                  plus a centre cube "suni" (angleDelta = cumulative scale factor).
//
//   * Put it inside the Node whose coordinate system you edit; `target` is the position in that
//     node's coordinates. It keeps a constant size on screen (screenSize px) using `view`/`camera`.
//   * Picking is left to the owner: hit objects expose `gizmoAxis`.
//     Call beginDrag(axis, mx, my) / updateDrag(mx, my) / endDrag() with View3D pixel coordinates;
//     deltas are cumulative since beginDrag.
Node {
    id: gizmo
    required property var view            // View3D
    required property var camera          // Camera used by the view
    property vector3d target: Qt.vector3d(0, 0, 0)
    property vector3d targetRotation: Qt.vector3d(0, 0, 0)   // the target's local frame (deg)
    property string mode: "move"          // move | rotate | scale
    property bool showZ: true
    property real screenSize: 110         // arrow length in pixels
    property string hotAxis: ""           // axis under the mouse
    property string activeAxis: ""        // drag in progress
    signal dragStarted(string axis)
    signal dragMoved(string axis, vector3d delta, real angleDelta)
    signal dragEnded(string axis)

    position: target
    // Scale handles edit the shape's LOCAL dimensions, so in scale mode the gizmo axes follow the
    // target's rotation and drags happen along the axes the user sees. Move stays world-aligned.
    // The drag maths need no change: screenOf/axis2d project the gizmo's local axes, so a rotated
    // axis is projected rotated.
    eulerRotation: scaleMode ? targetRotation : Qt.vector3d(0, 0, 0)
    property vector3d camLocal: parent ? parent.mapPositionFromScene(camera.scenePosition) : Qt.vector3d(0, 0, 10)
    property real dist: Math.max(0.05, camLocal.minus(target).length())
    // metres per pixel at the gizmo's depth (vertical fov): 2 d tan(fov/2) / viewHeight
    property real mpp: (view && view.height > 0) ? (2 * dist * Math.tan((camera.fieldOfView || 60) * Math.PI / 360) / view.height) : 0.01
    property real len: screenSize * mpp
    property real shaft: 0.045 * len
    property real tip: 0.14 * len
    readonly property bool moveMode: mode === "move"
    readonly property bool rotateMode: mode === "rotate"
    readonly property bool scaleMode: mode === "scale"

    function axisColor(a, base) { return hotAxis === a ? "#ffffff" : base; }

    component Arrow: Node {
        id: arrow
        property string axis: "x"
        property color col: "#d05050"
        property bool cubeTip: false      // scale handles end in a cube instead of a cone
        Model { source: "#Cylinder"; pickable: arrow.visible; property string gizmoAxis: arrow.axis
            position: Qt.vector3d(0, gizmo.len * 0.5, 0); scale: Qt.vector3d(gizmo.shaft / 100, gizmo.len / 100, gizmo.shaft / 100)
            materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: gizmo.axisColor(arrow.axis, arrow.col) } }
        Model { source: arrow.cubeTip ? "#Cube" : "#Cone"; pickable: arrow.visible; property string gizmoAxis: arrow.axis
            position: Qt.vector3d(0, gizmo.len + gizmo.tip * 0.5, 0); scale: arrow.cubeTip ? Qt.vector3d(gizmo.tip * 0.7 / 100, gizmo.tip * 0.7 / 100, gizmo.tip * 0.7 / 100) : Qt.vector3d(gizmo.tip * 0.8 / 100, gizmo.tip / 100, gizmo.tip * 0.8 / 100)
            materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: gizmo.axisColor(arrow.axis, arrow.col) } }
        // wide invisible pick shaft so the arrow is easy to grab
        Model { source: "#Cylinder"; pickable: arrow.visible; property string gizmoAxis: arrow.axis; opacity: 0
            position: Qt.vector3d(0, gizmo.len * 0.5, 0); scale: Qt.vector3d(gizmo.shaft * 2.5 / 100, gizmo.len * 0.96 / 100, gizmo.shaft * 2.5 / 100)
            materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#000000"; opacity: 0 } }
    }
    // move
    Arrow { axis: "x"; col: "#d05050"; eulerRotation: Qt.vector3d(0, 0, -90); visible: gizmo.moveMode }
    Arrow { axis: "y"; col: "#50c070"; visible: gizmo.moveMode }
    Arrow { axis: "z"; col: "#5080e0"; eulerRotation: Qt.vector3d(90, 0, 0); visible: gizmo.moveMode && gizmo.showZ }
    // scale
    Arrow { axis: "sx"; col: "#d05050"; cubeTip: true; eulerRotation: Qt.vector3d(0, 0, -90); visible: gizmo.scaleMode }
    Arrow { axis: "sy"; col: "#50c070"; cubeTip: true; visible: gizmo.scaleMode }
    Arrow { axis: "sz"; col: "#5080e0"; cubeTip: true; eulerRotation: Qt.vector3d(90, 0, 0); visible: gizmo.scaleMode && gizmo.showZ }
    Model {   // uniform scale: centre cube
        visible: gizmo.scaleMode
        source: "#Cube"; pickable: gizmo.scaleMode; property string gizmoAxis: "suni"
        scale: Qt.vector3d(gizmo.tip * 0.9 / 100, gizmo.tip * 0.9 / 100, gizmo.tip * 0.9 / 100)
        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: gizmo.axisColor("suni", "#e0c050") }
    }

    // XY plane pad (move)
    Model {
        visible: gizmo.moveMode
        source: "#Rectangle"; pickable: gizmo.moveMode; property string gizmoAxis: "xy"
        position: Qt.vector3d(gizmo.len * 0.3, gizmo.len * 0.3, 0); scale: Qt.vector3d(gizmo.len * 0.22 / 100, gizmo.len * 0.22 / 100, 1)
        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: gizmo.axisColor("xy", "#e0c050"); opacity: gizmo.hotAxis === "xy" ? 0.9 : 0.45; cullMode: Material.NoCulling }
    }
    // Z rotation ring
    Model {
        id: ring
        visible: gizmo.rotateMode
        pickable: gizmo.rotateMode; property string gizmoAxis: "rz"
        property var mesh: { gizmo.len; var m = U.torusMesh(gizmo.len * 1.1, gizmo.shaft * 0.7, 56, 8); var p = [], n = []; for (var i = 0; i < m.positions.length; i++) { p.push(Qt.vector3d(m.positions[i][0], m.positions[i][1], m.positions[i][2])); n.push(Qt.vector3d(m.normals[i][0], m.normals[i][1], m.normals[i][2])); } return { positions: p, normals: n, indices: m.indices }; }
        geometry: ProceduralMesh { positions: ring.mesh.positions; normals: ring.mesh.normals; indexes: ring.mesh.indices }
        materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: gizmo.axisColor("rz", "#5a9be0"); opacity: 0.9; cullMode: Material.NoCulling }
    }
    // invisible pick proxies around the ring (procedural meshes are not reliably pickable)
    Repeater3D {
        model: gizmo.rotateMode ? 32 : 0
        delegate: Model {
            required property int index
            property real a: index / 32 * Math.PI * 2
            source: "#Cube"; pickable: true; property string gizmoAxis: "rz"; opacity: 0
            position: Qt.vector3d(Math.cos(a) * gizmo.len * 1.1, Math.sin(a) * gizmo.len * 1.1, 0)
            eulerRotation: Qt.vector3d(0, 0, a * 180 / Math.PI)
            scale: Qt.vector3d(gizmo.len * 1.1 * 0.2 / 100, gizmo.shaft * 3 / 100, gizmo.shaft * 3 / 100)
            materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#000000"; opacity: 0 }
        }
    }
    // centre knob (move / rotate)
    Model { visible: !gizmo.scaleMode; source: "#Sphere"; scale: Qt.vector3d(gizmo.shaft * 2.2 / 100, gizmo.shaft * 2.2 / 100, gizmo.shaft * 2.2 / 100); materials: DefaultMaterial { lighting: DefaultMaterial.NoLighting; diffuseColor: "#f0f0f0" } }

    // ---------------- drag maths ----------------
    property var drag: null
    function screenOf(localPoint) { var s = gizmo.mapPositionToScene(localPoint); var v = view.mapFrom3DScene(s); return [v.x, v.y]; }
    function rayHitPlane(mx, my, zPlane) {
        // ray from two depths, in parent coordinates; intersect with plane z = zPlane
        var a = gizmo.parent.mapPositionFromScene(view.mapTo3DScene(Qt.vector3d(mx, my, 0.5)));
        var b = gizmo.parent.mapPositionFromScene(view.mapTo3DScene(Qt.vector3d(mx, my, 200)));
        var dz = b.z - a.z; if (Math.abs(dz) < 1e-9) return null;
        var t = (zPlane - a.z) / dz;
        return Qt.vector3d(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, zPlane);
    }
    function beginDrag(axis, mx, my) {
        var o = screenOf(Qt.vector3d(0, 0, 0));
        var d = { axis: axis, mx: mx, my: my, o: o, axis2d: null, len2: 0, plane0: null, a0: 0, sign: 1, r0: 1 };
        var lin = axis === "x" || axis === "y" || axis === "z" || axis === "sx" || axis === "sy" || axis === "sz";
        if (lin) {
            var ax = axis.length === 2 ? axis[1] : axis;
            var p = screenOf(ax === "x" ? Qt.vector3d(1, 0, 0) : (ax === "y" ? Qt.vector3d(0, 1, 0) : Qt.vector3d(0, 0, 1)));
            d.axis2d = [p[0] - o[0], p[1] - o[1]]; d.len2 = d.axis2d[0] * d.axis2d[0] + d.axis2d[1] * d.axis2d[1];
        } else if (axis === "xy") {
            d.plane0 = rayHitPlane(mx, my, target.z);
        } else if (axis === "rz") {
            d.a0 = Math.atan2(my - o[1], mx - o[0]);
            d.sign = camLocal.z >= target.z ? -1 : 1;   // screen y points down: CCW in the world looks CW from above
        } else if (axis === "suni") {
            d.r0 = Math.max(8, Math.hypot(mx - o[0], my - o[1]));
        }
        drag = d; activeAxis = axis; hotAxis = axis; dragStarted(axis);
    }
    function updateDrag(mx, my) {
        var d = drag; if (!d) return;
        var lin = d.axis === "x" || d.axis === "y" || d.axis === "z" || d.axis === "sx" || d.axis === "sy" || d.axis === "sz";
        if (lin) {
            if (d.len2 < 1e-6) return;
            var k = ((mx - d.mx) * d.axis2d[0] + (my - d.my) * d.axis2d[1]) / d.len2;
            var ax = d.axis.length === 2 ? d.axis[1] : d.axis;
            dragMoved(d.axis, ax === "x" ? Qt.vector3d(k, 0, 0) : (ax === "y" ? Qt.vector3d(0, k, 0) : Qt.vector3d(0, 0, k)), 0);
        } else if (d.axis === "xy") {
            var h = rayHitPlane(mx, my, target.z); if (!h || !d.plane0) return;
            dragMoved("xy", Qt.vector3d(h.x - d.plane0.x, h.y - d.plane0.y, 0), 0);
        } else if (d.axis === "rz") {
            var a1 = Math.atan2(my - d.o[1], mx - d.o[0]);
            var da = a1 - d.a0; while (da > Math.PI) da -= 2 * Math.PI; while (da < -Math.PI) da += 2 * Math.PI;
            dragMoved("rz", Qt.vector3d(0, 0, 0), d.sign * da * 180 / Math.PI);
        } else if (d.axis === "suni") {
            var f = Math.max(0.02, Math.hypot(mx - d.o[0], my - d.o[1]) / d.r0);
            dragMoved("suni", Qt.vector3d(0, 0, 0), f);
        }
    }
    function endDrag() { var a = activeAxis; drag = null; activeAxis = ""; hotAxis = ""; if (a) dragEnded(a); }
}
