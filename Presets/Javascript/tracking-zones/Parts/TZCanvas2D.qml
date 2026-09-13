import QtQuick
import QtQuick.Controls
import "Geometry.js" as Geom
import "Model.js" as Model
import "UiUtil.js" as U
import OssiaUI as S

// Top-down 2D editor: grid, backdrop, zones, handles, live entities, tools.
Item {
    id: view
    property var owner
    clip: true

    // view transform: world metres -> screen pixels (y up)
    property real ppm: 60
    property real cx: 0
    property real cy: 0
    function w2sx(x) { return width / 2 + (x - cx) * ppm; }
    function w2sy(y) { return height / 2 - (y - cy) * ppm; }
    function s2wx(sx) { return cx + (sx - width / 2) / ppm; }
    function s2wy(sy) { return cy - (sy - height / 2) / ppm; }
    function snap(v) { return (owner.snapping && !snapOverride) ? U.snapValue(v, owner.gridStep) : v; }
    property bool snapOverride: false

    // interaction state
    property string mode: ""            // pan | move | handle | draw | poly | simdrag | marquee
    property var pressW: [0, 0]
    property var pressS: [0, 0]
    property var lastW: [0, 0]
    property var dragStartPos: null     // primary zone pos at press
    property var dragStartPositions: ({})
    property var activeHandle: null
    property var drawPoints: []         // polygon/path points in world
    property var drawCurrent: null      // current mouse world pos while drawing
    property var previewShape: null     // {type, x0,y0,x1,y1}
    property var marquee: null
    property var hoverW: [0, 0]
    property string hoverZone: ""
    property string simDragId: ""

    function fitAll() {
        var zs = owner.doc.zones; if (!zs.length) { cx = 0; cy = 0; ppm = 60; staticLayer.requestPaint(); return; }
        var b = [Infinity, Infinity, -Infinity, -Infinity];
        for (var i = 0; i < zs.length; i++) { var zb = U.zoneWorldBounds(zs[i]); if (!isFinite(zb[0])) continue; b[0] = Math.min(b[0], zb[0]); b[1] = Math.min(b[1], zb[1]); b[2] = Math.max(b[2], zb[2]); b[3] = Math.max(b[3], zb[3]); }
        if (!isFinite(b[0])) return;
        cx = (b[0] + b[2]) / 2; cy = (b[1] + b[3]) / 2;
        var w = Math.max(1, b[2] - b[0]), h = Math.max(1, b[3] - b[1]);
        ppm = Math.max(5, Math.min(400, Math.min((width - 60) / w, (height - 60) / h)));
        staticLayer.requestPaint(); dynLayer.requestPaint();
    }
    function cancelDrawing() { drawPoints = []; previewShape = null; mode = ""; staticLayer.requestPaint(); }

    function zoneState(id) { var zs = owner.zoneStates; return zs ? (zs[id] || null) : null; }

    Connections { target: owner; function onDocVersionChanged() { staticLayer.requestPaint(); } function onSelectionChanged() { staticLayer.requestPaint(); } function onGridStepChanged() { staticLayer.requestPaint(); } function onShowVelocityChanged() { dynLayer.requestPaint(); } function onSnapshotChanged() { dynLayer.requestPaint(); } function onSimVersionChanged() { dynLayer.requestPaint(); } function onToolChanged() { view.cancelDrawing(); } function onShowHeatChanged() { dynLayer.requestPaint(); } function onShowLabelsChanged() { staticLayer.requestPaint(); dynLayer.requestPaint(); } }
    onPpmChanged: { staticLayer.requestPaint(); dynLayer.requestPaint(); }
    onCxChanged: { staticLayer.requestPaint(); dynLayer.requestPaint(); }
    onCyChanged: { staticLayer.requestPaint(); dynLayer.requestPaint(); }
    onWidthChanged: { staticLayer.requestPaint(); dynLayer.requestPaint(); }
    onHeightChanged: { staticLayer.requestPaint(); dynLayer.requestPaint(); }

    Rectangle { anchors.fill: parent; color: "#141312" }

    // backdrop image
    Image {
        id: backdrop
        property var bd: { owner.docVersion; return owner.doc.settings.backdrop; }
        source: owner.floorPlanUrl
        visible: status === Image.Ready && bd && bd.path
        opacity: bd ? bd.opacity : 0.5
        x: bd ? view.w2sx(bd.x - bd.w / 2) : 0
        y: bd ? view.w2sy(bd.y + bd.h / 2) : 0
        width: bd ? bd.w * view.ppm : 0
        height: bd ? bd.h * view.ppm : 0
        rotation: bd ? -(bd.rotation || 0) : 0
        fillMode: Image.Stretch
        asynchronous: true
    }

    // ---------------- static layer: grid + zones + handles ----------------
    Canvas {
        id: staticLayer
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var w0 = Date.now();
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            drawGrid(ctx);
            var zs = owner.doc.zones;
            for (var i = 0; i < zs.length; i++) if (zs[i].visible !== false) drawZone(ctx, zs[i], false);
            // selection on top
            for (var j = 0; j < zs.length; j++) if (owner.isSelected(zs[j].id) && zs[j].visible !== false) drawZone(ctx, zs[j], true);
            if (owner.selection.length === 1) drawHandles(ctx, owner.selectedZone);
            drawPreview(ctx);
            drawMarquee(ctx);
            // sim bounds
            if (owner.tool === "sim" || owner.bottomTab === 1) {
                var b = owner.simBounds; ctx.save(); ctx.setLineDash([4, 4]); ctx.strokeStyle = "rgba(122,211,255,0.35)"; ctx.lineWidth = 1;
                ctx.strokeRect(w2sx(b.x - b.w / 2), w2sy(b.y + b.h / 2), b.w * ppm, b.h * ppm); ctx.restore();
            }
            owner.perfAcc.paintStaticMs += Date.now() - w0; owner.perfAcc.paintStaticN++;
        }

        function drawGrid(ctx) {
            var step = owner.gridStep > 0 ? owner.gridStep : 1;
            var pxStep = step * ppm;
            var major = 1;
            while (pxStep < 14) { step *= 2; pxStep = step * ppm; }
            var x0 = s2wx(0), x1 = s2wx(width), y0 = s2wy(height), y1 = s2wy(0);
            ctx.lineWidth = 1;
            var gx0 = Math.floor(x0 / step) * step;
            for (var x = gx0; x <= x1; x += step) {
                var sx = Math.round(w2sx(x)) + 0.5; var isM = Math.abs(x / major - Math.round(x / major)) < 1e-6;
                ctx.strokeStyle = isM ? "rgba(255,255,255,0.10)" : "rgba(255,255,255,0.04)";
                ctx.beginPath(); ctx.moveTo(sx, 0); ctx.lineTo(sx, height); ctx.stroke();
            }
            var gy0 = Math.floor(y0 / step) * step;
            for (var y = gy0; y <= y1; y += step) {
                var sy = Math.round(w2sy(y)) + 0.5; var isM2 = Math.abs(y / major - Math.round(y / major)) < 1e-6;
                ctx.strokeStyle = isM2 ? "rgba(255,255,255,0.10)" : "rgba(255,255,255,0.04)";
                ctx.beginPath(); ctx.moveTo(0, sy); ctx.lineTo(width, sy); ctx.stroke();
            }
            // axes
            ctx.strokeStyle = "rgba(255,90,90,0.5)"; ctx.beginPath(); ctx.moveTo(w2sx(0), w2sy(0)); ctx.lineTo(w2sx(0) + 30, w2sy(0)); ctx.stroke();
            ctx.strokeStyle = "rgba(90,255,120,0.5)"; ctx.beginPath(); ctx.moveTo(w2sx(0), w2sy(0)); ctx.lineTo(w2sx(0), w2sy(0) - 30); ctx.stroke();
            ctx.fillStyle = "rgba(255,255,255,0.35)"; ctx.font = "10px sans-serif";
            ctx.fillText("x", w2sx(0) + 33, w2sy(0) + 3); ctx.fillText("y", w2sx(0) - 8, w2sy(0) - 32);
            // scale bar
            var barM = step * 2; var barPx = barM * ppm;
            ctx.fillStyle = "rgba(255,255,255,0.5)"; ctx.fillRect(12, height - 18, barPx, 2); ctx.fillText(barM + " m", 12, height - 22);
            // labels on major lines (every 1 m or more)
            var lab = step; while (lab * ppm < 50) lab *= 2;
            ctx.fillStyle = "rgba(255,255,255,0.25)";
            for (var lx = Math.floor(x0 / lab) * lab; lx <= x1; lx += lab) ctx.fillText((Math.round(lx * 100) / 100) + "", w2sx(lx) + 2, height - 4);
            for (var ly = Math.floor(y0 / lab) * lab; ly <= y1; ly += lab) ctx.fillText((Math.round(ly * 100) / 100) + "", 2, w2sy(ly) - 2);
        }

        function beginLocal(ctx, z) {
            ctx.save();
            ctx.translate(w2sx(z.pos[0]), w2sy(z.pos[1]));
            ctx.rotate(-(z.rot ? z.rot[2] : 0) * Math.PI / 180);
            ctx.scale(ppm, -ppm);
        }
        function tracePath(ctx, s) {
            switch (s.type) {
            case "rect": case "box": ctx.rect(-(s.w || 1) / 2, -(s.h || 1) / 2, s.w || 1, s.h || 1); break;
            case "circle": case "sphere": case "cylinder": {
                var rx = s.rx || s.r || 1, ry = s.ry || s.r || rx;
                ctx.save(); ctx.scale(rx, ry); ctx.arc(0, 0, 1, 0, Math.PI * 2); ctx.restore(); break;
            }
            case "polygon": case "prism": { var p = s.points || []; if (!p.length) break; ctx.moveTo(p[0][0], p[0][1]); for (var i = 1; i < p.length; i++) ctx.lineTo(p[i][0], p[i][1]); ctx.closePath(); break; }
            case "path": { var q = s.points || []; if (!q.length) break; ctx.moveTo(q[0][0], q[0][1]); for (var j = 1; j < q.length; j++) ctx.lineTo(q[j][0], q[j][1]); break; }
            case "line": { var l = s.points || [[-1, 0], [1, 0]]; ctx.moveTo(l[0][0], l[0][1]); ctx.lineTo(l[1][0], l[1][1]); break; }
            }
        }

        function drawZone(ctx, z, selected) {
            var s = z.shape;
            var st = view.zoneState(z.id);
            var occ = st && st.occupied;
            var active = st ? st.active !== false : z.enabled;
            var col = z.color || "#2bb3a3";
            var alphaFill = z.enabled === false ? 0.05 : (occ ? 0.42 : 0.16);
            if (z.role === "exclude") col = "#d96b6b"; else if (z.role === "include") col = "#7fc45a";
            beginLocal(ctx, z);
            ctx.lineWidth = (selected ? 2.5 : 1.5) / ppm;
            var isLine = s.type === "line", isPath = s.type === "path";
            if (isPath) {
                ctx.beginPath(); tracePath(ctx, s);
                ctx.lineCap = "round"; ctx.lineJoin = "round";
                ctx.strokeStyle = U.withAlpha(col, occ ? 0.45 : 0.2); ctx.lineWidth = (s.width || 1); ctx.stroke();
                ctx.beginPath(); tracePath(ctx, s); ctx.lineWidth = (selected ? 2.5 : 1.5) / ppm; ctx.strokeStyle = selected ? "#ffffff" : col; if (!active) ctx.setLineDash([6 / ppm, 6 / ppm]); ctx.stroke();
                // progress ticks
                ctx.fillStyle = U.withAlpha(col, 0.8); var p0 = s.points[0]; ctx.beginPath(); ctx.arc(p0[0], p0[1], 4 / ppm, 0, 7); ctx.fill();
            } else if (isLine) {
                var a = s.points[0], b = s.points[1];
                ctx.beginPath(); tracePath(ctx, s);
                ctx.strokeStyle = U.withAlpha(col, 0.25); ctx.lineWidth = Math.max(s.width || 0.1, 6 / ppm); ctx.lineCap = "butt"; ctx.stroke();
                ctx.beginPath(); tracePath(ctx, s); ctx.lineWidth = (selected ? 3 : 2) / ppm; ctx.strokeStyle = selected ? "#ffffff" : col; if (!active) ctx.setLineDash([6 / ppm, 6 / ppm]); ctx.stroke();
                ctx.setLineDash([]);
                // direction arrows (left of a->b = in)
                var mx = (a[0] + b[0]) / 2, my = (a[1] + b[1]) / 2; var dx = b[0] - a[0], dy = b[1] - a[1]; var L = Math.sqrt(dx * dx + dy * dy) || 1; var nx = -dy / L, ny = dx / L;
                var al = 0.45; ctx.fillStyle = col; ctx.strokeStyle = col; ctx.lineWidth = 2 / ppm;
                function arrow(sign) { var ex = mx + nx * al * sign, ey = my + ny * al * sign; ctx.beginPath(); ctx.moveTo(mx, my); ctx.lineTo(ex, ey); ctx.stroke(); var hx = ex - nx * 0.15 * sign, hy = ey - ny * 0.15 * sign; ctx.beginPath(); ctx.moveTo(ex, ey); ctx.lineTo(hx + (dx / L) * 0.1, hy + (dy / L) * 0.1); ctx.lineTo(hx - (dx / L) * 0.1, hy - (dy / L) * 0.1); ctx.closePath(); ctx.fill(); }
                if (s.direction === "a_to_b" || s.direction === "both") arrow(1);
                if (s.direction === "b_to_a" || s.direction === "both") arrow(-1);
                // A/B marks
                ctx.fillStyle = "#ffffff"; ctx.beginPath(); ctx.arc(a[0], a[1], 3 / ppm, 0, 7); ctx.fill(); ctx.beginPath(); ctx.arc(b[0], b[1], 3 / ppm, 0, 7); ctx.fill();
            } else {
                ctx.beginPath(); tracePath(ctx, s);
                ctx.fillStyle = U.withAlpha(col, alphaFill); ctx.fill();
                if (z.role === "exclude") { ctx.save(); ctx.clip(); ctx.strokeStyle = U.withAlpha(col, 0.35); ctx.lineWidth = 1 / ppm; var bb = Geom.shapeBounds(s); for (var hx2 = bb[0] - (bb[4] - bb[1]); hx2 < bb[3]; hx2 += 0.3) { ctx.beginPath(); ctx.moveTo(hx2, bb[1]); ctx.lineTo(hx2 + (bb[4] - bb[1]), bb[4]); ctx.stroke(); } ctx.restore(); }
                ctx.strokeStyle = selected ? "#ffffff" : col;
                if (!active) ctx.setLineDash([6 / ppm, 6 / ppm]); else if (z.locked) ctx.setLineDash([2 / ppm, 3 / ppm]);
                ctx.stroke(); ctx.setLineDash([]);
                // hysteresis band
                if (selected && z.hysteresis && z.hysteresis.margin > 0 && (s.type === "rect" || s.type === "circle" || s.type === "box" || s.type === "sphere" || s.type === "cylinder")) {
                    ctx.beginPath(); var m = z.hysteresis.margin;
                    if (s.type === "rect" || s.type === "box") ctx.rect(-(s.w || 1) / 2 - m, -(s.h || 1) / 2 - m, (s.w || 1) + 2 * m, (s.h || 1) + 2 * m);
                    else { var rr = (s.r || s.rx || 1) + m; ctx.arc(0, 0, rr, 0, 7); }
                    ctx.strokeStyle = "rgba(255,255,255,0.25)"; ctx.setLineDash([3 / ppm, 3 / ppm]); ctx.lineWidth = 1 / ppm; ctx.stroke(); ctx.setLineDash([]);
                }
                // anchor indicator (frame attach)
                if (z.frame === "entity") { ctx.fillStyle = "rgba(255,255,255,0.5)"; ctx.beginPath(); ctx.arc(0, 0, 3 / ppm, 0, 7); ctx.fill(); }
            }
            ctx.restore();
            // labels (screen space)
            if (owner.showLabels) {
                var c = labelPos(z);
                ctx.save();
                ctx.font = (selected ? "bold " : "") + "11px sans-serif";
                var nm = labelText(z);
                var tw = ctx.measureText(nm).width;
                ctx.fillStyle = "rgba(0,0,0,0.55)"; ctx.fillRect(c[0] - tw / 2 - 4, c[1] - 9, tw + 8, 15);
                ctx.fillStyle = z.enabled === false ? "#8a918d" : "#f0f3f1"; ctx.textAlign = "center"; ctx.fillText(nm, c[0], c[1] + 3);
                ctx.restore();
            }
        }
        function labelText(z) {
            var s = z.shape;
            return z.name + (Model.is3D(s) ? "  z " + (s.type === "box" || s.type === "sphere" || s.type === "cylinder" ? U.fmt(z.pos[2], 1) : (U.fmt(s.zmin, 1) + "-" + U.fmt(s.zmax, 1))) : "");
        }
        function labelPos(z) {
            var s = z.shape; var lx = 0, ly = 0;
            if (s.type === "polygon" || s.type === "prism") { var c = Geom.polygonCentroid(s.points || []); lx = c[0]; ly = c[1]; }
            else if (s.type === "path" || s.type === "line") { var p = s.points || []; if (p.length) { var m = p[Math.floor((p.length - 1) / 2)]; var n = p[Math.min(p.length - 1, Math.floor((p.length - 1) / 2) + 1)]; lx = (m[0] + n[0]) / 2; ly = (m[1] + n[1]) / 2; } }
            var f = U.zoneFrame(z); var w = Geom.toWorld(f, [lx, ly, 0]);
            return [w2sx(w[0]), w2sy(w[1]) - ((s.type === "line") ? 14 : 0)];
        }

        function drawHandles(ctx, z) {
            if (!z || z.locked || owner.showMode) return;
            var hs = U.zoneHandles(z); var f = U.zoneFrame(z);
            for (var i = 0; i < hs.length; i++) {
                var h = hs[i]; var w = Geom.toWorld(f, [h.x, h.y, 0]); var sx = w2sx(w[0]), sy = w2sy(w[1]);
                ctx.beginPath();
                if (h.kind === "rot") { ctx.arc(sx, sy, 5, 0, 7); ctx.fillStyle = "#ffd166"; ctx.fill(); var c = Geom.toWorld(f, [0, 0, 0]); ctx.strokeStyle = "rgba(255,209,102,0.5)"; ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(w2sx(c[0]), w2sy(c[1])); ctx.lineTo(sx, sy); ctx.stroke(); }
                else if (h.kind === "scale") { ctx.save(); ctx.translate(sx, sy); ctx.rotate(Math.PI / 4); ctx.rect(-4, -4, 8, 8); ctx.fillStyle = "#c58014"; ctx.fill(); ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 1.2; ctx.stroke(); ctx.restore(); }
                else if (h.kind === "mid") { ctx.arc(sx, sy, 3.5, 0, 7); ctx.fillStyle = "rgba(255,255,255,0.45)"; ctx.fill(); }
                else { ctx.rect(sx - 4, sy - 4, 8, 8); ctx.fillStyle = "#ffffff"; ctx.fill(); ctx.strokeStyle = "#c58014"; ctx.lineWidth = 1.5; ctx.stroke(); }
            }
            // z handle text for 3D
        }

        function drawPreview(ctx) {
            var ps = view.previewShape;
            if (ps) {
                ctx.save(); ctx.strokeStyle = "#ffffff"; ctx.setLineDash([5, 4]); ctx.lineWidth = 1.5; ctx.fillStyle = "rgba(255,255,255,0.08)";
                var x0 = w2sx(ps.x0), y0 = w2sy(ps.y0), x1 = w2sx(ps.x1), y1 = w2sy(ps.y1);
                ctx.beginPath();
                if (ps.type === "rect" || ps.type === "box") { ctx.rect(Math.min(x0, x1), Math.min(y0, y1), Math.abs(x1 - x0), Math.abs(y1 - y0)); ctx.fill(); ctx.stroke(); }
                else if (ps.type === "circle" || ps.type === "sphere" || ps.type === "cylinder") { var r = Math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)); ctx.arc(x0, y0, r, 0, 7); ctx.fill(); ctx.stroke(); }
                else if (ps.type === "line") { ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke(); }
                ctx.restore();
                ctx.fillStyle = "#ffffff"; ctx.font = "11px sans-serif";
                var wm = Math.abs(ps.x1 - ps.x0), hm = Math.abs(ps.y1 - ps.y0), rm = Math.sqrt(wm * wm + hm * hm);
                ctx.fillText(ps.type === "circle" || ps.type === "sphere" || ps.type === "cylinder" ? ("r " + U.fmt(rm)) : ps.type === "line" ? ("len " + U.fmt(rm)) : (U.fmt(wm) + " × " + U.fmt(hm)), x1 + 10, y1 - 10);
            }
            var dp = view.drawPoints;
            if (dp.length) {
                ctx.save(); ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 1.5; ctx.setLineDash([5, 4]);
                ctx.beginPath(); ctx.moveTo(w2sx(dp[0][0]), w2sy(dp[0][1]));
                for (var i = 1; i < dp.length; i++) ctx.lineTo(w2sx(dp[i][0]), w2sy(dp[i][1]));
                if (view.drawCurrent) ctx.lineTo(w2sx(view.drawCurrent[0]), w2sy(view.drawCurrent[1]));
                if (owner.tool === "polygon" && dp.length > 1) ctx.lineTo(w2sx(dp[0][0]), w2sy(dp[0][1]));
                ctx.stroke(); ctx.setLineDash([]);
                ctx.fillStyle = "#ffffff";
                for (var j = 0; j < dp.length; j++) { ctx.beginPath(); ctx.arc(w2sx(dp[j][0]), w2sy(dp[j][1]), 3.5, 0, 7); ctx.fill(); }
                // segment length readout
                if (view.drawCurrent) { var l = dp[dp.length - 1]; var d = Geom.dist2d([l[0], l[1], 0], [view.drawCurrent[0], view.drawCurrent[1], 0]); ctx.font = "11px sans-serif"; ctx.fillText(U.fmt(d) + " m", w2sx(view.drawCurrent[0]) + 10, w2sy(view.drawCurrent[1]) - 8); }
                // validity
                if (owner.tool === "polygon" && dp.length >= 4 && Geom.polygonSelfIntersects(dp)) { ctx.fillStyle = "#ff6b6b"; ctx.fillText("self-intersecting", w2sx(dp[0][0]), w2sy(dp[0][1]) - 12); }
                ctx.restore();
            }
        }
        function drawMarquee(ctx) {
            var m = view.marquee; if (!m) return;
            ctx.save(); ctx.strokeStyle = "rgba(255,255,255,0.7)"; ctx.fillStyle = "rgba(63,196,164,0.12)"; ctx.setLineDash([4, 3]);
            ctx.beginPath(); ctx.rect(Math.min(m[0], m[2]), Math.min(m[1], m[3]), Math.abs(m[2] - m[0]), Math.abs(m[3] - m[1])); ctx.fill(); ctx.stroke(); ctx.restore();
        }
    }

    // ---------------- dynamic layer: heat, trails, entities, badges ----------------
    Canvas {
        id: dynLayer
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var w0 = Date.now();
            var ctx = getContext("2d"); ctx.reset(); ctx.clearRect(0, 0, width, height);
            var snap = owner.snapshot;
            // heatmap
            if (owner.showHeat && snap && snap.heatmap && snap.heatmap.length && owner.doc.settings.heatmap.enabled) {
                var hm = owner.doc.settings.heatmap; var mx = 0; for (var q = 0; q < snap.heatmap.length; q++) if (snap.heatmap[q] > mx) mx = snap.heatmap[q];
                if (mx > 0) { var cw = hm.w / hm.cols, ch = hm.h / hm.rows;
                    for (var r = 0; r < hm.rows; r++) for (var c = 0; c < hm.cols; c++) { var v = snap.heatmap[r * hm.cols + c] / mx; if (v <= 0.01) continue; var wx = hm.x - hm.w / 2 + c * cw, wy = hm.y + hm.h / 2 - r * ch; ctx.fillStyle = "rgba(255," + Math.round(200 - 180 * v) + ",40," + (0.1 + 0.5 * v) + ")"; ctx.fillRect(w2sx(wx), w2sy(wy), cw * ppm, ch * ppm); } }
            }
            // zone badges (count / flash)
            if (snap && snap.zones) {
                var zs = owner.doc.zones; var byId = {}; for (var i = 0; i < snap.zones.length; i++) byId[snap.zones[i].id] = snap.zones[i];
                for (var j = 0; j < zs.length; j++) {
                    var z = zs[j]; var st = byId[z.id]; if (!st || z.visible === false) continue;
                    var lp = staticLayer.labelPos(z);
                    if (st.count > 0 || st.crossings_in || st.crossings_out) {
                        var txt = z.shape.type === "line" ? ("↑" + st.crossings_in + " ↓" + st.crossings_out) : (st.count + (st.dwell_now > 1 ? "  " + U.fmtTime(st.dwell_now) : ""));
                        ctx.font = "bold 11px sans-serif"; var tw = ctx.measureText(txt).width;
                        ctx.fillStyle = st.occupied ? (z.color || "#2bb3a3") : "rgba(120,120,120,0.8)"; ctx.beginPath(); ctx.roundedRect(lp[0] - tw / 2 - 6, lp[1] + 8, tw + 12, 15, 7, 7); ctx.fill();
                        ctx.fillStyle = "#0b0d0c"; ctx.textAlign = "center"; ctx.fillText(txt, lp[0], lp[1] + 19);
                    }
                    if (st.flash > 0 && snap.t - st.flash < 0.4) { ctx.strokeStyle = "rgba(255,255,255," + (1 - (snap.t - st.flash) / 0.4) + ")"; ctx.lineWidth = 3; staticLayer.beginLocal(ctx, z); ctx.lineWidth = 4 / ppm; ctx.beginPath(); staticLayer.tracePath(ctx, z.shape); ctx.stroke(); ctx.restore(); }
                }
            }
            // trails
            if (owner.showTrails) {
                var tr = owner.trails;
                for (var k in tr) { var a = tr[k]; if (a.length < 2) continue; ctx.strokeStyle = "rgba(255,255,255,0.18)"; ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(w2sx(a[0][0]), w2sy(a[0][1])); for (var n = 1; n < a.length; n++) ctx.lineTo(w2sx(a[n][0]), w2sy(a[n][1])); ctx.stroke(); }
            }
            // live entities
            if (snap && snap.entities && owner.liveData) {
                for (var e = 0; e < snap.entities.length; e++) {
                    var en = snap.entities[e]; var sx = w2sx(en.pos[0]), sy = w2sy(en.pos[1]);
                    var col = en.src === 4 ? "#ffffff" : U.srcColor(en.src);
                    if (en.masked) col = "#6f7a75";
                    // velocity
                    if (owner.showVelocity && en.vel && (Math.abs(en.vel[0]) + Math.abs(en.vel[1])) > 0.05) { ctx.strokeStyle = U.withAlpha(col === "#ffffff" ? "#ffffff" : col, 0.7); ctx.lineWidth = 1.5; ctx.beginPath(); ctx.moveTo(sx, sy); ctx.lineTo(sx + en.vel[0] * ppm * 0.5, sy - en.vel[1] * ppm * 0.5); ctx.stroke(); }
                    // keypoints
                    if (en.kps && owner.showKeypoints) { ctx.fillStyle = U.withAlpha(col, 0.6); for (var kp = 0; kp < en.kps.length; kp++) { var K = en.kps[kp]; if (K[3] < 0.2) continue; ctx.beginPath(); ctx.arc(w2sx(K[0]), w2sy(K[1]), 2, 0, 7); ctx.fill(); } }
                    ctx.beginPath(); ctx.arc(sx, sy, en.zones && en.zones.length ? 7 : 5.5, 0, 7);
                    ctx.fillStyle = col; ctx.fill();
                    if (en.zones && en.zones.length) { ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 2; ctx.stroke(); }
                    if (en.state === "lost") { ctx.strokeStyle = "rgba(255,255,255,0.5)"; ctx.setLineDash([2, 2]); ctx.beginPath(); ctx.arc(sx, sy, 10, 0, 7); ctx.stroke(); ctx.setLineDash([]); }
                    if (owner.showLabels) { ctx.fillStyle = "#ffffff"; ctx.font = "10px sans-serif"; ctx.textAlign = "left"; ctx.fillText((en.src === 4 ? "" : U.srcLabel(en.src) + ":") + en.id + (en.cls ? " " + en.cls : ""), sx + 9, sy - 6); }
                }
            }
            // simulator dummies (hollow rings = UI-side position)
            if (owner.simEnabled) {
                var sims = owner.simEntities;
                for (var s2 = 0; s2 < sims.length; s2++) { var se = sims[s2]; var ssx = w2sx(se.pos[0]), ssy = w2sy(se.pos[1]); ctx.strokeStyle = se.kind === "walker" ? "rgba(255,255,255,0.6)" : "#ffffff"; ctx.lineWidth = se.id === view.simDragId ? 3 : 1.5; ctx.setLineDash(se.kind === "walker" ? [2, 2] : []); ctx.beginPath(); ctx.arc(ssx, ssy, 9, 0, 7); ctx.stroke(); ctx.setLineDash([]); }
            }
            // hover coordinates
            ctx.fillStyle = "rgba(255,255,255,0.5)"; ctx.font = "10px sans-serif"; ctx.textAlign = "right";
            ctx.fillText(U.fmt(view.hoverW[0]) + ", " + U.fmt(view.hoverW[1]) + " m", width - 8, height - 6);
            owner.perfAcc.paintDynMs += Date.now() - w0; owner.perfAcc.paintDynN++;
        }
    }

    // ---------------- interaction ----------------
    function handleAt(sx, sy) {
        var z = owner.selectedZone; if (!z || owner.selection.length !== 1 || z.locked) return null;
        var hs = U.zoneHandles(z); var f = U.zoneFrame(z); var best = null, bd = 9;
        for (var i = 0; i < hs.length; i++) { var w = Geom.toWorld(f, [hs[i].x, hs[i].y, 0]); var d = Math.hypot(w2sx(w[0]) - sx, w2sy(w[1]) - sy); if (d < bd) { bd = d; best = hs[i]; } }
        return best;
    }
    function zoneAt(wx, wy) {
        var zs = owner.doc.zones; var tol = 6 / ppm;
        for (var i = zs.length - 1; i >= 0; i--) { var z = zs[i]; if (z.visible === false) continue; if (U.hitZone(z, wx, wy, tol)) return z; }
        return null;
    }
    function labelAt(sx, sy) {
        if (!owner.showLabels) return null;
        var ctx = staticLayer.getContext("2d"), zones = owner.doc.zones;
        for (var i = zones.length - 1; i >= 0; --i) {
            var zone = zones[i];
            if (zone.visible === false) continue;
            var p = staticLayer.labelPos(zone);
            ctx.font = (owner.isSelected(zone.id) ? "bold " : "") + "11px sans-serif";
            var halfWidth = ctx.measureText(staticLayer.labelText(zone)).width / 2 + 4;
            if (sx >= p[0] - halfWidth && sx <= p[0] + halfWidth && sy >= p[1] - 9 && sy <= p[1] + 6)
                return { zone: zone, x: p[0] - halfWidth, y: p[1] - 9, width: halfWidth * 2 };
        }
        return null;
    }
    function simAt(wx, wy) { var l = owner.simEntities; var tol = 12 / ppm; for (var i = l.length - 1; i >= 0; i--) if (Geom.dist2d(l[i].pos, [wx, wy, 0]) < tol) return l[i]; return null; }

    MouseArea {
        id: ma
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: view.mode === "pan" ? Qt.ClosedHandCursor : (owner.tool === "select" ? (view.hoverZone ? Qt.SizeAllCursor : Qt.ArrowCursor) : Qt.CrossCursor)
        onWheel: function (w) {
            var factor = Math.pow(1.0015, w.angleDelta.y);
            var wx = s2wx(w.x), wy = s2wy(w.y);
            var np = Math.max(4, Math.min(600, ppm * factor));
            // keep world point under cursor fixed
            cx = wx - (w.x - width / 2) / np; cy = wy + (w.y - height / 2) / np; ppm = np;
        }
        onPressed: function (m) {
            owner.forceActiveFocus();
            var wx = s2wx(m.x), wy = s2wy(m.y);
            view.pressS = [m.x, m.y]; view.pressW = [wx, wy]; view.lastW = [wx, wy];
            view.snapOverride = (m.modifiers & Qt.AltModifier) !== 0;
            if (m.button === Qt.MiddleButton || (owner.tool === "pan")) { view.mode = "pan"; return; }
            var t = owner.tool;
            if (t === "select") {
                if (m.button === Qt.RightButton) {
                    var h0 = handleAt(m.x, m.y);
                    if (h0 && h0.kind === "vertex") { U.removeVertex(owner.selectedZone, h0.idx); owner.commit("Remove vertex"); return; }
                    var zr = zoneAt(wx, wy); if (zr) { if (!owner.isSelected(zr.id)) owner.select(zr.id, false); ctxMenu.popup(); }
                    return;
                }
                var label = view.labelAt(m.x, m.y);
                var h = label ? null : handleAt(m.x, m.y);
                if (h) {
                    if (h.kind === "mid") { var z0 = owner.selectedZone; var f0 = U.zoneFrame(z0); var lp0 = Geom.toLocal(f0, [wx, wy, 0]); U.insertVertex(z0, h.idx, lp0); h = { kind: "vertex", idx: h.idx + 1, x: lp0[0], y: lp0[1] }; owner.touch(); }
                    view.activeHandle = h; view.mode = "handle"; return;
                }
                var z = label ? label.zone : zoneAt(wx, wy);
                if (z) {
                    if (m.modifiers & Qt.ShiftModifier) { owner.select(z.id, true); view.mode = ""; return; }
                    if (!owner.isSelected(z.id)) owner.select(z.id, false);
                    if (owner.showMode) return;
                    view.dragStartPositions = {}; for (var i = 0; i < owner.selection.length; i++) { var zz = owner.zoneById(owner.selection[i]); if (zz) view.dragStartPositions[zz.id] = zz.pos.slice(); }
                    view.mode = "move";
                } else {
                    if (!(m.modifiers & Qt.ShiftModifier)) owner.selection = [];
                    view.marquee = [m.x, m.y, m.x, m.y]; view.mode = "marquee";
                }
            } else if (t === "polygon" || t === "path") {
                if (m.button === Qt.RightButton) { finishPoly(); return; }
                var p = [snap(wx), snap(wy)]; var dp = view.drawPoints.slice(); dp.push(p); view.drawPoints = dp; view.mode = "poly"; staticLayer.requestPaint();
            } else if (t === "sim") {
                var se = simAt(wx, wy);
                if (m.button === Qt.RightButton) { if (se) owner.removeSim(se.id); return; }
                if (se) { view.simDragId = se.id; owner.draggingSim = se.id; view.mode = "simdrag"; }
                else { var ne = owner.addDummy(wx, wy); view.simDragId = ne.id; owner.draggingSim = ne.id; view.mode = "simdrag"; }
                dynLayer.requestPaint();
            } else {
                if (m.button === Qt.RightButton) { owner.tool = "select"; return; }
                if (owner.showMode) return;
                view.previewShape = { type: t, x0: snap(wx), y0: snap(wy), x1: snap(wx), y1: snap(wy) }; view.mode = "draw"; staticLayer.requestPaint();
            }
        }
        onDoubleClicked: function (m) {
            if (owner.tool === "polygon" || owner.tool === "path") { finishPoly(); }
            else if (owner.tool === "select" && m.button === Qt.LeftButton) {
                var label = view.labelAt(m.x, m.y);
                if (label) owner.renameZone(label.zone.id, view, label.x, label.y, label.width, 11);
                else { var z = zoneAt(s2wx(m.x), s2wy(m.y)); if (z) owner.select(z.id, false); }
            }
        }
        onPositionChanged: function (m) {
            var wx = s2wx(m.x), wy = s2wy(m.y);
            view.hoverW = [wx, wy];
            if (view.mode === "pan") { cx -= (wx - view.lastW[0]); cy -= (wy - view.lastW[1]); view.lastW = [s2wx(m.x), s2wy(m.y)]; return; }
            if (view.mode === "move") {
                var dx = snap(wx - view.pressW[0]), dy = snap(wy - view.pressW[1]);
                for (var i = 0; i < owner.selection.length; i++) { var z = owner.zoneById(owner.selection[i]); if (!z || z.locked) continue; var sp = view.dragStartPositions[z.id]; if (!sp) continue; z.pos = [snap(sp[0] + dx), snap(sp[1] + dy), sp[2]]; }
                owner.touch();
            } else if (view.mode === "handle") {
                var zh = owner.selectedZone; if (!zh) return; var f = U.zoneFrame(zh);
                var lp = (view.activeHandle.kind === "rot") ? Geom.toLocal(f, [wx, wy, 0]) : Geom.toLocal(f, [snap(wx), snap(wy), 0]);
                U.applyHandle(zh, view.activeHandle, lp);
                if (view.activeHandle.kind === "rot" || view.activeHandle.kind === "scale") { var hk = view.activeHandle.kind; view.activeHandle = U.zoneHandles(zh).filter(function (hh) { return hh.kind === hk; })[0] || view.activeHandle; }
                owner.touch();
            } else if (view.mode === "draw") {
                var ps = view.previewShape; ps.x1 = snap(wx); ps.y1 = snap(wy); view.previewShape = ps; staticLayer.requestPaint();
            } else if (view.mode === "poly" || (owner.tool === "polygon" || owner.tool === "path") && view.drawPoints.length) {
                view.drawCurrent = [snap(wx), snap(wy)]; staticLayer.requestPaint();
            } else if (view.mode === "simdrag") {
                var se = owner.simById(view.simDragId); if (se) { se.pos = [wx, wy, 0]; se.vel = [0, 0, 0]; owner.simVersion++; }
            } else if (view.mode === "marquee") {
                var mq = view.marquee; mq[2] = m.x; mq[3] = m.y; view.marquee = mq; staticLayer.requestPaint();
            } else {
                var hz = zoneAt(wx, wy); view.hoverZone = hz ? hz.id : "";
                dynLayer.requestPaint();
            }
        }
        onReleased: function (m) {
            var wx = s2wx(m.x), wy = s2wy(m.y);
            if (view.mode === "move") { var moved = Math.abs(wx - view.pressW[0]) + Math.abs(wy - view.pressW[1]) > 1e-6; if (moved) owner.commit("Move zone" + (owner.selection.length > 1 ? "s" : "")); }
            else if (view.mode === "handle") { owner.commit(view.activeHandle && view.activeHandle.kind === "rot" ? "Rotate zone" : "Resize zone"); view.activeHandle = null; }
            else if (view.mode === "draw") { createFromPreview(); }
            else if (view.mode === "simdrag") { owner.draggingSim = ""; view.simDragId = ""; owner.simSend(); dynLayer.requestPaint(); }
            else if (view.mode === "marquee") {
                var mq = view.marquee; if (mq && Math.abs(mq[2] - mq[0]) > 3 && Math.abs(mq[3] - mq[1]) > 3) {
                    var x0 = s2wx(Math.min(mq[0], mq[2])), x1 = s2wx(Math.max(mq[0], mq[2])), y0 = s2wy(Math.max(mq[1], mq[3])), y1 = s2wy(Math.min(mq[1], mq[3]));
                    var sel = (m.modifiers & Qt.ShiftModifier) ? owner.selection.slice() : [];
                    for (var i = 0; i < owner.doc.zones.length; i++) { var z = owner.doc.zones[i]; if (z.visible === false) continue; var b = U.zoneWorldBounds(z); if (b[0] >= x0 && b[2] <= x1 && b[1] >= y0 && b[3] <= y1 && sel.indexOf(z.id) < 0) sel.push(z.id); }
                    owner.selection = sel;
                }
                view.marquee = null; staticLayer.requestPaint();
            }
            if (view.mode !== "poly") view.mode = "";
        }
        onExited: { view.hoverZone = ""; }
    }

    S.SImageDropArea {
        anchors.fill: parent; enabled: !owner.showMode
        onFilesDropped: function(paths, x, y) { owner.applyFloorPlan(paths[0], [view.s2wx(x), view.s2wy(y)]); }
    }

    function finishPoly() {
        var dp = view.drawPoints; var t = owner.tool;
        var minPts = t === "polygon" ? 3 : 2;
        if (dp.length >= minPts && !owner.showMode) {
            // centre the zone on the centroid, points relative
            var c = t === "polygon" ? Geom.polygonCentroid(dp) : [(dp[0][0] + dp[dp.length - 1][0]) / 2, (dp[0][1] + dp[dp.length - 1][1]) / 2];
            var rel = dp.map(function (p) { return [p[0] - c[0], p[1] - c[1]]; });
            if (t === "polygon" && Geom.polygonArea(rel) < 0) rel.reverse();
            var z = Model.makeZone(t, owner.doc.zones.length); z.pos = [c[0], c[1], 0]; z.shape.points = rel;
            if (owner.doc.settings.activeSet) z.set = owner.doc.settings.activeSet;
            owner.doc.zones.push(z); owner.selection = [z.id]; owner.commit("Add " + t);
        }
        view.drawPoints = []; view.drawCurrent = null; view.mode = ""; staticLayer.requestPaint();
    }
    function createFromPreview() {
        var ps = view.previewShape; view.previewShape = null; view.mode = "";
        if (!ps || owner.showMode) { staticLayer.requestPaint(); return; }
        var w = Math.abs(ps.x1 - ps.x0), h = Math.abs(ps.y1 - ps.y0); var r = Math.sqrt(w * w + h * h);
        var t = ps.type;
        if ((t === "rect" || t === "box") && (w < 0.05 || h < 0.05)) { w = Math.max(w, 1); h = Math.max(h, 1); }
        if ((t === "circle" || t === "sphere" || t === "cylinder") && r < 0.05) r = 1;
        if (t === "line" && r < 0.05) { ps.x1 = ps.x0 + 1; r = 1; }
        var z = Model.makeZone(t, owner.doc.zones.length);
        if (t === "rect" || t === "box") { z.pos = [(ps.x0 + ps.x1) / 2, (ps.y0 + ps.y1) / 2, t === "box" ? 1 : 0]; z.shape.w = w; z.shape.h = h; if (t === "box") z.shape.d = 2; }
        else if (t === "circle" || t === "sphere" || t === "cylinder") { z.pos = [ps.x0, ps.y0, t === "circle" ? 0 : (t === "sphere" ? r : 1)]; z.shape.r = r; if (t === "cylinder") z.shape.d = 2; }
        else if (t === "line") { var mx = (ps.x0 + ps.x1) / 2, my = (ps.y0 + ps.y1) / 2; z.pos = [mx, my, 0]; z.shape.points = [[ps.x0 - mx, ps.y0 - my], [ps.x1 - mx, ps.y1 - my]]; }
        if (owner.doc.settings.activeSet) z.set = owner.doc.settings.activeSet;
        owner.doc.zones.push(z); owner.selection = [z.id]; owner.commit("Add " + t);
        owner.tool = "select";
    }

    S.SMenu {
        id: ctxMenu
        S.SMenuItem { text: "Duplicate"; enabled: !owner.showMode; onTriggered: owner.duplicateSelected() }
        S.SMenuItem { text: "Delete"; enabled: !owner.showMode; onTriggered: owner.deleteSelected() }
        S.SMenuSeparator {}
        S.SMenuItem { text: (owner.selectedZone && owner.selectedZone.enabled === false) ? "Enable" : "Disable"; enabled: !owner.showMode; onTriggered: owner.setSelectedProp("enabled", !(owner.selectedZone && owner.selectedZone.enabled !== false), "Toggle enabled") }
        S.SMenuItem { text: (owner.selectedZone && owner.selectedZone.locked) ? "Unlock" : "Lock"; enabled: !owner.showMode; onTriggered: owner.setSelectedProp("locked", !(owner.selectedZone && owner.selectedZone.locked), "Toggle lock") }
        S.SMenuItem { text: "Hide"; enabled: !owner.showMode; onTriggered: owner.setSelectedProp("visible", false, "Hide zone") }
        S.SMenuSeparator {}
        S.SMenuItem { text: "Bring to front"; enabled: !owner.showMode; onTriggered: { var i = owner.zoneIndex(owner.selectedId); owner.reorderZone(i, owner.doc.zones.length - 1); } }
        S.SMenuItem { text: "Send to back"; enabled: !owner.showMode; onTriggered: { var i = owner.zoneIndex(owner.selectedId); owner.reorderZone(i, 0); } }
        S.SMenuSeparator {}
        S.SMenuItem { text: "Reset zone counters"; onTriggered: owner.executionSend({ type: "resetCounters", zone: owner.selectedId }) }
    }
}
