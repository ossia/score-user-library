import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Score.ScriptUI {
    id: root
    anchors.fill: parent

    property var rects: []
    property int stateVersion: 0
    property int selectedRect: -1
    property bool isDragging: false
    property int dragCorner: -1 // -1 = move whole quad, 0-3 = corner index
    property real renderWidth: 0
    property real renderHeight: 0
    property var snapLinesX: []
    property var snapLinesY: []
    property bool snappingEnabled: true
    readonly property real snapThresholdPx: snappingEnabled ? 10 : 0

    // ---- State management ----

    loadState: function (state) {
        if (state && state.mapperState) {
            try {
                var s = typeof state.mapperState === "string" ? JSON.parse(state.mapperState) : state.mapperState;
                root.rects = root.loadRects(s);
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
                root.rects = root.loadRects(Array.isArray(s) ? s : []);
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

    function loadRects(data) {
        return data || [];
    }

    // ---- Naming helper ----

    function incrementName(name) {
        var m = name.match(/^(.*?)(\d+)$/);
        if (m)
            return m[1] + (parseInt(m[2]) + 1);
        return name + " 2";
    }

    // ---- Actions ----

    function saveState(actionName) {
        root.beginUpdateState(actionName || "Edit mapping");
        root.updateState("mapperState", JSON.stringify(root.rects));
        root.endUpdateState();
    }

    function sendLiveUpdate() {
        root.executionSend({
            type: "updateRects",
            rects: root.rects
        });
    }

    function addRect() {
        var offset = (rects.length % 5) * 0.05;
        var x0 = 0.1 + offset, y0 = 0.1 + offset;
        var x1 = 0.4 + offset, y1 = 0.4 + offset;
        rects.push({
            id: "rect-" + Date.now(),
            name: "Quad " + (rects.length + 1),
            corners: [[x0, y0], [x1, y0], [x1, y1], [x0, y1]],
            source: 0,
            blend: { top: 0, right: 0, bottom: 0, left: 0 },
            blendGamma: 1.0,
            srcBlend: 1,
            dstBlend: 7
        });
        selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Add quad");
        sendLiveUpdate();
    }

    function deleteRect(idx) {
        if (idx < 0 || idx >= rects.length)
            return;
        rects.splice(idx, 1);
        if (selectedRect >= rects.length)
            selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Delete quad");
        sendLiveUpdate();
    }

    function duplicateRect(idx) {
        if (idx < 0 || idx >= rects.length)
            return;
        var src = rects[idx];
        var nc = [];
        for (var i = 0; i < 4; i++)
            nc.push([src.corners[i][0] + 0.05, src.corners[i][1] + 0.05]);
        rects.push({
            id: "rect-" + Date.now(),
            name: incrementName(src.name),
            corners: nc,
            source: src.source,
            blend: src.blend ? JSON.parse(JSON.stringify(src.blend)) : { top: 0, right: 0, bottom: 0, left: 0 },
            blendGamma: src.blendGamma || 1.0,
            srcBlend: src.srcBlend !== undefined ? src.srcBlend : 1,
            dstBlend: src.dstBlend !== undefined ? src.dstBlend : 7
        });
        selectedRect = rects.length - 1;
        stateVersion++;
        saveState("Duplicate quad");
        sendLiveUpdate();
    }

    function moveRectUp(idx) {
        if (idx >= rects.length - 1)
            return;
        var tmp = rects[idx];
        rects[idx] = rects[idx + 1];
        rects[idx + 1] = tmp;
        selectedRect = idx + 1;
        stateVersion++;
        saveState("Reorder layers");
        sendLiveUpdate();
    }

    function moveRectDown(idx) {
        if (idx <= 0)
            return;
        var tmp = rects[idx];
        rects[idx] = rects[idx - 1];
        rects[idx - 1] = tmp;
        selectedRect = idx - 1;
        stateVersion++;
        saveState("Reorder layers");
        sendLiveUpdate();
    }

    // ---- Geometry helpers ----

    function quadCentroid(c) {
        return [(c[0][0] + c[1][0] + c[2][0] + c[3][0]) / 4,
                (c[0][1] + c[1][1] + c[2][1] + c[3][1]) / 4];
    }

    function pointInPolygon(px, py, pts) {
        if (!pts || pts.length < 3)
            return false;
        var inside = false;
        for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
            var xi = pts[i][0], yi = pts[i][1];
            var xj = pts[j][0], yj = pts[j][1];
            if (((yi > py) !== (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi))
                inside = !inside;
        }
        return inside;
    }

    // ---- Snapping ----

    function getSnapTargets(excludeIdx) {
        var tx = [0, 1], ty = [0, 1];
        for (var i = 0; i < rects.length; i++) {
            if (i === excludeIdx)
                continue;
            var c = rects[i].corners;
            for (var j = 0; j < 4; j++) {
                tx.push(c[j][0]);
                ty.push(c[j][1]);
            }
        }
        return {x: tx, y: ty};
    }

    function nearestSnap(val, targets) {
        var best = val, bestDist = Infinity;
        for (var i = 0; i < targets.length; i++) {
            var d = Math.abs(val - targets[i]);
            if (d < bestDist) {
                bestDist = d;
                best = targets[i];
            }
        }
        return {value: best, dist: bestDist};
    }

    function snapCorner(nx, ny, excludeIdx) {
        if (!snappingEnabled) {
            snapLinesX = [];
            snapLinesY = [];
            return [nx, ny];
        }
        var thX = snapThresholdPx / viewport.width;
        var thY = snapThresholdPx / viewport.height;
        var targets = getSnapTargets(excludeIdx);
        var sX = nearestSnap(nx, targets.x);
        var sY = nearestSnap(ny, targets.y);
        var lx = [], ly = [];
        if (sX.dist <= thX) {
            nx = sX.value;
            lx.push(sX.value);
        }
        if (sY.dist <= thY) {
            ny = sY.value;
            ly.push(sY.value);
        }
        snapLinesX = lx;
        snapLinesY = ly;
        return [nx, ny];
    }

    function snapQuadMove(origCorners, dx, dy, excludeIdx) {
        if (!snappingEnabled) {
            snapLinesX = [];
            snapLinesY = [];
            return {dx: dx, dy: dy};
        }
        var thX = snapThresholdPx / viewport.width;
        var thY = snapThresholdPx / viewport.height;
        var targets = getSnapTargets(excludeIdx);

        var bestSnapDx = 0, bestDistX = thX + 1;
        var bestSnapDy = 0, bestDistY = thY + 1;

        for (var i = 0; i < 4; i++) {
            var cx = origCorners[i][0] + dx;
            var cy = origCorners[i][1] + dy;
            var sX = nearestSnap(cx, targets.x);
            if (sX.dist < bestDistX) {
                bestDistX = sX.dist;
                bestSnapDx = sX.value - cx;
            }
            var sY = nearestSnap(cy, targets.y);
            if (sY.dist < bestDistY) {
                bestDistY = sY.dist;
                bestSnapDy = sY.value - cy;
            }
        }

        if (bestDistX <= thX)
            dx += bestSnapDx;
        if (bestDistY <= thY)
            dy += bestSnapDy;

        // Compute snap guide lines
        var lx = [], ly = [];
        for (var i = 0; i < 4; i++) {
            var sX2 = nearestSnap(origCorners[i][0] + dx, targets.x);
            if (sX2.dist < 0.001)
                lx.push(sX2.value);
            var sY2 = nearestSnap(origCorners[i][1] + dy, targets.y);
            if (sY2.dist < 0.001)
                ly.push(sY2.value);
        }
        snapLinesX = lx;
        snapLinesY = ly;
        return {dx: dx, dy: dy};
    }

    function clearSnap() {
        snapLinesX = [];
        snapLinesY = [];
    }

    // ---- Rotation helper ----

    function rotateCorners(corners, centroid, angle) {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        var result = [];
        for (var i = 0; i < 4; i++) {
            var dx = corners[i][0] - centroid[0];
            var dy = corners[i][1] - centroid[1];
            result.push([centroid[0] + dx * cos - dy * sin,
                         centroid[1] + dx * sin + dy * cos]);
        }
        return result;
    }

    // ---- Info display ----

    function formatInfo(rd) {
        if (!rd || !rd.corners)
            return "";
        var ct = quadCentroid(rd.corners);
        if (renderWidth > 0 && renderHeight > 0) {
            var px = Math.round(ct[0] * renderWidth);
            var py = Math.round(ct[1] * renderHeight);
            return "(" + px + ", " + py + ")";
        }
        return "(" + ct[0].toFixed(2) + ", " + ct[1].toFixed(2) + ")";
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
    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // ---- Left Panel ----
        ColumnLayout {
            Layout.preferredWidth: 200
            Layout.minimumWidth: 100
            Layout.maximumWidth: 150
            Layout.fillHeight: true
            spacing: 4

            Button {
                text: "+ Add Quad"
                Layout.fillWidth: true
                onClicked: root.addRect()
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
                                        root.saveState("Rename quad");
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

                        RowLayout {
                            spacing: 4
                            Label {
                                text: "Source:"
                                color: palette.windowText
                                font.pixelSize: 11
                            }
                            ComboBox {
                                model: ["Tex 1", "Tex 2", "Tex 3", "Tex 4", "Tex 5", "Tex 6", "Tex 7", "Tex 8"]
                                currentIndex: listDel.rd ? listDel.rd.source : 0
                                implicitWidth: 90
                                implicitHeight: 24
                                font.pixelSize: 11
                                onActivated: {
                                    root.rects[listDel.delIndex].source = currentIndex;
                                    root.stateVersion++;
                                    root.saveState("Change source");
                                    root.sendLiveUpdate();
                                }
                            }
                        }
                    }
                }
            }

            // ---- Edge Blend controls for selected quad ----
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                visible: root.selectedRect >= 0 && root.selectedRect < root.rects.length

                property var selBlend: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return null;
                    return root.rects[root.selectedRect].blend || { top: 0, right: 0, bottom: 0, left: 0 };
                }
                property real selGamma: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return 1.0;
                    return root.rects[root.selectedRect].blendGamma || 1.0;
                }
                property int selSrcBlend: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return 1;
                    var v = root.rects[root.selectedRect].srcBlend;
                    return (typeof v === 'number') ? v : 1;
                }
                property int selDstBlend: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length) return 7;
                    var v = root.rects[root.selectedRect].dstBlend;
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

                Label { text: "Edge Blend"; font.bold: true; color: palette.windowText; font.pixelSize: 11 }

                RowLayout {
                    spacing: 2
                    Label { text: "T:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                    Slider { from: 0; to: 0.5; stepSize: 0.01; value: parent.parent.selBlend ? parent.parent.selBlend.top : 0; Layout.fillWidth: true; onMoved: parent.parent.setBlendEdge("top", value) }
                }
                RowLayout {
                    spacing: 2
                    Label { text: "B:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                    Slider { from: 0; to: 0.5; stepSize: 0.01; value: parent.parent.selBlend ? parent.parent.selBlend.bottom : 0; Layout.fillWidth: true; onMoved: parent.parent.setBlendEdge("bottom", value) }
                }
                RowLayout {
                    spacing: 2
                    Label { text: "L:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                    Slider { from: 0; to: 0.5; stepSize: 0.01; value: parent.parent.selBlend ? parent.parent.selBlend.left : 0; Layout.fillWidth: true; onMoved: parent.parent.setBlendEdge("left", value) }
                }
                RowLayout {
                    spacing: 2
                    Label { text: "R:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                    Slider { from: 0; to: 0.5; stepSize: 0.01; value: parent.parent.selBlend ? parent.parent.selBlend.right : 0; Layout.fillWidth: true; onMoved: parent.parent.setBlendEdge("right", value) }
                }
                RowLayout {
                    spacing: 2
                    Label { text: "γ:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 14 }
                    Slider { from: 0.5; to: 4.0; stepSize: 0.1; value: parent.parent.selGamma; Layout.fillWidth: true; onMoved: parent.parent.setGamma(value) }
                }

                Label { text: "Blend Mode"; font.bold: true; color: palette.windowText; font.pixelSize: 11; topPadding: 4 }

                RowLayout {
                    spacing: 2
                    Label { text: "Src:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 24 }
                    ComboBox {
                        model: root.blendModeNames
                        currentIndex: parent.parent.selSrcBlend
                        implicitHeight: 24
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        onActivated: parent.parent.setSrcBlend(currentIndex)
                    }
                }
                RowLayout {
                    spacing: 2
                    Label { text: "Dst:"; color: palette.windowText; font.pixelSize: 10; Layout.preferredWidth: 24 }
                    ComboBox {
                        model: root.blendModeNames
                        currentIndex: parent.parent.selDstBlend
                        implicitHeight: 24
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        onActivated: parent.parent.setDstBlend(currentIndex)
                    }
                }
            }

            CheckBox {
                text: "Snap"
                checked: root.snappingEnabled
                onToggled: root.snappingEnabled = checked
            }
        }

        // ---- Separator ----
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: palette.mid
        }

        // ---- Right Panel: viewport ----
        Item {
            id: viewport
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                        ctx.beginPath();
                        ctx.moveTo(x, 0);
                        ctx.lineTo(x, height);
                        ctx.stroke();
                    }
                    for (var y = step; y < height; y += step) {
                        ctx.beginPath();
                        ctx.moveTo(0, y);
                        ctx.lineTo(width, y);
                        ctx.stroke();
                    }
                }
            }

            // Quad overlay canvas
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
                        var c = r.corners;
                        if (!c || c.length < 4)
                            continue;

                        var isSelected = (qi === root.selectedRect);

                        // Fill
                        ctx.fillStyle = root.sourceColors[r.source];
                        ctx.beginPath();
                        ctx.moveTo(c[0][0] * w, c[0][1] * h);
                        ctx.lineTo(c[1][0] * w, c[1][1] * h);
                        ctx.lineTo(c[2][0] * w, c[2][1] * h);
                        ctx.lineTo(c[3][0] * w, c[3][1] * h);
                        ctx.closePath();
                        ctx.fill();

                        // Border
                        ctx.strokeStyle = isSelected ? "white" : root.sourceBorderColors[r.source];
                        ctx.lineWidth = isSelected ? 2 : 1;
                        ctx.stroke();

                        // Label at centroid
                        var ct = root.quadCentroid(c);
                        var cx = ct[0] * w, cy = ct[1] * h;
                        var label;
                        if (root.isDragging && isSelected)
                            label = root.formatInfo(r);
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
                    }
                }
            }

            // Corner handles for selected quad
            Repeater {
                model: root.selectedRect >= 0 && root.selectedRect < root.rects.length ? 4 : 0

                Rectangle {
                    id: cornerHandle
                    property int ci: index
                    property var corner: {
                        root.stateVersion;
                        if (root.selectedRect < 0 || root.selectedRect >= root.rects.length)
                            return [0, 0];
                        return root.rects[root.selectedRect].corners[ci];
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

                    // Corner index label
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
                        cursorShape: Qt.CrossCursor

                        property real startX
                        property real startY
                        property real origCX
                        property real origCY

                        onPressed: function (mouse) {
                            root.isDragging = true;
                            root.dragCorner = cornerHandle.ci;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            startX = p.x;
                            startY = p.y;
                            var c = root.rects[root.selectedRect].corners[cornerHandle.ci];
                            origCX = c[0];
                            origCY = c[1];
                            root.beginUpdateState("Move corner");
                        }

                        onPositionChanged: function (mouse) {
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var nx = origCX + (p.x - startX) / viewport.width;
                            var ny = origCY + (p.y - startY) / viewport.height;
                            var snapped = root.snapCorner(nx, ny, root.selectedRect);
                            root.rects[root.selectedRect].corners[cornerHandle.ci] = snapped;
                            root.stateVersion++;
                            root.sendLiveUpdate();
                        }

                        onReleased: {
                            root.isDragging = false;
                            root.dragCorner = -1;
                            root.clearSnap();
                            root.updateState("mapperState", JSON.stringify(root.rects));
                            root.endUpdateState();
                        }
                    }
                }
            }

            // Rotation handle for selected quad
            Item {
                id: rotHandle
                visible: root.selectedRect >= 0 && root.selectedRect < root.rects.length
                z: 10

                property var topCenter: {
                    root.stateVersion;
                    if (root.selectedRect < 0 || root.selectedRect >= root.rects.length)
                        return [0.5, 0.5];
                    var c = root.rects[root.selectedRect].corners;
                    return [(c[0][0] + c[1][0]) / 2, (c[0][1] + c[1][1]) / 2];
                }
                readonly property real handleOffset: 25
                property real hx: topCenter[0] * viewport.width
                property real hy: topCenter[1] * viewport.height - handleOffset

                // Connecting line
                Rectangle {
                    x: rotHandle.hx - 0.5
                    y: rotHandle.hy + 5
                    width: 1
                    height: rotHandle.handleOffset - 5
                    color: palette.buttonText
                    opacity: 0.5
                }

                // Handle circle
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
                        cursorShape: Qt.ClosedHandCursor

                        property real startAngle
                        property var origCorners

                        onPressed: function (mouse) {
                            root.isDragging = true;
                            var ct = root.quadCentroid(root.rects[root.selectedRect].corners);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cx = ct[0] * viewport.width;
                            var cy = ct[1] * viewport.height;
                            startAngle = Math.atan2(p.y - cy, p.x - cx);
                            origCorners = JSON.parse(JSON.stringify(root.rects[root.selectedRect].corners));
                            root.beginUpdateState("Rotate quad");
                        }

                        onPositionChanged: function (mouse) {
                            var ct = root.quadCentroid(origCorners);
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var cx = ct[0] * viewport.width;
                            var cy = ct[1] * viewport.height;
                            var angle = Math.atan2(p.y - cy, p.x - cx) - startAngle;
                            root.rects[root.selectedRect].corners = root.rotateCorners(origCorners, ct, angle);
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

            // Background MouseArea: selection, deselection, move-drag
            MouseArea {
                anchors.fill: parent
                z: -1

                property int dragMode: 0 // 0=none, 1=move
                property real startX
                property real startY
                property var origCorners: null
                property bool wantsAltDup: false
                property bool didDuplicate: false
                property int hitSrcIdx: -1

                onPressed: function (mouse) {
                    root.forceActiveFocus();
                    var nx = mouse.x / viewport.width;
                    var ny = mouse.y / viewport.height;
                    wantsAltDup = false;
                    didDuplicate = false;
                    hitSrcIdx = -1;

                    // Hit test quads (top to bottom = last to first)
                    var hitIdx = -1;
                    for (var i = root.rects.length - 1; i >= 0; i--) {
                        if (root.pointInPolygon(nx, ny, root.rects[i].corners)) {
                            hitIdx = i;
                            break;
                        }
                    }

                    if (hitIdx >= 0) {
                        wantsAltDup = !!(mouse.modifiers & Qt.AltModifier);
                        hitSrcIdx = hitIdx;
                        root.selectedRect = hitIdx;
                        dragMode = 1;
                        root.isDragging = true;
                        root.dragCorner = -1;
                        startX = mouse.x;
                        startY = mouse.y;
                        origCorners = JSON.parse(JSON.stringify(root.rects[hitIdx].corners));
                        root.beginUpdateState(wantsAltDup ? "Duplicate quad" : "Move quad");
                    } else {
                        root.selectedRect = -1;
                        dragMode = 0;
                    }
                }

                onPositionChanged: function (mouse) {
                    if (dragMode !== 1)
                        return;

                    // Deferred alt+duplicate: create copy on first drag movement
                    if (wantsAltDup && !didDuplicate) {
                        var src = root.rects[hitSrcIdx];
                        root.rects.push({
                            id: "rect-" + Date.now(),
                            name: root.incrementName(src.name),
                            corners: JSON.parse(JSON.stringify(origCorners)),
                            source: src.source,
                            blend: src.blend ? JSON.parse(JSON.stringify(src.blend)) : { top: 0, right: 0, bottom: 0, left: 0 },
                            blendGamma: src.blendGamma || 1.0,
                            srcBlend: src.srcBlend !== undefined ? src.srcBlend : 1,
                            dstBlend: src.dstBlend !== undefined ? src.dstBlend : 7
                        });
                        root.selectedRect = root.rects.length - 1;
                        didDuplicate = true;
                        root.stateVersion++;
                    }

                    var dx = (mouse.x - startX) / viewport.width;
                    var dy = (mouse.y - startY) / viewport.height;
                    var snapped = root.snapQuadMove(origCorners, dx, dy, root.selectedRect);
                    var r = root.rects[root.selectedRect];
                    for (var i = 0; i < 4; i++) {
                        r.corners[i] = [origCorners[i][0] + snapped.dx,
                                        origCorners[i][1] + snapped.dy];
                    }
                    root.stateVersion++;
                    root.sendLiveUpdate();
                }

                onReleased: {
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
    }
    }

    // Keyboard shortcuts
    Keys.onPressed: function (event) {
        if ((event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) && root.selectedRect >= 0) {
            root.deleteRect(root.selectedRect);
            event.accepted = true;
        } else if (root.selectedRect >= 0 && root.selectedRect < root.rects.length
                   && (event.key === Qt.Key_Left || event.key === Qt.Key_Right
                       || event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
            var step = (event.modifiers & Qt.ShiftModifier) ? 0.05 : 0.01;
            var dx = 0, dy = 0;
            if (event.key === Qt.Key_Left)  dx = -step;
            if (event.key === Qt.Key_Right) dx =  step;
            if (event.key === Qt.Key_Up)    dy = -step;
            if (event.key === Qt.Key_Down)  dy =  step;
            var r = root.rects[root.selectedRect];
            for (var i = 0; i < 4; i++) {
                r.corners[i][0] += dx;
                r.corners[i][1] += dy;
            }
            root.stateVersion++;
            root.saveState("Move quad");
            root.sendLiveUpdate();
            event.accepted = true;
        }
    }
}
