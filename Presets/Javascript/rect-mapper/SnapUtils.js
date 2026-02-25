// SnapUtils.js — Snapping logic for the rect-mapper UI

function getSnapTargets(shapes, excludeIdx) {
    var tx = [0, 1], ty = [0, 1];
    for (var i = 0; i < shapes.length; i++) {
        if (i === excludeIdx) continue;
        var c = shapes[i].vertices;
        if (!c) continue;
        for (var j = 0; j < c.length; j++) {
            tx.push(c[j][0]);
            ty.push(c[j][1]);
        }
    }
    return { x: tx, y: ty };
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
    return { value: best, dist: bestDist };
}

function snapVertex(nx, ny, excludeIdx, shapes, viewportW, viewportH, thresholdPx) {
    if (thresholdPx <= 0)
        return { pos: [nx, ny], linesX: [], linesY: [] };

    var thX = thresholdPx / viewportW;
    var thY = thresholdPx / viewportH;
    var targets = getSnapTargets(shapes, excludeIdx);
    var sX = nearestSnap(nx, targets.x);
    var sY = nearestSnap(ny, targets.y);
    var lx = [], ly = [];
    if (sX.dist <= thX) { nx = sX.value; lx.push(sX.value); }
    if (sY.dist <= thY) { ny = sY.value; ly.push(sY.value); }
    return { pos: [nx, ny], linesX: lx, linesY: ly };
}

function snapShapeMove(origCorners, dx, dy, excludeIdx, shapes, viewportW, viewportH, thresholdPx) {
    if (thresholdPx <= 0)
        return { dx: dx, dy: dy, linesX: [], linesY: [] };

    var thX = thresholdPx / viewportW;
    var thY = thresholdPx / viewportH;
    var targets = getSnapTargets(shapes, excludeIdx);

    var bestSnapDx = 0, bestDistX = thX + 1;
    var bestSnapDy = 0, bestDistY = thY + 1;

    for (var i = 0; i < origCorners.length; i++) {
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

    if (bestDistX <= thX) dx += bestSnapDx;
    if (bestDistY <= thY) dy += bestSnapDy;

    // Compute snap guide lines
    var lx = [], ly = [];
    for (var i = 0; i < origCorners.length; i++) {
        var sX2 = nearestSnap(origCorners[i][0] + dx, targets.x);
        if (sX2.dist < 0.001) lx.push(sX2.value);
        var sY2 = nearestSnap(origCorners[i][1] + dy, targets.y);
        if (sY2.dist < 0.001) ly.push(sY2.value);
    }

    return { dx: dx, dy: dy, linesX: lx, linesY: ly };
}
