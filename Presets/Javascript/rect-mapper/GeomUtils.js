// GeomUtils.js — Geometry helpers for the rect-mapper UI

function pointInPolygon(px, py, pts) {
    if (!pts || pts.length < 3) return false;
    var inside = false;
    for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
        var xi = pts[i][0], yi = pts[i][1];
        var xj = pts[j][0], yj = pts[j][1];
        if (((yi > py) !== (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi))
            inside = !inside;
    }
    return inside;
}

function polygonCentroid(vertices) {
    var sx = 0, sy = 0;
    for (var i = 0; i < vertices.length; i++) {
        sx += vertices[i][0];
        sy += vertices[i][1];
    }
    return [sx / vertices.length, sy / vertices.length];
}

function rotatePoint(px, py, centroid, cos, sin) {
    var dx = px - centroid[0];
    var dy = py - centroid[1];
    return [centroid[0] + dx * cos - dy * sin,
            centroid[1] + dx * sin + dy * cos];
}

function rotateVertices(vertices, centroid, angle) {
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);
    var result = [];
    for (var i = 0; i < vertices.length; i++)
        result.push(rotatePoint(vertices[i][0], vertices[i][1], centroid, cos, sin));
    return result;
}

function rotateEdges(edges, centroid, angle) {
    if (!edges || edges.length === 0) return edges;
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);
    var result = [];
    for (var i = 0; i < edges.length; i++) {
        var e = edges[i];
        if (e && e.cp1 && e.cp2) {
            result.push({
                cp1: rotatePoint(e.cp1[0], e.cp1[1], centroid, cos, sin),
                cp2: rotatePoint(e.cp2[0], e.cp2[1], centroid, cos, sin)
            });
        } else {
            result.push(null);
        }
    }
    return result;
}

function formatInfo(rd, renderWidth, renderHeight) {
    if (!rd || !rd.vertices) return "";
    var ct = polygonCentroid(rd.vertices);
    if (renderWidth > 0 && renderHeight > 0) {
        var px = Math.round(ct[0] * renderWidth);
        var py = Math.round(ct[1] * renderHeight);
        return "(" + px + ", " + py + ")";
    }
    return "(" + ct[0].toFixed(2) + ", " + ct[1].toFixed(2) + ")";
}

function incrementName(name) {
    var m = name.match(/^(.*?)(\d+)$/);
    if (m) return m[1] + (parseInt(m[2]) + 1);
    return name + " 2";
}

// Distance from point (px,py) to line segment (ax,ay)-(bx,by)
function distToSegment(px, py, ax, ay, bx, by) {
    var dx = bx - ax, dy = by - ay;
    var lenSq = dx * dx + dy * dy;
    if (lenSq === 0) return Math.sqrt((px - ax) * (px - ax) + (py - ay) * (py - ay));
    var t = Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / lenSq));
    var projX = ax + t * dx, projY = ay + t * dy;
    return Math.sqrt((px - projX) * (px - projX) + (py - projY) * (py - projY));
}

// Find the nearest edge index to a point. Returns { edgeIndex, t, dist }
function nearestEdge(px, py, vertices) {
    var bestIdx = -1, bestDist = Infinity, bestT = 0;
    for (var i = 0; i < vertices.length; i++) {
        var j = (i + 1) % vertices.length;
        var ax = vertices[i][0], ay = vertices[i][1];
        var bx = vertices[j][0], by = vertices[j][1];
        var dx = bx - ax, dy = by - ay;
        var lenSq = dx * dx + dy * dy;
        var t = lenSq === 0 ? 0 : Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / lenSq));
        var projX = ax + t * dx, projY = ay + t * dy;
        var dist = Math.sqrt((px - projX) * (px - projX) + (py - projY) * (py - projY));
        if (dist < bestDist) {
            bestDist = dist;
            bestIdx = i;
            bestT = t;
        }
    }
    return { edgeIndex: bestIdx, t: bestT, dist: bestDist };
}
