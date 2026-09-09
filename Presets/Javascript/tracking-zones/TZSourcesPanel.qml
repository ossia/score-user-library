import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "UiUtil.js" as U
import "Ingest.js" as Ingest
import OssiaUI as S

// Sources & calibration: one card per inlet. An inlet can carry a single source or a map of
// several ({name: payload}, e.g. a device container with one child per sensor); every source
// arriving on an inlet shares the card's settings, so group sensors of the same kind per inlet.
Item {
    id: panel
    property var owner
    property int v: owner.docVersion

    function sget(key, path, def) { v; var s = owner.sourceCfg(key); if (!s) return def; var r = U.deepGet(s, path); return r === undefined || r === null ? def : r; }
    function health(key) { var s = owner.snapshot; if (!s || !s.sources) return null; return s.sources[String(key)] || null; }

    component SmallNum: TextField {
        id: sn
        property real value: 0
        property int decimals: 2
        signal edited(real v)
        property string path: ""      // source property, for double-click reset
        property int idx: -1
        function defaultValue() { if (!path.length) return undefined; var dv = U.deepGet(Ingest.defaultSource(0), path); if (dv === undefined || dv === null) return undefined; if (idx >= 0) return dv[idx]; return typeof dv === "number" ? dv : undefined; }
        implicitWidth: 54; implicitHeight: 22; topPadding: 2; bottomPadding: 2; font.pixelSize: 10; selectByMouse: true
        text: U.fmt(value, decimals)
        validator: DoubleValidator { notation: DoubleValidator.StandardNotation }
        onEditingFinished: { var nv = parseFloat(text); if (!isNaN(nv) && Math.abs(nv - value) > 1e-9) edited(nv); rebind(); }
        function rebind() { text = Qt.binding(function () { return U.fmt(value, decimals); }); }
        S.SNumDrag { field: sn; value: sn.value; decimals: sn.decimals; onDragged: function (v) { sn.text = U.fmt(v, sn.decimals); } onCommitted: function (v) { sn.edited(v); sn.rebind(); } onReset: { var dv = sn.defaultValue(); if (dv !== undefined) { sn.edited(dv); sn.rebind(); } } }
    }
    component L: Label { font.pixelSize: 10; color: palette.windowText }

    ColumnLayout {
        anchors.fill: parent
        spacing: 2
        L {
            Layout.fillWidth: true
            text: "One card per inlet. An inlet takes one source, or several at once as a map {name: payload} (for example a device container like local:/tracking with one child per sensor). Every source on an inlet shares the card's calibration, so group sensors of the same kind: inlet 1 camera boxes, inlet 2 centroids, inlet 3 BlackTrax..."
            wrapMode: Text.WordWrap; color: palette.placeholderText
        }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            contentHeight: availableHeight
            Row {
                spacing: 4
                height: parent.height
                Repeater {
                    model: panel.owner.sourceKeys()
                    Rectangle {
                        id: card
                        required property var modelData
                        property var key: modelData
                        width: 300; height: parent.height
                        color: palette.alternateBase; radius: 3; border.color: palette.mid
                        property var h: { owner.snapshot; return panel.health(key); }
                        property bool alive: h && owner.liveData && owner.snapshot && (owner.snapshot.t - h.lastT) < 1.0
                        ScrollView {
                            anchors.fill: parent; anchors.margins: 4; clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            contentWidth: availableWidth
                            ColumnLayout {
                                width: card.width - 30   // leaves room for the vertical scrollbar so the combos keep their right edge visible
                                spacing: 2
                                RowLayout {
                                    Layout.fillWidth: true
                                    S.SCheck { checked: panel.sget(card.key, "enabled", true); onToggled: owner.setSource(card.key, "enabled", checked, "Source enabled") }
                                    TextField { Layout.preferredWidth: 92; implicitHeight: 22; topPadding: 2; bottomPadding: 2; font.pixelSize: 11; font.bold: true; text: panel.sget(card.key, "name", "Source " + (card.key + 1)); selectByMouse: true; onEditingFinished: owner.setSource(card.key, "name", text, "Source name") }
                                    L { text: "inlet " + (card.key + 1); color: palette.placeholderText }
                                    Rectangle { width: 8; height: 8; radius: 4; color: card.alive ? S.Theme.accent : "#555" }
                                    L { text: card.h && card.alive ? (U.fmt(card.h.fps, 0) + " Hz, " + card.h.n) : "no data"; color: palette.placeholderText; Layout.fillWidth: true; elide: Text.ElideRight }
                                }
                                GridLayout {
                                    columns: 2; columnSpacing: 4; rowSpacing: 2; Layout.fillWidth: true
                                    L { text: "Units" }
                                    S.SCombo { Layout.preferredWidth: 200; Layout.maximumWidth: 200; model: ["m", "cm", "mm", "ft", "in", "custom"]; currentIndex: Math.max(0, model.indexOf(panel.sget(card.key, "units", "m"))); onActivated: function (i) { owner.setSource(card.key, "units", model[i], "Source units"); } }
                                    L { visible: panel.sget(card.key, "units", "m") === "custom"; text: "Scale" }
                                    SmallNum { visible: panel.sget(card.key, "units", "m") === "custom"; Layout.fillWidth: true; path: "unitScale"; value: panel.sget(card.key, "unitScale", 1); decimals: 4; onEdited: function (v) { owner.setSource(card.key, "unitScale", v, "Source scale"); } }
                                    L { text: "Axes" }
                                    S.SCombo { Layout.preferredWidth: 200; Layout.maximumWidth: 200; model: ["Z up (x,y,z)", "Y up (OpenGL/PSN/XR)", "Camera x right, y up, z fwd", "Custom spec"]; property var keys: ["xyz", "yup", "camera-yup", "custom"]; currentIndex: Math.max(0, keys.indexOf(panel.sget(card.key, "axes", "xyz"))); onActivated: function (i) { owner.setSource(card.key, "axes", keys[i], "Source axes"); } }
                                    L { visible: panel.sget(card.key, "axes", "xyz") === "custom"; text: "Spec" }
                                    TextField { visible: panel.sget(card.key, "axes", "xyz") === "custom"; Layout.fillWidth: true; implicitHeight: 22; topPadding: 2; bottomPadding: 2; font.pixelSize: 10; placeholderText: "x,-z,y"; text: panel.sget(card.key, "axisSpec", ""); onEditingFinished: owner.setSource(card.key, "axisSpec", text, "Axis spec") }
                                    L { text: "Origin" }
                                    S.SCombo { Layout.preferredWidth: 200; Layout.maximumWidth: 200; model: ["World coordinates", "Normalised 0..1 (top-left)", "Pixels (top-left)"]; property var keys: ["world", "normalized", "pixels"]; currentIndex: Math.max(0, keys.indexOf(panel.sget(card.key, "originMode", "world"))); onActivated: function (i) { owner.setSource(card.key, "originMode", keys[i], "Source origin"); } }
                                    L { text: "Data" }
                                    S.SCombo { Layout.preferredWidth: 200; Layout.maximumWidth: 200; model: ["Auto detect", "Points [x,y]", "Points [x,y,z]", "Boxes [x,y,w,h]", "Boxes [x1,y1,x2,y2]", "Boxes 3D [x1,y1,z1,x2,y2,z2]"]; property var keys: ["auto", "points2", "points3", "boxes_xywh", "boxes_corners2", "boxes_corners3"]; currentIndex: Math.max(0, keys.indexOf(panel.sget(card.key, "dataFormat", "auto"))); onActivated: function (i) { owner.setSource(card.key, "dataFormat", keys[i], "Source data format"); }; ToolTip.visible: hovered; ToolTip.text: "How bare numeric lists are read. Maps (Point Tracker, Pose Detector, PSN) are recognised automatically." }
                                }
                                RowLayout {
                                    visible: panel.sget(card.key, "originMode", "world") === "normalized"
                                    L { text: "Scene W×H m" }
                                    SmallNum { path: "scene.w"; value: panel.sget(card.key, "scene.w", 4); onEdited: function (v) { owner.setSource(card.key, "scene.w", Math.max(0.01, v), "Scene size"); } }
                                    SmallNum { path: "scene.h"; value: panel.sget(card.key, "scene.h", 3); onEdited: function (v) { owner.setSource(card.key, "scene.h", Math.max(0.01, v), "Scene size"); } }
                                }
                                RowLayout {
                                    visible: panel.sget(card.key, "originMode", "world") === "pixels"
                                    L { text: "Px W×H, m/px" }
                                    SmallNum { path: "pixels.w"; value: panel.sget(card.key, "pixels.w", 1920); decimals: 0; onEdited: function (v) { owner.setSource(card.key, "pixels.w", v, "Pixel size"); } }
                                    SmallNum { path: "pixels.h"; value: panel.sget(card.key, "pixels.h", 1080); decimals: 0; onEdited: function (v) { owner.setSource(card.key, "pixels.h", v, "Pixel size"); } }
                                    SmallNum { path: "pixels.mpp"; value: panel.sget(card.key, "pixels.mpp", 0.002); decimals: 4; onEdited: function (v) { owner.setSource(card.key, "pixels.mpp", v, "Metres per pixel"); } }
                                }
                                RowLayout {
                                    L { text: "Flip" }
                                    S.SCheck { text: "X"; checked: panel.sget(card.key, "flipX", false); onToggled: owner.setSource(card.key, "flipX", checked, "Flip") }
                                    S.SCheck { text: "Y"; checked: panel.sget(card.key, "flipY", false); onToggled: owner.setSource(card.key, "flipY", checked, "Flip") }
                                    S.SCheck { text: "Z"; checked: panel.sget(card.key, "flipZ", false); onToggled: owner.setSource(card.key, "flipZ", checked, "Flip") }
                                }
                                RowLayout {
                                    L { text: "Position"; Layout.preferredWidth: 48 }
                                    SmallNum { path: "transform.pos"; idx: 0; value: panel.sget(card.key, "transform.pos", [0, 0, 0])[0]; onEdited: function (v) { var p = panel.sget(card.key, "transform.pos", [0, 0, 0]).slice(); p[0] = v; owner.setSource(card.key, "transform.pos", p, "Source position"); } }
                                    SmallNum { path: "transform.pos"; idx: 1; value: panel.sget(card.key, "transform.pos", [0, 0, 0])[1]; onEdited: function (v) { var p = panel.sget(card.key, "transform.pos", [0, 0, 0]).slice(); p[1] = v; owner.setSource(card.key, "transform.pos", p, "Source position"); } }
                                    SmallNum { path: "transform.pos"; idx: 2; value: panel.sget(card.key, "transform.pos", [0, 0, 0])[2]; onEdited: function (v) { var p = panel.sget(card.key, "transform.pos", [0, 0, 0]).slice(); p[2] = v; owner.setSource(card.key, "transform.pos", p, "Source position"); } }
                                }
                                RowLayout {
                                    L { text: "Rotation°"; Layout.preferredWidth: 48 }
                                    SmallNum { path: "transform.rot"; idx: 0; value: panel.sget(card.key, "transform.rot", [0, 0, 0])[0]; decimals: 1; onEdited: function (v) { var p = panel.sget(card.key, "transform.rot", [0, 0, 0]).slice(); p[0] = v; owner.setSource(card.key, "transform.rot", p, "Source rotation"); } }
                                    SmallNum { path: "transform.rot"; idx: 1; value: panel.sget(card.key, "transform.rot", [0, 0, 0])[1]; decimals: 1; onEdited: function (v) { var p = panel.sget(card.key, "transform.rot", [0, 0, 0]).slice(); p[1] = v; owner.setSource(card.key, "transform.rot", p, "Source rotation"); } }
                                    SmallNum { path: "transform.rot"; idx: 2; value: panel.sget(card.key, "transform.rot", [0, 0, 0])[2]; decimals: 1; onEdited: function (v) { var p = panel.sget(card.key, "transform.rot", [0, 0, 0]).slice(); p[2] = v; owner.setSource(card.key, "transform.rot", p, "Source rotation"); } }
                                }
                                RowLayout {
                                    L { text: "Scale"; Layout.preferredWidth: 48 }
                                    SmallNum { path: "transform.scale"; idx: 0; value: panel.sget(card.key, "transform.scale", [1, 1, 1])[0]; onEdited: function (v) { var p = panel.sget(card.key, "transform.scale", [1, 1, 1]).slice(); p[0] = v || 1; owner.setSource(card.key, "transform.scale", p, "Source scale"); } }
                                    SmallNum { path: "transform.scale"; idx: 1; value: panel.sget(card.key, "transform.scale", [1, 1, 1])[1]; onEdited: function (v) { var p = panel.sget(card.key, "transform.scale", [1, 1, 1]).slice(); p[1] = v || 1; owner.setSource(card.key, "transform.scale", p, "Source scale"); } }
                                    SmallNum { path: "transform.scale"; idx: 2; value: panel.sget(card.key, "transform.scale", [1, 1, 1])[2]; onEdited: function (v) { var p = panel.sget(card.key, "transform.scale", [1, 1, 1]).slice(); p[2] = v || 1; owner.setSource(card.key, "transform.scale", p, "Source scale"); } }
                                }
                                RowLayout {
                                    S.SCheck { text: "4-point floor homography"; checked: !!panel.sget(card.key, "homography", null); onToggled: owner.setSource(card.key, "homography", checked ? { src: [[0, 0], [1, 0], [1, 1], [0, 1]], dst: [[-2, 1.5], [2, 1.5], [2, -1.5], [-2, -1.5]] } : null, "Homography") }
                                }
                                GridLayout {
                                    visible: !!panel.sget(card.key, "homography", null)
                                    columns: 5; columnSpacing: 3; rowSpacing: 1
                                    L { text: "" } L { text: "in x"; color: palette.placeholderText } L { text: "in y"; color: palette.placeholderText } L { text: "→ X m"; color: palette.placeholderText } L { text: "Y m"; color: palette.placeholderText }
                                    Repeater { model: 4; delegate: L { required property int index; text: "P" + (index + 1); Layout.row: index + 1; Layout.column: 0 } }
                                    Repeater {
                                        model: 16
                                        delegate: SmallNum {
                                            required property int index
                                            property int pt: Math.floor(index / 4)
                                            property int col: index % 4
                                            Layout.row: pt + 1; Layout.column: col + 1
                                            implicitWidth: 44
                                            value: { var h = panel.sget(card.key, "homography", null); if (!h) return 0; var arr = col < 2 ? h.src : h.dst; return arr[pt][col % 2]; }
                                            decimals: 3
                                            onEdited: function (v) { var h = JSON.parse(JSON.stringify(panel.sget(card.key, "homography", null))); var arr = col < 2 ? h.src : h.dst; arr[pt][col % 2] = v; owner.setSource(card.key, "homography", h, "Homography"); }
                                        }
                                    }
                                }
                                RowLayout {
                                    L { text: "Ids" }
                                    S.SCombo { implicitWidth: 90; model: ["From data", "By index"]; property var keys: ["auto", "index"]; currentIndex: Math.max(0, keys.indexOf(panel.sget(card.key, "idMode", "auto"))); onActivated: function (i) { owner.setSource(card.key, "idMode", keys[i], "Id mode"); } }
                                    L { text: "Prefix" }
                                    TextField { implicitWidth: 40; implicitHeight: 22; topPadding: 2; bottomPadding: 2; font.pixelSize: 10; text: panel.sget(card.key, "idPrefix", ""); placeholderText: "s" + card.key; onEditingFinished: owner.setSource(card.key, "idPrefix", text, "Id prefix") }
                                    L { text: "Class" }
                                    TextField { Layout.fillWidth: true; implicitHeight: 22; topPadding: 2; bottomPadding: 2; font.pixelSize: 10; text: panel.sget(card.key, "cls", ""); placeholderText: "default class"; onEditingFinished: owner.setSource(card.key, "cls", text, "Source class") }
                                }
                                RowLayout {
                                    L { text: "Lost after" }
                                    SmallNum { path: "lostTimeout"; value: panel.sget(card.key, "lostTimeout", 0.5); onEdited: function (v) { owner.setSource(card.key, "lostTimeout", Math.max(0.02, v), "Lost timeout"); } }
                                    L { text: "s   Max jump" }
                                    SmallNum { path: "maxJump"; value: panel.sget(card.key, "maxJump", 0); onEdited: function (v) { owner.setSource(card.key, "maxJump", Math.max(0, v), "Max jump"); } }
                                    L { text: "m   Z" }
                                    SmallNum { path: "defaultZ"; value: panel.sget(card.key, "defaultZ", 0); onEdited: function (v) { owner.setSource(card.key, "defaultZ", v, "Default Z"); } }
                                }
                                RowLayout {
                                    S.SCheck { text: "1€ smoothing"; checked: panel.sget(card.key, "smoothing.enabled", false); onToggled: owner.setSource(card.key, "smoothing.enabled", checked, "Smoothing") }
                                    L { text: "cutoff" }
                                    SmallNum { path: "smoothing.minCutoff"; value: panel.sget(card.key, "smoothing.minCutoff", 1); onEdited: function (v) { owner.setSource(card.key, "smoothing.minCutoff", Math.max(0.01, v), "Smoothing"); } }
                                    L { text: "beta" }
                                    SmallNum { path: "smoothing.beta"; value: panel.sget(card.key, "smoothing.beta", 0.02); decimals: 3; onEdited: function (v) { owner.setSource(card.key, "smoothing.beta", Math.max(0, v), "Smoothing"); } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
