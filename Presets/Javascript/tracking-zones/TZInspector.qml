import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Model.js" as Model
import "UiUtil.js" as U

// Right panel: properties of the selected zone, or the global settings when nothing is selected.
Rectangle {
    id: insp
    property var owner
    color: palette.base
    border.color: palette.mid
    radius: 3

    property var zn: owner.selectedZone
    property int v: owner.docVersion
    property var st: { var zs = owner.zoneStates; return zn && zs ? (zs[zn.id] || null) : null; }

    function zp(path, def) { v; if (!zn) return def; var r = U.deepGet(zn, path); return r === undefined || r === null ? def : r; }
    function setZ(path, value, label) { if (!zn) return; if (owner.selection.length > 1) owner.setSelectedProp(path, value, label); else owner.setZoneProp(zn.id, path, value, label); }
    function sp(path, def) { v; var r = U.deepGet(owner.doc.settings, path); return r === undefined || r === null ? def : r; }

    // ---- reusable field components ----
    component SectionLabel: Label { Layout.fillWidth: true; Layout.topMargin: 6; font.bold: true; font.pixelSize: 11; color: palette.light; text: "" }
    component FieldLabel: Label { font.pixelSize: 11; color: palette.windowText; Layout.preferredWidth: 92; elide: Text.ElideRight }
    component NumField: RowLayout {
        property string label: ""
        property real value: 0
        property real step: 0.1
        property int decimals: 2
        property string suffix: ""
        property string tip: ""
        property string livePath: ""      // zone property updated live while dragging (committed on release)
        property string path: ""          // zone property (double-click resets to the model default)
        property string spath: ""         // settings property (same)
        property int idx: -1              // component index when the property is a vector
        function defaultValue() {
            var dv;
            if (path.length) dv = U.deepGet(Model.normalizeZone({ shape: { type: insp.zp("shape.type", "rect") } }, 0), path);
            else if (spath.length) dv = U.deepGet(Model.defaultSettings(), spath);
            if (dv === undefined || dv === null) return undefined;
            if (idx >= 0) return dv[idx];
            return typeof dv === "number" ? dv : undefined;
        }
        signal edited(real v)
        Layout.fillWidth: true; spacing: 4
        FieldLabel { text: parent.label; ToolTip.visible: tip.length && hov.hovered; ToolTip.text: tip; HoverHandler { id: hov } }
        TextField {
            id: tf; Layout.fillWidth: true; implicitHeight: 22; font.pixelSize: 11; topPadding: 2; bottomPadding: 2
            property var nf: parent
            text: U.fmt(parent.value, parent.decimals)
            selectByMouse: true
            validator: DoubleValidator { notation: DoubleValidator.StandardNotation }
            onEditingFinished: { var nv = parseFloat(text); if (!isNaN(nv) && Math.abs(nv - parent.value) > 1e-9) parent.edited(nv); rebind(); }
            function rebind() { text = Qt.binding(function () { return U.fmt(tf.nf.value, tf.nf.decimals); }); }
            Keys.onUpPressed: { parent.edited(parent.value + parent.step); }
            Keys.onDownPressed: { parent.edited(parent.value - parent.step); }
            WheelHandler { onWheel: function (ev) { if (tf.activeFocus) parent.parent.edited(parent.parent.value + (ev.angleDelta.y > 0 ? 1 : -1) * parent.parent.step); } }
            // drag left/right to change the value (click to type)
            TZNumDrag {
                field: tf; value: tf.nf.value; step: tf.nf.step
                onDragged: function (v) { tf.text = U.fmt(v, tf.nf.decimals); if (tf.nf.livePath.length && insp.zn) owner.setZonePropLive(insp.zn.id, tf.nf.livePath, v); }
                onCommitted: function (v) { tf.nf.edited(v); tf.rebind(); }
                onReset: { var dv = tf.nf.defaultValue(); if (dv !== undefined) { tf.nf.edited(dv); tf.rebind(); } }
            }
        }
        Label { text: parent.suffix; font.pixelSize: 10; color: palette.placeholderText; visible: parent.suffix.length > 0 }
    }
    component TextFieldRow: RowLayout {
        property string label: ""
        property string value: ""
        property string placeholder: ""
        signal edited(string v)
        Layout.fillWidth: true; spacing: 4
        FieldLabel { text: parent.label }
        TextField { Layout.fillWidth: true; implicitHeight: 22; font.pixelSize: 11; topPadding: 2; bottomPadding: 2; text: parent.value; placeholderText: parent.placeholder; selectByMouse: true; onEditingFinished: if (text !== parent.value) parent.edited(text) }
    }
    component ComboRow: RowLayout {
        property string label: ""
        property var options: []
        property var labels: []
        property string value: ""
        signal edited(string v)
        Layout.fillWidth: true; spacing: 4
        FieldLabel { text: parent.label }
        TZCombo {
            Layout.fillWidth: true; font.pixelSize: 11
            model: parent.labels.length ? parent.labels : parent.options
            currentIndex: Math.max(0, parent.options.indexOf(parent.value))
            onActivated: function (i) { parent.edited(parent.options[i]); }
        }
    }
    component CheckRow: RowLayout {
        property string label: ""
        property bool value: false
        signal edited(bool v)
        Layout.fillWidth: true; spacing: 4
        TZCheck { text: parent.label; checked: parent.value; font.pixelSize: 11; onToggled: parent.edited(checked) }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 6
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: availableWidth

        ColumnLayout {
            width: insp.width - 16
            spacing: 3

            // ====================== ZONE ======================
            ColumnLayout {
                visible: insp.zn !== null
                Layout.fillWidth: true; spacing: 3
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: owner.selection.length > 1 ? owner.selection.length + " zones selected" : "Zone"; font.bold: true; font.pixelSize: 12; color: palette.windowText; Layout.fillWidth: true }
                    Label { visible: insp.st !== null; text: insp.st ? (insp.st.occupied ? "● occupied" : "○ empty") : ""; font.pixelSize: 11; color: insp.st && insp.st.occupied ? palette.light : palette.placeholderText }
                }
                TextFieldRow { label: "Name"; value: insp.zp("name", ""); onEdited: function (v) { insp.setZ("name", v, "Rename zone"); } }
                RowLayout {
                    Layout.fillWidth: true
                    CheckRow { label: "Enabled"; value: insp.zp("enabled", true); onEdited: function (v) { insp.setZ("enabled", v, "Toggle enabled"); } }
                    CheckRow { label: "Visible"; value: insp.zp("visible", true); onEdited: function (v) { insp.setZ("visible", v, "Toggle visible"); } }
                    CheckRow { label: "Locked"; value: insp.zp("locked", false); onEdited: function (v) { insp.setZ("locked", v, "Toggle lock"); } }
                }
                ComboRow { label: "Role"; options: ["event", "exclude", "include"]; labels: ["Event zone", "Exclude (mask)", "Include (only inside)"]; value: insp.zp("role", "event"); onEdited: function (v) { insp.setZ("role", v, "Zone role"); } }
                TextFieldRow { label: "Set"; value: insp.zp("set", ""); placeholder: "(always active)"; onEdited: function (v) { insp.setZ("set", v, "Zone set"); } }
                TextFieldRow { label: "Group"; value: insp.zp("group", ""); onEdited: function (v) { insp.setZ("group", v, "Zone group"); } }
                TextFieldRow { label: "Tags"; value: (insp.zp("tags", []) || []).join(","); onEdited: function (v) { insp.setZ("tags", v.split(",").map(function (s) { return s.trim(); }).filter(function (s) { return s.length; }), "Zone tags"); } }
                ComboRow { label: "Frame"; options: ["world", "entity", "zone", "source"]; labels: ["World", "Attached to entity", "Relative to zone", "Relative to source"]; value: insp.zp("frame", "world"); onEdited: function (v) { insp.setZ("frame", v, "Zone frame"); } }
                TextFieldRow { visible: insp.zp("frame", "world") !== "world"; label: insp.zp("frame", "world") === "entity" ? "Entity id" : (insp.zp("frame", "world") === "zone" ? "Zone id/name" : "Source index"); value: insp.zp("frameRef", ""); onEdited: function (v) { if (insp.zp("frame", "world") === "zone") { var zz = owner.doc.zones.filter(function (q) { return q.name === v; })[0]; if (zz) v = zz.id; } insp.setZ("frameRef", v, "Frame reference"); } }

                SectionLabel { text: "Transform (m, °)" }
                NumField { label: "X"; livePath: "pos.0"; path: "pos"; idx: 0; value: insp.zp("pos", [0, 0, 0])[0]; onEdited: function (v) { var p = insp.zn.pos.slice(); p[0] = v; insp.setZ("pos", p, "Move zone"); } }
                NumField { label: "Y"; livePath: "pos.1"; path: "pos"; idx: 1; value: insp.zp("pos", [0, 0, 0])[1]; onEdited: function (v) { var p = insp.zn.pos.slice(); p[1] = v; insp.setZ("pos", p, "Move zone"); } }
                NumField { label: "Z"; livePath: "pos.2"; path: "pos"; idx: 2; value: insp.zp("pos", [0, 0, 0])[2]; onEdited: function (v) { var p = insp.zn.pos.slice(); p[2] = v; insp.setZ("pos", p, "Move zone"); } }
                NumField { label: "Rotation Z"; livePath: "rot.2"; path: "rot"; idx: 2; value: insp.zp("rot", [0, 0, 0])[2]; step: 5; decimals: 1; suffix: "°"; onEdited: function (v) { var r = insp.zn.rot.slice(); r[2] = v; insp.setZ("rot", r, "Rotate zone"); } }
                NumField { visible: Model.is3D(insp.zp("shape", { type: "rect" })); label: "Rotation X"; livePath: "rot.0"; path: "rot"; idx: 0; value: insp.zp("rot", [0, 0, 0])[0]; step: 5; decimals: 1; suffix: "°"; onEdited: function (v) { var r = insp.zn.rot.slice(); r[0] = v; insp.setZ("rot", r, "Rotate zone"); } }
                NumField { visible: Model.is3D(insp.zp("shape", { type: "rect" })); label: "Rotation Y"; livePath: "rot.1"; path: "rot"; idx: 1; value: insp.zp("rot", [0, 0, 0])[1]; step: 5; decimals: 1; suffix: "°"; onEdited: function (v) { var r = insp.zn.rot.slice(); r[1] = v; insp.setZ("rot", r, "Rotate zone"); } }

                SectionLabel { text: "Shape" }
                ComboRow { label: "Type"; options: ["rect", "circle", "polygon", "line", "path", "box", "sphere", "cylinder"]; labels: ["Rectangle", "Circle / ellipse", "Polygon", "Line (tripwire)", "Path", "Box", "Sphere", "Cylinder"]; value: insp.zp("shape.type", "rect"); onEdited: function (v) { insp.setZ("shape.type", v, "Zone type"); } }
                // rect / box
                NumField { visible: ["rect", "box"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Width"; livePath: "shape.w"; path: "shape.w"; value: insp.zp("shape.w", 1); suffix: "m"; onEdited: function (v) { insp.setZ("shape.w", Math.max(0.01, v), "Resize zone"); } }
                NumField { visible: ["rect", "box"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Height (Y)"; livePath: "shape.h"; path: "shape.h"; value: insp.zp("shape.h", 1); suffix: "m"; onEdited: function (v) { insp.setZ("shape.h", Math.max(0.01, v), "Resize zone"); } }
                NumField { visible: ["box", "cylinder"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Depth (Z)"; livePath: "shape.d"; path: "shape.d"; value: insp.zp("shape.d", 1); suffix: "m"; onEdited: function (v) { insp.setZ("shape.d", Math.max(0.01, v), "Resize zone"); } }
                // circle / sphere / cylinder
                NumField { visible: ["circle", "sphere", "cylinder"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Radius"; livePath: "shape.r"; path: "shape.r"; value: insp.zp("shape.r", 1); suffix: "m"; onEdited: function (v) { insp.setZ("shape.r", Math.max(0.01, v), "Resize zone"); } }
                NumField { visible: insp.zp("shape.type", "") === "circle"; label: "Radius X (ellipse)"; livePath: "shape.rx"; path: "shape.rx"; value: insp.zp("shape.rx", 0); suffix: "m"; tip: "0 = use Radius (circle)"; onEdited: function (v) { insp.setZ("shape.rx", Math.max(0, v), "Resize zone"); } }
                NumField { visible: insp.zp("shape.type", "") === "circle"; label: "Radius Y (ellipse)"; livePath: "shape.ry"; path: "shape.ry"; value: insp.zp("shape.ry", 0); suffix: "m"; onEdited: function (v) { insp.setZ("shape.ry", Math.max(0, v), "Resize zone"); } }
                // polygon / path / line
                RowLayout { visible: ["polygon", "path", "line", "prism"].indexOf(insp.zp("shape.type", "")) >= 0; Layout.fillWidth: true; FieldLabel { text: "Points" } Label { text: (insp.zp("shape.points", []) || []).length + "  (drag handles, click midpoints to insert, right-click to remove)"; font.pixelSize: 10; color: palette.placeholderText; wrapMode: Text.WordWrap; Layout.fillWidth: true } }
                NumField { visible: ["path", "line"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Width"; path: "shape.width"; value: insp.zp("shape.width", 1); suffix: "m"; tip: "Path: band width counted as inside. Line: display width."; onEdited: function (v) { insp.setZ("shape.width", Math.max(0.01, v), "Zone width"); } }
                ComboRow { visible: insp.zp("shape.type", "") === "line"; label: "Direction"; options: ["both", "a_to_b", "b_to_a"]; labels: ["Both ways", "A→B (in) only", "B→A (out) only"]; value: insp.zp("shape.direction", "both"); onEdited: function (v) { insp.setZ("shape.direction", v, "Line direction"); } }
                CheckRow { visible: insp.zp("shape.type", "") === "line"; label: "Extended (infinite line)"; value: insp.zp("shape.extended", false); onEdited: function (v) { insp.setZ("shape.extended", v, "Line extent"); } }
                NumField { visible: insp.zp("shape.type", "") === "line"; label: "Confirm frames"; path: "line.confirmFrames"; value: insp.zp("line.confirmFrames", 2); step: 1; decimals: 0; tip: "Frames on the other side before a crossing counts (anti-jitter)"; onEdited: function (v) { insp.setZ("line.confirmFrames", Math.max(1, Math.round(v)), "Line confirm"); } }
                CheckRow { visible: insp.zp("shape.type", "") === "line"; label: "Count each entity once"; value: insp.zp("line.countOnce", false); onEdited: function (v) { insp.setZ("line.countOnce", v, "Count once"); } }
                // z band for 2D shapes
                CheckRow { visible: ["rect", "circle", "polygon", "path", "line", "prism"].indexOf(insp.zp("shape.type", "")) >= 0; label: "Limit height (Z band)"; value: insp.zp("shape.useZ", false); onEdited: function (v) { insp.setZ("shape.useZ", v, "Z band"); } }
                NumField { visible: insp.zp("shape.useZ", false) && !["box", "sphere", "cylinder"].includes(insp.zp("shape.type", "")); label: "Z min"; livePath: "shape.zmin"; path: "shape.zmin"; value: insp.zp("shape.zmin", 0); suffix: "m"; onEdited: function (v) { insp.setZ("shape.zmin", v, "Z band"); } }
                NumField { visible: insp.zp("shape.useZ", false) && !["box", "sphere", "cylinder"].includes(insp.zp("shape.type", "")); label: "Z max"; livePath: "shape.zmax"; path: "shape.zmax"; value: insp.zp("shape.zmax", 2); suffix: "m"; onEdited: function (v) { insp.setZ("shape.zmax", v, "Z band"); } }

                SectionLabel { text: "Detection" }
                ComboRow { label: "Anchor"; options: ["center", "feet", "head", "hands", "any", "all"]; labels: ["Centre / position", "Feet (ankles or ground)", "Head (top)", "Hands (either)", "Any keypoint", "All keypoints"]; value: insp.zp("anchor", "center"); onEdited: function (v) { insp.setZ("anchor", v, "Zone anchor"); } }
                ComboRow { label: "Containment"; options: ["point", "radius", "bbox"]; labels: ["Point inside", "Radius overlap", "Bounding box overlap"]; value: insp.zp("containment", "point"); onEdited: function (v) { insp.setZ("containment", v, "Containment"); } }
                NumField { visible: insp.zp("containment", "point") === "radius"; label: "Entity radius"; path: "radius"; value: insp.zp("radius", 0.25); suffix: "m"; onEdited: function (v) { insp.setZ("radius", Math.max(0, v), "Entity radius"); } }
                ComboRow { label: "Selection"; options: ["all", "nearest", "first_in", "last_in", "max_n"]; labels: ["All inside", "Nearest to centre", "First in", "Last in", "Oldest N"]; value: insp.zp("selection", "all"); onEdited: function (v) { insp.setZ("selection", v, "Selection policy"); } }
                NumField { visible: insp.zp("selection", "all") !== "all"; label: "Max N"; path: "maxN"; value: insp.zp("maxN", 1); step: 1; decimals: 0; onEdited: function (v) { insp.setZ("maxN", Math.max(1, Math.round(v)), "Max N"); } }

                SectionLabel { text: "Filters" }
                TextFieldRow { label: "Classes"; value: insp.zp("filters.cls", ""); placeholder: "any (e.g. person,0)"; onEdited: function (v) { insp.setZ("filters.cls", v, "Class filter"); } }
                TextFieldRow { label: "Sources"; value: (insp.zp("filters.sources", []) || []).join(","); placeholder: "any (e.g. 0,2)"; onEdited: function (v) { insp.setZ("filters.sources", v.split(",").map(function (s) { return parseInt(s.trim()); }).filter(function (n) { return !isNaN(n); }), "Source filter"); } }
                NumField { label: "Min confidence"; path: "filters.minConf"; value: insp.zp("filters.minConf", 0); step: 0.05; onEdited: function (v) { insp.setZ("filters.minConf", v, "Min confidence"); } }
                NumField { label: "Min age"; path: "filters.minAge"; value: insp.zp("filters.minAge", 0); suffix: "s"; tip: "Ignore entities younger than this (ghost tracks)"; onEdited: function (v) { insp.setZ("filters.minAge", v, "Min age"); } }
                NumField { label: "Height min"; path: "filters.heightMin"; value: insp.zp("filters.heightMin", 0); suffix: "m"; tip: "0 = no limit"; onEdited: function (v) { insp.setZ("filters.heightMin", v, "Height filter"); } }
                NumField { label: "Height max"; path: "filters.heightMax"; value: insp.zp("filters.heightMax", 0); suffix: "m"; onEdited: function (v) { insp.setZ("filters.heightMax", v, "Height filter"); } }
                NumField { label: "Speed min"; path: "filters.speedMin"; value: insp.zp("filters.speedMin", 0); suffix: "m/s"; onEdited: function (v) { insp.setZ("filters.speedMin", v, "Speed filter"); } }
                NumField { label: "Speed max"; path: "filters.speedMax"; value: insp.zp("filters.speedMax", 0); suffix: "m/s"; onEdited: function (v) { insp.setZ("filters.speedMax", v, "Speed filter"); } }
                NumField { label: "Max count"; path: "filters.maxCount"; value: insp.zp("filters.maxCount", 0); step: 1; decimals: 0; tip: "Limit reported ids (0 = unlimited)"; onEdited: function (v) { insp.setZ("filters.maxCount", Math.max(0, Math.round(v)), "Max count"); } }

                SectionLabel { text: "Stability" }
                NumField { label: "Exit margin"; path: "hysteresis.margin"; value: insp.zp("hysteresis.margin", 0.05); suffix: "m"; step: 0.05; tip: "Spatial hysteresis: must go this far outside before exiting"; onEdited: function (v) { insp.setZ("hysteresis.margin", Math.max(0, v), "Hysteresis"); } }
                NumField { label: "Enter delay"; path: "hysteresis.enterMs"; value: insp.zp("hysteresis.enterMs", 0); suffix: "ms"; step: 50; decimals: 0; onEdited: function (v) { insp.setZ("hysteresis.enterMs", Math.max(0, v), "Enter delay"); } }
                NumField { label: "Exit delay"; path: "hysteresis.exitMs"; value: insp.zp("hysteresis.exitMs", 0); suffix: "ms"; step: 50; decimals: 0; onEdited: function (v) { insp.setZ("hysteresis.exitMs", Math.max(0, v), "Exit delay"); } }
                NumField { label: "Enter frames"; path: "hysteresis.enterFrames"; value: insp.zp("hysteresis.enterFrames", 1); step: 1; decimals: 0; onEdited: function (v) { insp.setZ("hysteresis.enterFrames", Math.max(1, Math.round(v)), "Enter frames"); } }
                NumField { label: "Exit frames"; path: "hysteresis.exitFrames"; value: insp.zp("hysteresis.exitFrames", 1); step: 1; decimals: 0; onEdited: function (v) { insp.setZ("hysteresis.exitFrames", Math.max(1, Math.round(v)), "Exit frames"); } }
                NumField { label: "Hold"; path: "hysteresis.holdMs"; value: insp.zp("hysteresis.holdMs", 0); suffix: "ms"; step: 50; decimals: 0; tip: "Stay 'inside' this long after leaving"; onEdited: function (v) { insp.setZ("hysteresis.holdMs", Math.max(0, v), "Hold"); } }
                NumField { label: "Cooldown"; path: "hysteresis.cooldownMs"; value: insp.zp("hysteresis.cooldownMs", 0); suffix: "ms"; step: 100; decimals: 0; tip: "Suppress re-enter events this long after an exit"; onEdited: function (v) { insp.setZ("hysteresis.cooldownMs", Math.max(0, v), "Cooldown"); } }

                SectionLabel { text: "Dwell, occupancy, soft edge" }
                NumField { label: "Loiter after"; path: "dwell.loiterS"; value: insp.zp("dwell.loiterS", 0); suffix: "s"; tip: "Emit a 'dwell' event when an entity stays this long (0 = off)"; onEdited: function (v) { insp.setZ("dwell.loiterS", Math.max(0, v), "Loiter time"); } }
                NumField { label: "Stationary speed"; path: "stationary.speed"; value: insp.zp("stationary.speed", 0.1); suffix: "m/s"; onEdited: function (v) { insp.setZ("stationary.speed", Math.max(0, v), "Stationary"); } }
                NumField { label: "Stationary after"; path: "stationary.timeS"; value: insp.zp("stationary.timeS", 2); suffix: "s"; tip: "0 = off"; onEdited: function (v) { insp.setZ("stationary.timeS", Math.max(0, v), "Stationary"); } }
                NumField { label: "Occupied at ≥"; path: "occupancy.setThreshold"; value: insp.zp("occupancy.setThreshold", 1); step: 1; decimals: 0; onEdited: function (v) { insp.setZ("occupancy.setThreshold", Math.max(1, Math.round(v)), "Occupancy threshold"); } }
                NumField { label: "Empty at ≤"; path: "occupancy.clearThreshold"; value: insp.zp("occupancy.clearThreshold", 0); step: 1; decimals: 0; onEdited: function (v) { insp.setZ("occupancy.clearThreshold", Math.max(0, Math.round(v)), "Occupancy threshold"); } }
                NumField { label: "Capacity"; path: "occupancy.capacity"; value: insp.zp("occupancy.capacity", 0); step: 1; decimals: 0; tip: "0 = off; emits 'capacity' events"; onEdited: function (v) { insp.setZ("occupancy.capacity", Math.max(0, Math.round(v)), "Capacity"); } }
                CheckRow { label: "Soft edge (weight 0..1 outside)"; value: insp.zp("soft.enabled", false); onEdited: function (v) { insp.setZ("soft.enabled", v, "Soft edge"); } }
                NumField { visible: insp.zp("soft.enabled", false); label: "Falloff"; path: "soft.falloff"; value: insp.zp("soft.falloff", 0.5); suffix: "m"; onEdited: function (v) { insp.setZ("soft.falloff", Math.max(0.01, v), "Falloff"); } }

                SectionLabel { text: "Outputs" }
                CheckRow { label: "Per-entity data (u,v,w, dist, dwell…)"; value: insp.zp("outputs.perId", true); onEdited: function (v) { insp.setZ("outputs.perId", v, "Outputs"); } }
                CheckRow { label: "Include in Tree output"; value: insp.zp("outputs.tree", true); onEdited: function (v) { insp.setZ("outputs.tree", v, "Outputs"); } }

                SectionLabel { text: "Live"; visible: insp.st !== null }
                Label {
                    visible: insp.st !== null; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pixelSize: 11; color: palette.text
                    text: insp.st ? ("count " + insp.st.count + "   ids [" + (insp.st.ids || []).join(", ") + "]\ndwell now " + U.fmtTime(insp.st.dwell_now || 0) + "   visits " + insp.st.visits + "   unique " + insp.st.unique + "\ncrossings in " + insp.st.crossings_in + " / out " + insp.st.crossings_out + "   idle " + U.fmtTime(insp.st.idle || 0) + (insp.st.weight !== undefined ? "\nweight " + U.fmt(insp.st.weight) : "")) : ""
                }
                Button { visible: insp.st !== null; text: "Reset counters"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.executionSend({ type: "resetCounters", zone: insp.zn.id }) }
            }

            // ====================== SETTINGS ======================
            ColumnLayout {
                visible: insp.zn === null
                Layout.fillWidth: true; spacing: 3
                Label { text: "Settings"; font.bold: true; font.pixelSize: 12; color: palette.windowText }
                Label { text: "Select a zone to edit it. Draw with the tools above, or use Generate."; font.pixelSize: 10; color: palette.placeholderText; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                SectionLabel { text: "Engine" }
                TextFieldRow { label: "Active set"; value: insp.sp("activeSet", ""); placeholder: "(all)"; onEdited: function (v) { owner.setSettings("activeSet", v, "Active set"); } }
                NumField { label: "Lost timeout"; spath: "lostTimeout"; value: insp.sp("lostTimeout", 0.5); suffix: "s"; tip: "Default time without data before an entity is dropped (per source overrides in Sources)"; onEdited: function (v) { owner.setSettings("lostTimeout", Math.max(0.02, v), "Lost timeout"); } }
                NumField { label: "UI rate"; spath: "uiRate"; value: insp.sp("uiRate", 30); suffix: "Hz"; step: 5; decimals: 0; onEdited: function (v) { owner.setSettings("uiRate", Math.max(1, Math.min(60, Math.round(v))), "UI rate"); } }
                SectionLabel { text: "Event log limits" }
                NumField { label: "Max rows"; spath: "monitor.maxEvents"; value: insp.sp("monitor.maxEvents", 400); step: 100; decimals: 0; tip: "Rows kept in the Monitor event log"; onEdited: function (v) { owner.setSettings("monitor.maxEvents", Math.max(10, Math.round(v)), "Event log"); } }
                NumField { label: "Max rows/s"; spath: "monitor.maxEventsPerSec"; value: insp.sp("monitor.maxEventsPerSec", 100); step: 10; decimals: 0; tip: "Rows added per second; extra events are counted but not listed"; onEdited: function (v) { owner.setSettings("monitor.maxEventsPerSec", Math.max(1, Math.round(v)), "Event log"); } }
                SectionLabel { text: "World transform (moves every source)" }
                NumField { label: "Offset X"; spath: "worldTransform.pos"; idx: 0; value: insp.sp("worldTransform.pos", [0, 0, 0])[0]; suffix: "m"; onEdited: function (v) { var p = insp.sp("worldTransform.pos", [0, 0, 0]).slice(); p[0] = v; owner.setSettings("worldTransform.pos", p, "World offset"); } }
                NumField { label: "Offset Y"; spath: "worldTransform.pos"; idx: 1; value: insp.sp("worldTransform.pos", [0, 0, 0])[1]; suffix: "m"; onEdited: function (v) { var p = insp.sp("worldTransform.pos", [0, 0, 0]).slice(); p[1] = v; owner.setSettings("worldTransform.pos", p, "World offset"); } }
                NumField { label: "Offset Z"; spath: "worldTransform.pos"; idx: 2; value: insp.sp("worldTransform.pos", [0, 0, 0])[2]; suffix: "m"; onEdited: function (v) { var p = insp.sp("worldTransform.pos", [0, 0, 0]).slice(); p[2] = v; owner.setSettings("worldTransform.pos", p, "World offset"); } }
                NumField { label: "Rotation Z"; spath: "worldTransform.rot"; idx: 2; value: insp.sp("worldTransform.rot", [0, 0, 0])[2]; suffix: "°"; step: 5; decimals: 1; onEdited: function (v) { var r = insp.sp("worldTransform.rot", [0, 0, 0]).slice(); r[2] = v; owner.setSettings("worldTransform.rot", r, "World rotation"); } }
                SectionLabel { text: "Proximity (entity ↔ entity)" }
                CheckRow { label: "Emit proximity events + Proximity output"; value: insp.sp("proximity.enabled", false); onEdited: function (v) { owner.setSettings("proximity.enabled", v, "Proximity"); } }
                NumField { visible: insp.sp("proximity.enabled", false); label: "Distance"; spath: "proximity.distance"; value: insp.sp("proximity.distance", 1); suffix: "m"; onEdited: function (v) { owner.setSettings("proximity.distance", Math.max(0.01, v), "Proximity"); } }
                CheckRow { visible: insp.sp("proximity.enabled", false); label: "Only across different sources"; value: insp.sp("proximity.crossSourcesOnly", false); onEdited: function (v) { owner.setSettings("proximity.crossSourcesOnly", v, "Proximity"); } }
                SectionLabel { text: "Heatmap" }
                CheckRow { label: "Enable heatmap output"; value: insp.sp("heatmap.enabled", false); onEdited: function (v) { owner.setSettings("heatmap.enabled", v, "Heatmap"); } }
                NumField { label: "Centre X"; spath: "heatmap.x"; value: insp.sp("heatmap.x", 0); suffix: "m"; onEdited: function (v) { owner.setSettings("heatmap.x", v, "Heatmap"); } }
                NumField { label: "Centre Y"; spath: "heatmap.y"; value: insp.sp("heatmap.y", 0); suffix: "m"; onEdited: function (v) { owner.setSettings("heatmap.y", v, "Heatmap"); } }
                NumField { label: "Width"; spath: "heatmap.w"; value: insp.sp("heatmap.w", 8); suffix: "m"; onEdited: function (v) { owner.setSettings("heatmap.w", Math.max(0.1, v), "Heatmap"); } }
                NumField { label: "Height"; spath: "heatmap.h"; value: insp.sp("heatmap.h", 6); suffix: "m"; onEdited: function (v) { owner.setSettings("heatmap.h", Math.max(0.1, v), "Heatmap"); } }
                NumField { label: "Columns"; spath: "heatmap.cols"; value: insp.sp("heatmap.cols", 16); step: 1; decimals: 0; onEdited: function (v) { owner.setSettings("heatmap.cols", Math.max(1, Math.round(v)), "Heatmap"); } }
                NumField { label: "Rows"; spath: "heatmap.rows"; value: insp.sp("heatmap.rows", 12); step: 1; decimals: 0; onEdited: function (v) { owner.setSettings("heatmap.rows", Math.max(1, Math.round(v)), "Heatmap"); } }
                NumField { label: "Decay"; spath: "heatmap.decay"; value: insp.sp("heatmap.decay", 0.2); suffix: "/s"; step: 0.05; onEdited: function (v) { owner.setSettings("heatmap.decay", Math.max(0, v), "Heatmap"); } }
                SectionLabel { text: "Floor plan backdrop" }
                RowLayout { Layout.fillWidth: true; FieldLabel { text: "Image" } Label { Layout.fillWidth: true; elide: Text.ElideMiddle; font.pixelSize: 10; text: insp.sp("backdrop.path", "") || "(none)"; color: palette.text } Button { text: "…"; implicitWidth: 26; implicitHeight: 22; onClicked: bdDlg.open() } Button { text: "×"; implicitWidth: 22; implicitHeight: 22; onClicked: owner.setSettings("backdrop.path", "", "Backdrop") } }
                NumField { label: "Centre X"; spath: "backdrop.x"; value: insp.sp("backdrop.x", 0); suffix: "m"; onEdited: function (v) { owner.setSettings("backdrop.x", v, "Backdrop"); } }
                NumField { label: "Centre Y"; spath: "backdrop.y"; value: insp.sp("backdrop.y", 0); suffix: "m"; onEdited: function (v) { owner.setSettings("backdrop.y", v, "Backdrop"); } }
                NumField { label: "Width"; spath: "backdrop.w"; value: insp.sp("backdrop.w", 10); suffix: "m"; tip: "Measure two points on the plan and set the real-world width"; onEdited: function (v) { owner.setSettings("backdrop.w", Math.max(0.1, v), "Backdrop"); } }
                NumField { label: "Height"; spath: "backdrop.h"; value: insp.sp("backdrop.h", 7.5); suffix: "m"; onEdited: function (v) { owner.setSettings("backdrop.h", Math.max(0.1, v), "Backdrop"); } }
                NumField { label: "Opacity"; spath: "backdrop.opacity"; value: insp.sp("backdrop.opacity", 0.5); step: 0.1; onEdited: function (v) { owner.setSettings("backdrop.opacity", Math.max(0, Math.min(1, v)), "Backdrop"); } }
                NumField { label: "Rotation"; spath: "backdrop.rotation"; value: insp.sp("backdrop.rotation", 0); suffix: "°"; step: 5; decimals: 1; onEdited: function (v) { owner.setSettings("backdrop.rotation", v, "Backdrop"); } }
                FileDialog { id: bdDlg; fileMode: FileDialog.OpenFile; nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.svg)"]; onAccepted: { var p = Util.urlToLocalFile(selectedFile); var sz = Util.imageSize(p); owner.setSettings("backdrop.path", p, "Backdrop"); if (sz && sz.width > 0) owner.setSettings("backdrop.h", insp.sp("backdrop.w", 10) * sz.height / sz.width, "Backdrop"); } }
            }
            Item { height: 20 }
        }
    }
}
