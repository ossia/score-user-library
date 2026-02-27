import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "GeomUtils.js" as Geom
import "SnapUtils.js" as Snap
import "ShapeData.js" as ShapeData

Score.ScriptUI {
    id: root
    anchors.fill: parent

    property var rects: []
    property int stateVersion: 0
    property int selectedRect: -1
    property bool isDragging: false
    property int dragCorner: -1
    property real renderWidth: 0
    property real renderHeight: 0
    property var snapLinesX: []
    property var snapLinesY: []
    property bool snappingEnabled: true
    readonly property real snapThresholdPx: snappingEnabled ? 10 : 0
    property bool drawingMode: false
    property var drawingPoints: []
    property int drawingVersion: 0

    // ---- State management ----

    loadState: function (state) {
        if (state && state.mapperState) {
            try {
                var s = typeof state.mapperState === "string" ? JSON.parse(state.mapperState) : state.mapperState;
                root.rects = s || [];
            } catch (e) {
                root.rects = [];
            }
        } else {
            root.rects = [];
        }
        root.stateVersion++;
    }

    stateUpdated: function (k, v) {
        if (k === "mapperState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.rects = Array.isArray(s) ? s : [];
            } catch (e) {
                return;
            }
            root.stateVersion++;
        }
    }

    executionEvent: function (message) {
        if (message && message.type === "renderSize") {
            root.renderWidth = message.width;
            root.renderHeight = message.height;
        }
    }

    // ---- Actions ----

    function saveState(actionName) {
        root.beginUpdateState(actionName || "Edit mapping");
        root.updateState("mapperState", JSON.stringify(root.rects));
        root.endUpdateState();
    }

    function sendLiveUpdate() {
        root.executionSend({ type: "updateRects", rects: root.rects });
    }

    function addShape(type) {
        var shape = ShapeData.createShape(type || "quad", rects.length);
        shape.name = shape.name + " " + (rects.length + 1);
        rects.push(shape);
        selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Add shape");
        sendLiveUpdate();
    }

    function deleteRect(idx) {
        if (idx < 0 || idx >= rects.length) return;
        rects.splice(idx, 1);
        if (selectedRect >= rects.length) selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Delete shape");
        sendLiveUpdate();
    }

    function duplicateRect(idx) {
        if (idx < 0 || idx >= rects.length) return;
        var src = rects[idx];
        var dup = ShapeData.cloneShape(src);
        dup.id = "shape-" + Date.now();
        dup.name = Geom.incrementName(src.name);
        for (var i = 0; i < dup.vertices.length; i++) {
            dup.vertices[i][0] += 0.05;
            dup.vertices[i][1] += 0.05;
        }
        if (dup.edges) {
            for (var i = 0; i < dup.edges.length; i++) {
                var e = dup.edges[i];
                if (e && e.cp1 && e.cp2) {
                    e.cp1[0] += 0.05; e.cp1[1] += 0.05;
                    e.cp2[0] += 0.05; e.cp2[1] += 0.05;
                }
            }
        }
        rects.push(dup);
        selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Duplicate shape");
        sendLiveUpdate();
    }

    function moveRectUp(idx) {
        if (idx >= rects.length - 1) return;
        var tmp = rects[idx];
        rects[idx] = rects[idx + 1];
        rects[idx + 1] = tmp;
        selectedRect = idx + 1;
        stateVersion++;
        saveState("Reorder layers");
        sendLiveUpdate();
    }

    function moveRectDown(idx) {
        if (idx <= 0) return;
        var tmp = rects[idx];
        rects[idx] = rects[idx - 1];
        rects[idx - 1] = tmp;
        selectedRect = idx - 1;
        stateVersion++;
        saveState("Reorder layers");
        sendLiveUpdate();
    }

    // ---- Vertex editing ----

    function insertVertexOnEdge(nx, ny) {
        if (selectedRect < 0 || selectedRect >= rects.length) return;
        if (isShapeLocked(selectedRect)) return;
        var shape = rects[selectedRect];
        var nearest = Geom.nearestEdge(nx, ny, shape.vertices);
        if (nearest.edgeIndex < 0) return;
        var ei = nearest.edgeIndex;
        var t = nearest.t;
        var a = shape.vertices[ei];
        var b = shape.vertices[(ei + 1) % shape.vertices.length];
        var newVert = [a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1])];
        shape.vertices.splice(ei + 1, 0, newVert);
        if (shape.edges) {
            // Split the edge: new vertex gets a null (straight) edge after it
            shape.edges.splice(ei + 1, 0, null);
        }
        stateVersion++;
        saveState("Insert vertex");
        sendLiveUpdate();
    }

    function removeVertex(vertIdx) {
        if (selectedRect < 0 || selectedRect >= rects.length) return;
        if (isShapeLocked(selectedRect)) return;
        var shape = rects[selectedRect];
        if (shape.vertices.length <= 3) return;
        shape.vertices.splice(vertIdx, 1);
        if (shape.edges && shape.edges.length > vertIdx) {
            shape.edges.splice(vertIdx, 1);
        }
        stateVersion++;
        saveState("Remove vertex");
        sendLiveUpdate();
    }

    function toggleBezierEdge(edgeIdx) {
        if (selectedRect < 0 || selectedRect >= rects.length) return;
        if (isShapeLocked(selectedRect)) return;
        var shape = rects[selectedRect];
        if (!shape.edges) shape.edges = [];
        while (shape.edges.length < shape.vertices.length)
            shape.edges.push(null);

        if (shape.edges[edgeIdx] && shape.edges[edgeIdx].cp1) {
            // Remove bezier: make straight
            shape.edges[edgeIdx] = null;
        } else {
            // Add bezier: place control points at 1/3 and 2/3 of the edge
            var a = shape.vertices[edgeIdx];
            var b = shape.vertices[(edgeIdx + 1) % shape.vertices.length];
            shape.edges[edgeIdx] = {
                cp1: [a[0] + (b[0] - a[0]) / 3, a[1] + (b[1] - a[1]) / 3],
                cp2: [a[0] + 2 * (b[0] - a[0]) / 3, a[1] + 2 * (b[1] - a[1]) / 3]
            };
        }
        stateVersion++;
        saveState("Toggle bezier");
        sendLiveUpdate();
    }

    function toggleAllBezierEdges() {
        if (selectedRect < 0 || selectedRect >= rects.length) return;
        if (isShapeLocked(selectedRect)) return;
        var shape = rects[selectedRect];
        // Check if any edge is bezier
        var hasBezier = false;
        if (shape.edges) {
            for (var i = 0; i < shape.edges.length; i++) {
                if (shape.edges[i] && shape.edges[i].cp1) { hasBezier = true; break; }
            }
        }
        if (hasBezier) {
            // Clear all bezier edges
            shape.edges = [];
        } else {
            // Make all edges bezier
            if (!shape.edges) shape.edges = [];
            while (shape.edges.length < shape.vertices.length)
                shape.edges.push(null);
            for (var i = 0; i < shape.vertices.length; i++) {
                var a = shape.vertices[i];
                var b = shape.vertices[(i + 1) % shape.vertices.length];
                shape.edges[i] = {
                    cp1: [a[0] + (b[0] - a[0]) / 3, a[1] + (b[1] - a[1]) / 3],
                    cp2: [a[0] + 2 * (b[0] - a[0]) / 3, a[1] + 2 * (b[1] - a[1]) / 3]
                };
            }
        }
        stateVersion++;
        saveState("Toggle bezier");
        sendLiveUpdate();
    }

    // ---- Snapping wrappers ----

    function snapVertex(nx, ny, excludeIdx) {
        if (!snappingEnabled) { snapLinesX = []; snapLinesY = []; return [nx, ny]; }
        var result = Snap.snapVertex(nx, ny, excludeIdx, rects, viewport.width, viewport.height, snapThresholdPx);
        snapLinesX = result.linesX;
        snapLinesY = result.linesY;
        return result.pos;
    }

    function snapShapeMove(origVertices, dx, dy, excludeIdx) {
        if (!snappingEnabled) { snapLinesX = []; snapLinesY = []; return { dx: dx, dy: dy }; }
        var result = Snap.snapShapeMove(origVertices, dx, dy, excludeIdx, rects, viewport.width, viewport.height, snapThresholdPx);
        snapLinesX = result.linesX;
        snapLinesY = result.linesY;
        return { dx: result.dx, dy: result.dy };
    }

    function clearSnap() { snapLinesX = []; snapLinesY = []; }

    function finishFreehandShape() {
        var pts = root.drawingPoints;
        root.drawingMode = false;
        root.drawingPoints = [];
        root.stateVersion++;
        if (pts.length < 3) return;

        // Simplify with RDP (epsilon in normalized coords)
        var simplified = Geom.simplifyPath(pts, 0.005);
        if (simplified.length < 3) simplified = pts;

        // Remove last point if it's too close to first (auto-closed)
        var last = simplified[simplified.length - 1];
        var first = simplified[0];
        var d = Math.sqrt((last[0]-first[0])*(last[0]-first[0]) + (last[1]-first[1])*(last[1]-first[1]));
        if (d < 0.01 && simplified.length > 3)
            simplified.pop();

        if (simplified.length < 3) return;

        var shape = ShapeData.createFreehand(simplified, rects.length);
        rects.push(shape);
        selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Draw freehand shape");
        sendLiveUpdate();
    }

    function isShapeLocked(idx) {
        if (idx < 0 || idx >= rects.length) return false;
        return rects[idx].locked || false;
    }

    function isSimpleWarpedQuad(shape) {
        if (!shape || !shape.vertices || shape.vertices.length !== 4) return false;
        if (!shape.warp) return false;
        if (shape.edges) {
            for (var i = 0; i < shape.edges.length; i++)
                if (shape.edges[i] && shape.edges[i].cp1) return false;
        }
        return true;
    }

    readonly property var sourceColors: ["#44ff4444", "#4444ff44", "#444444ff", "#44ffff44", "#44ff44ff", "#4444ffff", "#44ff8844", "#4488ff44"]
    readonly property var sourceBorderColors: ["#ff4444", "#44ff44", "#4444ff", "#ffff44", "#ff44ff", "#44ffff", "#ff8844", "#88ff44"]
    readonly property var blendModeNames: ["Zero", "One", "Src Color", "1-Src Color", "Dst Color", "1-Dst Color", "Src Alpha", "1-Src Alpha", "Dst Alpha", "1-Dst Alpha"]

    // ---- Layout ----

    Page {
        anchors.fill: parent

        palette {
            window: "#222222"
            base: "#161514"
            alternateBase: "#1e1d1c"
            highlight: "#62400a"
            highlightedText: "#FDFDFD"
            windowText: "silver"
            text: "#d0d0d0"
            button: "#1d1c1a"
            buttonText: "#f0f0f0"
            toolTipBase: "#161514"
            toolTipText: "silver"
            midlight: "#62400a"
            light: "#c58014"
            mid: "#252930"
        }
    SplitView {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // ---- Left Panel ----
        ColumnLayout {
            SplitView.preferredWidth: 150
            SplitView.minimumWidth: 100
            SplitView.maximumWidth: 230
            SplitView.fillHeight: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 2

                Button {
                    text: "+ Add"
                    Layout.fillWidth: true
                    onClicked: root.addShape(shapeTypeCombo.currentValue)
                }
                ComboBox {
                    id: shapeTypeCombo
                    Layout.preferredWidth: 90
                    implicitHeight: 30
                    font.pixelSize: 11
                    model: ListModel {
                        ListElement { text: "Quad"; value: "quad" }
                        ListElement { text: "Triangle"; value: "triangle" }
                        ListElement { text: "Pentagon"; value: "pentagon" }
                        ListElement { text: "Hexagon"; value: "hexagon" }
                        ListElement { text: "Circle"; value: "circle" }
                        ListElement { text: "Star"; value: "star" }
                    }
                    textRole: "text"
                    valueRole: "value"
                }
            }

            ListView {
                id: rectListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: {
                    root.stateVersion;
                    return root.rects.length;
                }

                delegate: Rectangle {
                    id: listDel
                    required property int index
                    property int delIndex: index
                    width: rectListView.width
                    height: delLayout.implicitHeight + 12
                    radius: 4
                    color: root.selectedRect === delIndex ? palette.highlight : (delIndex % 2 ? palette.alternateBase : palette.base)
                    border.color: root.selectedRect === delIndex ? palette.light : "transparent"
                    border.width: 1

                    property var rd: {
                        root.stateVersion;
                        return delIndex < root.rects.length ? root.rects[delIndex] : null;
                    }
                    opacity: (listDel.rd && listDel.rd.visible === false) ? 0.4 : 1.0

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { root.forceActiveFocus(); root.selectedRect = listDel.delIndex; }
                    }

                    ColumnLayout {
                        id: delLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        RowLayout {
                            spacing: 2
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 2
                                color: listDel.rd ? root.sourceBorderColors[listDel.rd.source] : palette.mid
                            }
                            Button {
                                text: (listDel.rd && listDel.rd.visible !== false) ? "\u25CF" : "\u25CB"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 11
                                onClicked: {
                                    var cur = root.rects[listDel.delIndex].visible;
                                    root.rects[listDel.delIndex].visible = (cur !== undefined ? !cur : false);
                                    root.stateVersion++;
                                    root.saveState("Toggle visibility");
                                    root.sendLiveUpdate();
                                }
                            }
                            Button {
                                text: (listDel.rd && listDel.rd.locked) ? "Lk" : "Ul"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 9
                                onClicked: {
                                    root.rects[listDel.delIndex].locked = !(root.rects[listDel.delIndex].locked || false);
                                    root.stateVersion++;
                                    root.saveState("Toggle lock");
                                    root.sendLiveUpdate();
                                }
                            }
                            TextInput {
                                id: nameInput
                                text: listDel.rd ? listDel.rd.name : ""
                                font.bold: true
                                color: palette.text
                                Layout.fillWidth: true
                                selectByMouse: true
                                function commitName() {
                                    if (listDel.delIndex < root.rects.length && root.rects[listDel.delIndex].name !== text) {
                                        root.rects[listDel.delIndex].name = text;
                                        root.stateVersion++;
                                        root.saveState("Rename shape");
                                        root.sendLiveUpdate();
                                    }
                                }
                                onEditingFinished: { commitName(); focus = false; }
                                onActiveFocusChanged: if (!activeFocus) commitName()
                            }
                            Button {
                                text: "\u25B2"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 9
                                enabled: listDel.delIndex > 0
                                onClicked: root.moveRectDown(listDel.delIndex)
                            }
                            Button {
                                text: "\u25BC"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 9
                                enabled: listDel.delIndex < root.rects.length - 1
                                onClicked: root.moveRectUp(listDel.delIndex)
                            }
                            Button {
                                text: "D"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 10
                                onClicked: root.duplicateRect(listDel.delIndex)
                            }
                            Button {
                                text: "\u2715"
                                flat: true
                                implicitWidth: 18
                                implicitHeight: 18
                                font.pixelSize: 12
                                onClicked: root.deleteRect(listDel.delIndex)
                            }
                        }

                        Label {
                            text: listDel.rd ? "(Tex " + (listDel.rd.source + 1) + ")" : ""
                            color: palette.windowText
                            font.pixelSize: 10
                        }
                    }
                }
            }

            CheckBox {
                text: "Snap"
                checked: root.snappingEnabled
                onToggled: root.snappingEnabled = checked
            }
        }

        // ---- Center Panel: viewport ----
        Item {
            id: viewport
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            clip: true

            Rectangle {
                anchors.fill: parent
                color: palette.base
            }

            // Background grid
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "rgba(255,255,255,0.08)";
                    ctx.lineWidth = 1;
                    var step = Math.max(width, height) / 10;
                    for (var x = step; x < width; x += step) {
                        ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
                    }
                    for (var y = step; y < height; y += step) {
                        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
                    }
                }
            }

            // Shape overlay canvas
            Canvas {
                id: quadOverlay
                anchors.fill: parent

                property int ver: root.stateVersion
                onVerChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width, h = height;
                    ctx.clearRect(0, 0, w, h);

                    for (var qi = 0; qi < root.rects.length; qi++) {
                        var r = root.rects[qi];
                        var c = r.vertices;
                        if (!c || c.length < 3) continue;

                        var isSelected = (qi === root.selectedRect);
                        var isHidden = (r.visible === false);
                        var edges = r.edges;

                        // Draw hidden shapes ghosted
                        if (isHidden) ctx.globalAlpha = 0.15;

                        // Build path (handles both straight and bezier edges)
                        ctx.beginPath();
                        ctx.moveTo(c[0][0] * w, c[0][1] * h);
                        for (var ci = 0; ci < c.length; ci++) {
                            var nextIdx = (ci + 1) % c.length;
                            var edge = (edges && ci < edges.length) ? edges[ci] : null;
                            if (edge && edge.cp1 && edge.cp2) {
                                ctx.bezierCurveTo(
                                    edge.cp1[0] * w, edge.cp1[1] * h,
                                    edge.cp2[0] * w, edge.cp2[1] * h,
                                    c[nextIdx][0] * w, c[nextIdx][1] * h
                                );
                            } else {
                                ctx.lineTo(c[nextIdx][0] * w, c[nextIdx][1] * h);
                            }
                        }

                        // Fill
                        ctx.fillStyle = root.sourceColors[r.source];
                        ctx.fill();

                        // Border
                        ctx.strokeStyle = isSelected ? "white" : root.sourceBorderColors[r.source];
                        ctx.lineWidth = isSelected ? 2 : 1;
                        ctx.stroke();

                        // Bezier tangent lines for selected shape
                        if (isSelected && edges) {
                            ctx.strokeStyle = "rgba(197,128,20,0.6)";
                            ctx.lineWidth = 1;
                            for (var ei = 0; ei < edges.length; ei++) {
                                var e = edges[ei];
                                if (!e || !e.cp1 || !e.cp2) continue;
                                // Line from vertex to cp1
                                ctx.beginPath();
                                ctx.moveTo(c[ei][0] * w, c[ei][1] * h);
                                ctx.lineTo(e.cp1[0] * w, e.cp1[1] * h);
                                ctx.stroke();
                                // Line from next vertex to cp2
                                var ni = (ei + 1) % c.length;
                                ctx.beginPath();
                                ctx.moveTo(c[ni][0] * w, c[ni][1] * h);
                                ctx.lineTo(e.cp2[0] * w, e.cp2[1] * h);
                                ctx.stroke();
                            }
                        }

                        // Grid lines for selected simple warped quads
                        if (isSelected && root.isSimpleWarpedQuad(r)) {
                            var gw = r.gridW || 4;
                            var gh = r.gridH || 4;
                            ctx.strokeStyle = "rgba(255,255,255,0.25)";
                            ctx.lineWidth = 1;
                            // Horizontal grid lines
                            for (var gr = 0; gr <= gh; gr++) {
                                ctx.beginPath();
                                for (var gc = 0; gc <= gw; gc++) {
                                    var gp = ShapeData.gridPointPos(r, gr, gc);
                                    if (gc === 0) ctx.moveTo(gp[0] * w, gp[1] * h);
                                    else ctx.lineTo(gp[0] * w, gp[1] * h);
                                }
                                ctx.stroke();
                            }
                            // Vertical grid lines
                            for (var gc = 0; gc <= gw; gc++) {
                                ctx.beginPath();
                                for (var gr = 0; gr <= gh; gr++) {
                                    var gp = ShapeData.gridPointPos(r, gr, gc);
                                    if (gr === 0) ctx.moveTo(gp[0] * w, gp[1] * h);
                                    else ctx.lineTo(gp[0] * w, gp[1] * h);
                                }
                                ctx.stroke();
                            }
                        }

                        // Label at centroid
                        var ct = Geom.polygonCentroid(c);
                        var cx = ct[0] * w, cy = ct[1] * h;
                        var label;
                        if (root.isDragging && isSelected)
                            label = Geom.formatInfo(r, root.renderWidth, root.renderHeight);
                        else
                            label = r.name + "\n(Tex " + (r.source + 1) + ")";

                        var lines = label.split("\n");
                        ctx.font = "bold 11px sans-serif";
                        ctx.textAlign = "center";
                        ctx.textBaseline = "middle";
                        var lineH = 14;
                        var startY = cy - (lines.length - 1) * lineH / 2;
                        for (var li = 0; li < lines.length; li++) {
                            var ly = startY + li * lineH;
                            ctx.strokeStyle = "#000";
                            ctx.lineWidth = 3;
                            ctx.strokeText(lines[li], cx, ly);
                            ctx.fillStyle = "white";
                            ctx.fillText(lines[li], cx, ly);
                        }

                        // Reset alpha after hidden shape
                        if (isHidden) ctx.globalAlpha = 1.0;
                    }
                }
            }

            // Freehand drawing overlay
            Canvas {
                id: drawOverlay
                anchors.fill: parent
                visible: root.drawingMode
                z: 15

                property int drawVer: root.drawingVersion
                onDrawVerChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width, h = height;
                    ctx.clearRect(0, 0, w, h);
                    var pts = root.drawingPoints;
                    if (pts.length < 2) return;

                    // Build closed path from raw points
                    ctx.beginPath();
                    ctx.moveTo(pts[0][0] * w, pts[0][1] * h);
                    for (var i = 1; i < pts.length; i++)
                        ctx.lineTo(pts[i][0] * w, pts[i][1] * h);
                    ctx.closePath();

                    // Filled preview
                    if (pts.length >= 3) {
                        ctx.fillStyle = "rgba(197,128,20,0.25)";
                        ctx.fill();
                    }

                    // Stroke outline
                    ctx.strokeStyle = "#c58014";
                    ctx.lineWidth = 2;
                    ctx.lineJoin = "round";
                    ctx.lineCap = "round";
                    ctx.stroke();
                }
            }

            // Corner handles for selected shape
            Repeater {
                model: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return 0;
                    return root.rects[root.selectedRect].vertices.length;
                }

                Rectangle {
                    id: cornerHandle
                    property int ci: index
                    property var corner: {
                        root.stateVersion;
                        if (root.selectedRect < 0 || root.selectedRect >= root.rects.length)
                            return [0, 0];
                        var c = root.rects[root.selectedRect].vertices;
                        return ci < c.length ? c[ci] : [0, 0];
                    }

                    x: corner[0] * viewport.width - 7
                    y: corner[1] * viewport.height - 7
                    width: 14
                    height: 14
                    radius: 7
                    color: palette.buttonText
                    border.color: palette.button
                    border.width: 1
                    z: 10

                    Label {
                        anchors.centerIn: parent
                        text: (cornerHandle.ci + 1).toString()
                        color: palette.button
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: root.isShapeLocked(root.selectedRect) ? Qt.ForbiddenCursor : Qt.CrossCursor

                        property real startX
                        property real startY
                        property real origCX
                        property real origCY
                        property bool removed: false

                        onPressed: function (mouse) {
                            if (root.isShapeLocked(root.selectedRect)) return;
                            removed = false;
                            // Right-click: toggle bezier on outgoing edge
                            if (mouse.button === Qt.RightButton) {
                                root.toggleBezierEdge(cornerHandle.ci);
                                return;
                            }
                            // Ctrl+click: remove vertex
                            if (mouse.modifiers & Qt.ControlModifier) {
                                root.removeVertex(cornerHandle.ci);
                                removed = true;
                                return;
                            }
                            root.isDragging = true;
                            root.dragCorner = cornerHandle.ci;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            startX = p.x;
                            startY = p.y;
                            var c = root.rects[root.selectedRect].vertices[cornerHandle.ci];
                            origCX = c[0];
                            origCY = c[1];
                            root.beginUpdateState("Move vertex");
                        }

                        onPositionChanged: function (mouse) {
                            if (removed || !root.isDragging) return;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var nx = origCX + (p.x - startX) / viewport.width;
                            var ny = origCY + (p.y - startY) / viewport.height;
                            var snapped = root.snapVertex(nx, ny, root.selectedRect);
                            root.rects[root.selectedRect].vertices[cornerHandle.ci] = snapped;
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            if (removed || !root.isDragging) return;
                            root.isDragging = false;
                            root.dragCorner = -1;
                            root.clearSnap();
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }
                    }
                }
            }

            // Rotation handle for selected shape
            Item {
                id: rotHandle
                visible: root.selectedRect >= 0 && root.selectedRect < root.rects.length
                z: 10

                property var topCenter: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length)
                        return [0.5, 0.5];
                    var c = root.rects[root.selectedRect].vertices;
                    return [(c[0][0] + c[1 % c.length][0]) / 2,
                            (c[0][1] + c[1 % c.length][1]) / 2];
                }
                readonly property real handleOffset: 25
                property real hx: topCenter[0] * viewport.width
                property real hy: topCenter[1] * viewport.height - handleOffset

                Rectangle {
                    x: rotHandle.hx - 0.5
                    y: rotHandle.hy + 5
                    width: 1
                    height: rotHandle.handleOffset - 5
                    color: palette.buttonText
                    opacity: 0.5
                }

                Rectangle {
                    id: rotCircle
                    x: rotHandle.hx - 7
                    y: rotHandle.hy - 7
                    width: 14
                    height: 14
                    radius: 7
                    color: palette.light
                    border.color: palette.buttonText
                    border.width: 1

                    Label {
                        anchors.centerIn: parent
                        text: "\u21BB"
                        color: palette.buttonText
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        cursorShape: root.isShapeLocked(root.selectedRect) ? Qt.ForbiddenCursor : Qt.ClosedHandCursor

                        property real startAngle
                        property var origVertices
                        property var origEdges
                        property var origGridOffsets

                        onPressed: function (mouse) {
                            if (root.isShapeLocked(root.selectedRect)) return;
                            root.isDragging = true;
                            var shape = root.rects[root.selectedRect];
                            var ct = Geom.polygonCentroid(shape.vertices);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cx = ct[0] * viewport.width;
                            var cy = ct[1] * viewport.height;
                            startAngle = Math.atan2(p.y - cy, p.x - cx);
                            origVertices = JSON.parse(JSON.stringify(shape.vertices));
                            origEdges = shape.edges ? JSON.parse(JSON.stringify(shape.edges)) : null;
                            origGridOffsets = shape.gridOffsets ? shape.gridOffsets.slice() : null;
                            root.beginUpdateState("Rotate shape");
                        }

                        onPositionChanged: function (mouse) {
                            var ct = Geom.polygonCentroid(origVertices);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cx = ct[0] * viewport.width;
                            var cy = ct[1] * viewport.height;
                            var angle = Math.atan2(p.y - cy, p.x - cx) - startAngle;
                            var shape = root.rects[root.selectedRect];
                            shape.vertices = Geom.rotateVertices(origVertices, ct, angle);
                            if (origEdges)
                                shape.edges = Geom.rotateEdges(origEdges, ct, angle);
                            if (origGridOffsets) {
                                var cos_a = Math.cos(angle);
                                var sin_a = Math.sin(angle);
                                var newOff = origGridOffsets.slice();
                                for (var i = 0; i < newOff.length; i += 2) {
                                    var dx = origGridOffsets[i];
                                    var dy = origGridOffsets[i + 1];
                                    newOff[i] = dx * cos_a - dy * sin_a;
                                    newOff[i + 1] = dx * sin_a + dy * cos_a;
                                }
                                shape.gridOffsets = newOff;
                            }
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            root.isDragging = false;
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }
                    }
                }
            }

            // Scale handle for selected shape
            Item {
                id: scaleHandle
                visible: root.selectedRect >= 0 && root.selectedRect < root.rects.length
                z: 10

                property var bottomRight: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length)
                        return [0.5, 0.5];
                    var bb = Geom.polygonBBox(root.rects[root.selectedRect].vertices);
                    return [bb.maxX, bb.maxY];
                }
                readonly property real handleOffset: 20
                property real hx: bottomRight[0] * viewport.width + handleOffset
                property real hy: bottomRight[1] * viewport.height + handleOffset

                // Connecting line from bottom-right corner to handle
                Canvas {
                    x: scaleHandle.bottomRight[0] * viewport.width
                    y: scaleHandle.bottomRight[1] * viewport.height
                    width: scaleHandle.handleOffset + 7
                    height: scaleHandle.handleOffset + 7
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = palette.buttonText;
                        ctx.globalAlpha = 0.5;
                        ctx.lineWidth = 1;
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(width - 7, height - 7);
                        ctx.stroke();
                    }
                }

                Rectangle {
                    id: scaleCircle
                    x: scaleHandle.hx - 7
                    y: scaleHandle.hy - 7
                    width: 14
                    height: 14
                    radius: 2
                    color: palette.light
                    border.color: palette.buttonText
                    border.width: 1

                    Label {
                        anchors.centerIn: parent
                        text: "\u2922"
                        color: palette.buttonText
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        cursorShape: root.isShapeLocked(root.selectedRect) ? Qt.ForbiddenCursor : Qt.SizeFDiagCursor

                        property real startDist
                        property var origVertices
                        property var origEdges
                        property var origGridOffsets

                        onPressed: function (mouse) {
                            if (root.isShapeLocked(root.selectedRect)) return;
                            root.isDragging = true;
                            var shape = root.rects[root.selectedRect];
                            var ct = Geom.polygonCentroid(shape.vertices);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cpx = ct[0] * viewport.width;
                            var cpy = ct[1] * viewport.height;
                            startDist = Math.sqrt((p.x - cpx) * (p.x - cpx) + (p.y - cpy) * (p.y - cpy));
                            if (startDist < 1) startDist = 1;
                            origVertices = JSON.parse(JSON.stringify(shape.vertices));
                            origEdges = shape.edges ? JSON.parse(JSON.stringify(shape.edges)) : null;
                            origGridOffsets = shape.gridOffsets ? shape.gridOffsets.slice() : null;
                            root.beginUpdateState("Scale shape");
                        }

                        onPositionChanged: function (mouse) {
                            var ct = Geom.polygonCentroid(origVertices);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cpx = ct[0] * viewport.width;
                            var cpy = ct[1] * viewport.height;
                            var curDist = Math.sqrt((p.x - cpx) * (p.x - cpx) + (p.y - cpy) * (p.y - cpy));
                            var s = curDist / startDist;

                            var shape = root.rects[root.selectedRect];
                            shape.vertices = Geom.scaleVertices(origVertices, ct, s, s);
                            if (origEdges)
                                shape.edges = Geom.scaleEdges(origEdges, ct, s, s);
                            if (origGridOffsets) {
                                var newOff = origGridOffsets.slice();
                                for (var i = 0; i < newOff.length; i++)
                                    newOff[i] = origGridOffsets[i] * s;
                                shape.gridOffsets = newOff;
                            }
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            root.isDragging = false;
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }
                    }
                }
            }

            // Bezier control point handles for selected shape
            Repeater {
                id: bezierCpRepeater
                model: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return [];
                    var shape = root.rects[root.selectedRect];
                    if (!shape.edges) return [];
                    var handles = [];
                    for (var i = 0; i < shape.edges.length; i++) {
                        var e = shape.edges[i];
                        if (e && e.cp1 && e.cp2) {
                            handles.push({ edgeIdx: i, cpIdx: 0 });
                            handles.push({ edgeIdx: i, cpIdx: 1 });
                        }
                    }
                    return handles;
                }

                Rectangle {
                    id: cpHandle
                    property var cpInfo: modelData || { edgeIdx: 0, cpIdx: 0 }
                    property var cpPos: {
                        root.stateVersion;
                        if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return [0, 0];
                        var shape = root.rects[root.selectedRect];
                        if (!shape.edges || cpInfo.edgeIdx >= shape.edges.length) return [0, 0];
                        var e = shape.edges[cpInfo.edgeIdx];
                        if (!e) return [0, 0];
                        return cpInfo.cpIdx === 0 ? (e.cp1 || [0,0]) : (e.cp2 || [0,0]);
                    }

                    x: cpPos[0] * viewport.width - 5
                    y: cpPos[1] * viewport.height - 5
                    width: 10
                    height: 10
                    radius: 0
                    color: palette.light
                    border.color: palette.buttonText
                    border.width: 1
                    z: 10

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        cursorShape: root.isShapeLocked(root.selectedRect) ? Qt.ForbiddenCursor : Qt.CrossCursor

                        property real startX
                        property real startY
                        property real origX
                        property real origY

                        onPressed: function (mouse) {
                            if (root.isShapeLocked(root.selectedRect)) return;
                            root.isDragging = true;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            startX = p.x;
                            startY = p.y;
                            origX = cpHandle.cpPos[0];
                            origY = cpHandle.cpPos[1];
                            root.beginUpdateState("Move control point");
                        }

                        onPositionChanged: function (mouse) {
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var nx = origX + (p.x - startX) / viewport.width;
                            var ny = origY + (p.y - startY) / viewport.height;
                            var shape = root.rects[root.selectedRect];
                            var cpKey = cpHandle.cpInfo.cpIdx === 0 ? "cp1" : "cp2";
                            shape.edges[cpHandle.cpInfo.edgeIdx][cpKey] = [nx, ny];
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            root.isDragging = false;
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }
                    }
                }
            }

            // Grid point handles for selected simple warped quads
            Repeater {
                id: gridHandleRepeater
                model: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return [];
                    var shape = root.rects[root.selectedRect];
                    if (!root.isSimpleWarpedQuad(shape)) return [];
                    var gw = shape.gridW || 4;
                    var gh = shape.gridH || 4;
                    var handles = [];
                    for (var row = 0; row <= gh; row++) {
                        for (var col = 0; col <= gw; col++) {
                            // Skip the 4 corners (handled by corner handles)
                            if ((row === 0 || row === gh) && (col === 0 || col === gw)) continue;
                            handles.push({ row: row, col: col });
                        }
                    }
                    return handles;
                }

                Rectangle {
                    id: gridHandle
                    property var gpInfo: modelData || { row: 0, col: 0 }
                    property var gpPos: {
                        root.stateVersion;
                        if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return [0, 0];
                        return ShapeData.gridPointPos(root.rects[root.selectedRect], gpInfo.row, gpInfo.col);
                    }

                    x: gpPos[0] * viewport.width - 4
                    y: gpPos[1] * viewport.height - 4
                    width: 8
                    height: 8
                    radius: 0
                    color: "transparent"
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.6)
                    border.width: 1
                    z: 9

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        cursorShape: root.isShapeLocked(root.selectedRect) ? Qt.ForbiddenCursor : Qt.CrossCursor

                        property real startX
                        property real startY
                        property real origOffX
                        property real origOffY

                        onPressed: function (mouse) {
                            if (root.isShapeLocked(root.selectedRect)) return;
                            root.isDragging = true;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            startX = p.x;
                            startY = p.y;

                            var shape = root.rects[root.selectedRect];
                            var gw = shape.gridW || 4;
                            var gh = shape.gridH || 4;
                            var gi = gridHandle.gpInfo.row * (gw + 1) + gridHandle.gpInfo.col;

                            // Initialize gridOffsets if needed
                            if (!shape.gridOffsets) {
                                shape.gridOffsets = ShapeData.initGridOffsets(gw, gh);
                            }

                            origOffX = shape.gridOffsets[gi * 2] || 0;
                            origOffY = shape.gridOffsets[gi * 2 + 1] || 0;
                            root.beginUpdateState("Move grid point");
                        }

                        onPositionChanged: function (mouse) {
                            if (!root.isDragging) return;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var dx = (p.x - startX) / viewport.width;
                            var dy = (p.y - startY) / viewport.height;

                            var shape = root.rects[root.selectedRect];
                            var gw = shape.gridW || 4;
                            var gi = gridHandle.gpInfo.row * (gw + 1) + gridHandle.gpInfo.col;

                            shape.gridOffsets[gi * 2] = origOffX + dx;
                            shape.gridOffsets[gi * 2 + 1] = origOffY + dy;
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            if (!root.isDragging) return;
                            root.isDragging = false;
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }

                        onDoubleClicked: function (mouse) {
                            // Reset this grid point to default position
                            var shape = root.rects[root.selectedRect];
                            if (!shape.gridOffsets) return;
                            var gw = shape.gridW || 4;
                            var gi = gridHandle.gpInfo.row * (gw + 1) + gridHandle.gpInfo.col;
                            shape.gridOffsets[gi * 2] = 0;
                            shape.gridOffsets[gi * 2 + 1] = 0;
                            root.stateVersion++;
                            root.saveState("Reset grid point");
                            root.sendLiveUpdate();
                        }
                    }
                }
            }

            // Snap guide lines (vertical)
            Repeater {
                model: root.snapLinesX.length
                Rectangle {
                    x: root.snapLinesX[index] * viewport.width - 0.5
                    y: 0
                    width: 1
                    height: viewport.height
                    color: palette.light
                    opacity: 0.7
                    visible: root.isDragging
                    z: 8
                }
            }

            // Snap guide lines (horizontal)
            Repeater {
                model: root.snapLinesY.length
                Rectangle {
                    x: 0
                    y: root.snapLinesY[index] * viewport.height - 0.5
                    width: viewport.width
                    height: 1
                    color: palette.light
                    opacity: 0.7
                    visible: root.isDragging
                    z: 8
                }
            }

            // Background MouseArea: selection, deselection, move-drag, freehand draw
            MouseArea {
                anchors.fill: parent
                z: -1

                property int dragMode: 0 // 0=none, 1=move, 2=drawing
                property real startX
                property real startY
                property var origVertices: null
                property var origEdges: null
                property bool wantsAltDup: false
                property bool didDuplicate: false
                property int hitSrcIdx: -1

                onDoubleClicked: function (mouse) {
                    if (root.drawingMode) return;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return;
                    if (root.isShapeLocked(root.selectedRect)) return;
                    var nx = mouse.x / viewport.width;
                    var ny = mouse.y / viewport.height;
                    // Check if click is near edge or in body
                    var shape = root.rects[root.selectedRect];
                    var nearest = Geom.nearestEdge(nx, ny, shape.vertices);
                    if (nearest.dist > 0.03) {
                        // Body click: set UV mode to manual
                        shape.uvMode = "manual";
                        root.stateVersion++;
                        root.saveState("UV manual mode");
                        root.sendLiveUpdate();
                    } else {
                        root.insertVertexOnEdge(nx, ny);
                    }
                    // Cancel any drag that was started by the first click
                    dragMode = 0;
                    root.isDragging = false;
                }

                onPressed: function (mouse) {
                    root.forceActiveFocus();
                    var nx = mouse.x / viewport.width;
                    var ny = mouse.y / viewport.height;
                    wantsAltDup = false;
                    didDuplicate = false;
                    hitSrcIdx = -1;

                    var hitIdx = -1;
                    for (var i = root.rects.length - 1; i >= 0; i--) {
                        if (Geom.pointInPolygon(nx, ny, root.rects[i].vertices)) {
                            hitIdx = i;
                            break;
                        }
                    }

                    if (hitIdx >= 0) {
                        root.selectedRect = hitIdx;
                        // Allow selection but prevent dragging locked shapes
                        if (root.isShapeLocked(hitIdx)) return;
                        wantsAltDup = !!(mouse.modifiers & Qt.AltModifier);
                        hitSrcIdx = hitIdx;
                        dragMode = 1;
                        root.isDragging = true;
                        root.dragCorner = -1;
                        startX = mouse.x;
                        startY = mouse.y;
                        origVertices = JSON.parse(JSON.stringify(root.rects[hitIdx].vertices));
                        origEdges = root.rects[hitIdx].edges ? JSON.parse(JSON.stringify(root.rects[hitIdx].edges)) : null;
                        root.beginUpdateState(wantsAltDup ? "Duplicate shape" : "Move shape");
                    } else if (mouse.modifiers & Qt.AltModifier) {
                        // Alt+click on empty space: start freehand drawing
                        root.selectedRect = -1;
                        dragMode = 2;
                        root.drawingMode = true;
                        root.drawingPoints = [[nx, ny]];
                    } else {
                        root.selectedRect = -1;
                        dragMode = 0;
                    }
                }

                onPositionChanged: function (mouse) {
                    if (dragMode === 2) {
                        // Freehand drawing: sample points with min distance
                        var nx = mouse.x / viewport.width;
                        var ny = mouse.y / viewport.height;
                        var pts = root.drawingPoints;
                        if (pts.length > 0) {
                            var last = pts[pts.length - 1];
                            var dx = nx - last[0], dy = ny - last[1];
                            if (dx*dx + dy*dy < 0.0001) return; // min distance filter
                        }
                        pts.push([nx, ny]);
                        root.drawingVersion++;
                        return;
                    }

                    if (dragMode !== 1) return;

                    if (wantsAltDup && !didDuplicate) {
                        var src = root.rects[hitSrcIdx];
                        var dup = ShapeData.cloneShape(src);
                        dup.id = "shape-" + Date.now();
                        dup.name = Geom.incrementName(src.name);
                        root.rects.push(dup);
                        root.selectedRect = root.rects.length - 1;
                        didDuplicate = true;
                        root.stateVersion++;
                    }

                    var dx = (mouse.x - startX) / viewport.width;
                    var dy = (mouse.y - startY) / viewport.height;
                    var snapped = root.snapShapeMove(origVertices, dx, dy, root.selectedRect);
                    var r = root.rects[root.selectedRect];
                    for (var i = 0; i < r.vertices.length; i++) {
                        r.vertices[i] = [origVertices[i][0] + snapped.dx,
                                        origVertices[i][1] + snapped.dy];
                    }
                    if (origEdges) {
                        if (!r.edges) r.edges = [];
                        for (var i = 0; i < origEdges.length; i++) {
                            var e = origEdges[i];
                            if (e && e.cp1 && e.cp2) {
                                r.edges[i] = {
                                    cp1: [e.cp1[0] + snapped.dx, e.cp1[1] + snapped.dy],
                                    cp2: [e.cp2[0] + snapped.dx, e.cp2[1] + snapped.dy]
                                };
                            }
                        }
                    }
                    root.stateVersion++;
                    root.sendLiveUpdate();
                }

                onReleased: {
                    if (dragMode === 2) {
                        root.finishFreehandShape();
                        dragMode = 0;
                        return;
                    }
                    if (dragMode !== 0) {
                        root.isDragging = false;
                        root.clearSnap();
                        root.updateState("mapperState", JSON.stringify(root.rects));
                        root.endUpdateState();
                    }
                    dragMode = 0;
                    wantsAltDup = false;
                }
            }
        }

        // ---- Right Panel: shape properties ----
        ColumnLayout {
            id: propsPanel
            SplitView.preferredWidth: 170
            SplitView.minimumWidth: 140
            SplitView.maximumWidth: 260
            SplitView.fillHeight: true
            spacing: 4

            property var selShape: {
                root.stateVersion;
                if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return null;
                return root.rects[root.selectedRect];
            }
            property var selBlend: selShape ? (selShape.blend || { top: 0, right: 0, bottom: 0, left: 0 }) : null
            property real selGamma: selShape ? (selShape.blendGamma || 1.0) : 1.0
            property real selOpacity: {
                if (!selShape) return 1.0;
                var v = selShape.opacity;
                return (v !== undefined) ? v : 1.0;
            }
            property string selUvMode: selShape ? (selShape.uvMode || "auto") : "auto"
            property var selUvOffset: selShape ? (selShape.uvOffset || [0,0]) : [0,0]
            property var selUvScale: selShape ? (selShape.uvScale || [1,1]) : [1,1]
            property real selUvRotation: selShape ? (selShape.uvRotation || 0) : 0
            property int selSrcBlend: {
                if (!selShape) return 1;
                var v = selShape.srcBlend;
                return (typeof v === 'number') ? v : 1;
            }
            property int selDstBlend: {
                if (!selShape) return 7;
                var v = selShape.dstBlend;
                return (typeof v === 'number') ? v : 7;
            }

            function setBlendEdge(edge, val) {
                var r = root.rects[root.selectedRect];
                if (!r.blend) r.blend = { top: 0, right: 0, bottom: 0, left: 0 };
                r.blend[edge] = val;
                root.stateVersion++;
                root.saveState("Edge blend");
                root.sendLiveUpdate();
            }
            function setGamma(val) {
                root.rects[root.selectedRect].blendGamma = val;
                root.stateVersion++;
                root.saveState("Blend gamma");
                root.sendLiveUpdate();
            }
            function setOpacity(val) {
                root.rects[root.selectedRect].opacity = val;
                root.stateVersion++;
                root.saveState("Shape opacity");
                root.sendLiveUpdate();
            }
            function setUvMode(mode) {
                root.rects[root.selectedRect].uvMode = mode;
                root.stateVersion++;
                root.saveState("UV mode");
                root.sendLiveUpdate();
            }
            function setUvOffset(x, y) {
                root.rects[root.selectedRect].uvOffset = [x, y];
                root.stateVersion++;
                root.saveState("UV offset");
                root.sendLiveUpdate();
            }
            function setUvScale(x, y) {
                root.rects[root.selectedRect].uvScale = [x, y];
                root.stateVersion++;
                root.saveState("UV scale");
                root.sendLiveUpdate();
            }
            function setUvRotation(val) {
                root.rects[root.selectedRect].uvRotation = val;
                root.stateVersion++;
                root.saveState("UV rotation");
                root.sendLiveUpdate();
            }
            function setSrcBlend(idx) {
                root.rects[root.selectedRect].srcBlend = idx;
                root.stateVersion++;
                root.saveState("Src blend mode");
                root.sendLiveUpdate();
            }
            function setDstBlend(idx) {
                root.rects[root.selectedRect].dstBlend = idx;
                root.stateVersion++;
                root.saveState("Dst blend mode");
                root.sendLiveUpdate();
            }

            // --- Source & Warp ---
            Label { text: "Shape"; font.bold: true; color: palette.windowText; font.pixelSize: 11 }

            RowLayout {
                spacing: 4
                Layout.fillWidth: true
                Label { text: "Source:"; color: palette.windowText; font.pixelSize: 11 }
                ComboBox {
                    model: ["Tex 1", "Tex 2", "Tex 3", "Tex 4", "Tex 5", "Tex 6", "Tex 7", "Tex 8"]
                    currentIndex: propsPanel.selShape ? propsPanel.selShape.source : 0
                    implicitWidth: 90
                    implicitHeight: 24
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    onActivated: {
                        root.rects[root.selectedRect].source = currentIndex;
                        root.stateVersion++;
                        root.saveState("Change source");
                        root.sendLiveUpdate();
                    }
                }
            }

            RowLayout {
                spacing: 4
                Layout.fillWidth: true
                CheckBox {
                    text: "Warp"
                    checked: propsPanel.selShape ? (propsPanel.selShape.warp || false) : false
                    font.pixelSize: 11
                    implicitHeight: 24
                    onToggled: {
                        root.rects[root.selectedRect].warp = checked;
                        root.stateVersion++;
                        root.saveState("Toggle warp");
                        root.sendLiveUpdate();
                    }
                }
            }

            RowLayout {
                spacing: 4
                Layout.fillWidth: true
                visible: propsPanel.selShape ? root.isSimpleWarpedQuad(propsPanel.selShape) : false
                Label { text: "Grid:"; color: palette.windowText; font.pixelSize: 11 }
                SpinBox {
                    from: 1; to: 16
                    value: propsPanel.selShape ? (propsPanel.selShape.gridW || 4) : 4
                    implicitWidth: 60; implicitHeight: 24; font.pixelSize: 11
                    onValueModified: {
                        root.rects[root.selectedRect].gridW = value;
                        root.rects[root.selectedRect].gridOffsets = null;
                        root.stateVersion++;
                        root.saveState("Grid width");
                        root.sendLiveUpdate();
                    }
                }
                Label { text: "\u00D7"; color: palette.windowText; font.pixelSize: 11 }
                SpinBox {
                    from: 1; to: 16
                    value: propsPanel.selShape ? (propsPanel.selShape.gridH || 4) : 4
                    implicitWidth: 60; implicitHeight: 24; font.pixelSize: 11
                    onValueModified: {
                        root.rects[root.selectedRect].gridH = value;
                        root.rects[root.selectedRect].gridOffsets = null;
                        root.stateVersion++;
                        root.saveState("Grid height");
                        root.sendLiveUpdate();
                    }
                }
            }

            // --- Opacity ---
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "Opacity:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 42 }
                Slider { from: 0; to: 1.0; stepSize: 0.01; value: propsPanel.selOpacity; Layout.fillWidth: true; onMoved: propsPanel.setOpacity(value) }
            }

            // --- Edge Blend ---
            Label { text: "Edge Blend"; font.bold: true; color: palette.windowText; font.pixelSize: 11; topPadding: 4 }

            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "T:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                Slider { from: 0; to: 0.5; stepSize: 0.01; value: propsPanel.selBlend ? propsPanel.selBlend.top : 0; Layout.fillWidth: true; onMoved: propsPanel.setBlendEdge("top", value) }
            }
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "B:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                Slider { from: 0; to: 0.5; stepSize: 0.01; value: propsPanel.selBlend ? propsPanel.selBlend.bottom : 0; Layout.fillWidth: true; onMoved: propsPanel.setBlendEdge("bottom", value) }
            }
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "L:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                Slider { from: 0; to: 0.5; stepSize: 0.01; value: propsPanel.selBlend ? propsPanel.selBlend.left : 0; Layout.fillWidth: true; onMoved: propsPanel.setBlendEdge("left", value) }
            }
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "R:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                Slider { from: 0; to: 0.5; stepSize: 0.01; value: propsPanel.selBlend ? propsPanel.selBlend.right : 0; Layout.fillWidth: true; onMoved: propsPanel.setBlendEdge("right", value) }
            }
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "\u03B3:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                Slider { from: 0.5; to: 4.0; stepSize: 0.1; value: propsPanel.selGamma; Layout.fillWidth: true; onMoved: propsPanel.setGamma(value) }
            }

            // --- Blend Mode ---
            Label { text: "Blend Mode"; font.bold: true; color: palette.windowText; font.pixelSize: 11; topPadding: 4 }

            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "Src:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 24 }
                ComboBox {
                    model: root.blendModeNames
                    currentIndex: propsPanel.selSrcBlend
                    implicitHeight: 24; font.pixelSize: 11
                    Layout.fillWidth: true
                    onActivated: propsPanel.setSrcBlend(currentIndex)
                }
            }
            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "Dst:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 24 }
                ComboBox {
                    model: root.blendModeNames
                    currentIndex: propsPanel.selDstBlend
                    implicitHeight: 24; font.pixelSize: 11
                    Layout.fillWidth: true
                    onActivated: propsPanel.setDstBlend(currentIndex)
                }
            }

            // --- UV Mapping ---
            Label { text: "UV Mapping"; font.bold: true; color: palette.windowText; font.pixelSize: 11; topPadding: 4 }

            RowLayout {
                spacing: 2
                Layout.fillWidth: true
                Label { text: "Mode:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 32 }
                ComboBox {
                    id: uvModeCombo
                    model: ["Auto", "Interpolated", "Aligned", "Manual"]
                    readonly property var modeValues: ["auto", "interpolated", "aligned", "manual"]
                    currentIndex: {
                        var m = propsPanel.selUvMode;
                        var idx = modeValues.indexOf(m);
                        return idx >= 0 ? idx : 0;
                    }
                    implicitHeight: 24; font.pixelSize: 11
                    Layout.fillWidth: true
                    onActivated: propsPanel.setUvMode(modeValues[currentIndex])
                }
            }

            // Manual UV controls
            RowLayout {
                spacing: 2; visible: propsPanel.selUvMode === "manual"; Layout.fillWidth: true
                Label { text: "Ox:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 22 }
                Slider { from: -1; to: 1; stepSize: 0.01; value: propsPanel.selUvOffset[0]; Layout.fillWidth: true; onMoved: propsPanel.setUvOffset(value, propsPanel.selUvOffset[1]) }
            }
            RowLayout {
                spacing: 2; visible: propsPanel.selUvMode === "manual"; Layout.fillWidth: true
                Label { text: "Oy:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 22 }
                Slider { from: -1; to: 1; stepSize: 0.01; value: propsPanel.selUvOffset[1]; Layout.fillWidth: true; onMoved: propsPanel.setUvOffset(propsPanel.selUvOffset[0], value) }
            }
            RowLayout {
                spacing: 2; visible: propsPanel.selUvMode === "manual"; Layout.fillWidth: true
                Label { text: "Sx:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 22 }
                Slider { from: 0.1; to: 4.0; stepSize: 0.01; value: propsPanel.selUvScale[0]; Layout.fillWidth: true; onMoved: propsPanel.setUvScale(value, propsPanel.selUvScale[1]) }
            }
            RowLayout {
                spacing: 2; visible: propsPanel.selUvMode === "manual"; Layout.fillWidth: true
                Label { text: "Sy:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 22 }
                Slider { from: 0.1; to: 4.0; stepSize: 0.01; value: propsPanel.selUvScale[1]; Layout.fillWidth: true; onMoved: propsPanel.setUvScale(propsPanel.selUvScale[0], value) }
            }
            RowLayout {
                spacing: 2; visible: propsPanel.selUvMode === "manual"; Layout.fillWidth: true
                Label { text: "Rot:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 22 }
                Slider { from: -180; to: 180; stepSize: 1; value: propsPanel.selUvRotation; Layout.fillWidth: true; onMoved: propsPanel.setUvRotation(value) }
            }

            Item { Layout.fillHeight: true }
        }
    }
    }

    // Keyboard shortcuts
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape && root.drawingMode) {
            root.drawingMode = false;
            root.drawingPoints = [];
            root.stateVersion++;
            event.accepted = true;
            return;
        }
        if ((event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) && root.selectedRect >= 0) {
            root.deleteRect(root.selectedRect);
            event.accepted = true;
        } else if (event.key === Qt.Key_B && root.selectedRect >= 0) {
            root.toggleAllBezierEdges();
            event.accepted = true;
        } else if (root.selectedRect >= 0 && root.selectedRect < root.rects.length
                   && !root.isShapeLocked(root.selectedRect)
                   && (event.key === Qt.Key_Left || event.key === Qt.Key_Right
                       || event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
            var step = (event.modifiers & Qt.ShiftModifier) ? 0.05 : 0.01;
            var dx = 0, dy = 0;
            if (event.key === Qt.Key_Left)  dx = -step;
            if (event.key === Qt.Key_Right) dx =  step;
            if (event.key === Qt.Key_Up)    dy = -step;
            if (event.key === Qt.Key_Down)  dy =  step;
            var r = root.rects[root.selectedRect];
            for (var i = 0; i < r.vertices.length; i++) {
                r.vertices[i][0] += dx;
                r.vertices[i][1] += dy;
            }
            if (r.edges) {
                for (var i = 0; i < r.edges.length; i++) {
                    var e = r.edges[i];
                    if (e && e.cp1 && e.cp2) {
                        e.cp1[0] += dx; e.cp1[1] += dy;
                        e.cp2[0] += dx; e.cp2[1] += dy;
                    }
                }
            }
            root.stateVersion++;
            root.saveState("Move shape");
            root.sendLiveUpdate();
            event.accepted = true;
        }
    }
}
