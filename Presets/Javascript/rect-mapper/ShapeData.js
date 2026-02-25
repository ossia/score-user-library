// ShapeData.js — Shape data model utilities for the rect-mapper

function cloneShape(shape) {
    return JSON.parse(JSON.stringify(shape));
}

function verticesEqual(a, b) {
    if (!a || !b || a.length !== b.length) return false;
    for (var i = 0; i < a.length; i++)
        if (a[i][0] !== b[i][0] || a[i][1] !== b[i][1])
            return false;
    return true;
}

function shapesEqual(a, b) {
    if (!a || !b) return false;
    if (!a.vertices || !b.vertices) return false;
    if (!verticesEqual(a.vertices, b.vertices)) return false;
    if ((a.source || 0) !== (b.source || 0)) return false;

    var ab = a.blend || {}, bb = b.blend || {};
    if ((ab.top || 0) !== (bb.top || 0) || (ab.bottom || 0) !== (bb.bottom || 0)
        || (ab.left || 0) !== (bb.left || 0) || (ab.right || 0) !== (bb.right || 0))
        return false;

    if ((a.blendGamma || 1) !== (b.blendGamma || 1)) return false;
    if ((a.srcBlend === undefined ? 1 : a.srcBlend) !== (b.srcBlend === undefined ? 1 : b.srcBlend))
        return false;
    if ((a.dstBlend === undefined ? 7 : a.dstBlend) !== (b.dstBlend === undefined ? 7 : b.dstBlend))
        return false;
    if ((a.warp || false) !== (b.warp || false)) return false;
    if ((a.gridW || 4) !== (b.gridW || 4)) return false;
    if ((a.gridH || 4) !== (b.gridH || 4)) return false;
    var ago = a.gridOffsets, bgo = b.gridOffsets;
    if ((!ago) !== (!bgo)) return false;
    if (ago && bgo) {
        if (ago.length !== bgo.length) return false;
        for (var i = 0; i < ago.length; i++)
            if (ago[i] !== bgo[i]) return false;
    }
    return true;
}

function defaultBlend() {
    return { top: 0, right: 0, bottom: 0, left: 0 };
}

function gridPointPos(shape, row, col) {
    var gw = shape.gridW || 4;
    var gh = shape.gridH || 4;
    var u = col / gw;
    var v = row / gh;
    var c = shape.vertices;
    var nx = (1-u)*(1-v)*c[0][0] + u*(1-v)*c[1][0]
           + u*v*c[2][0] + (1-u)*v*c[3][0];
    var ny = (1-u)*(1-v)*c[0][1] + u*(1-v)*c[1][1]
           + u*v*c[2][1] + (1-u)*v*c[3][1];
    if (shape.gridOffsets) {
        var idx = row * (gw + 1) + col;
        if (idx * 2 + 1 < shape.gridOffsets.length) {
            nx += shape.gridOffsets[idx * 2];
            ny += shape.gridOffsets[idx * 2 + 1];
        }
    }
    return [nx, ny];
}

function initGridOffsets(gridW, gridH) {
    var total = (gridW + 1) * (gridH + 1) * 2;
    var offsets = [];
    for (var i = 0; i < total; i++) offsets.push(0);
    return offsets;
}

function createQuad(offset) {
    var x0 = 0.1 + offset, y0 = 0.1 + offset;
    var x1 = 0.4 + offset, y1 = 0.4 + offset;
    return {
        id: "shape-" + Date.now(),
        name: "Quad",
        vertices: [[x0, y0], [x1, y0], [x1, y1], [x0, y1]],
        source: 0,
        blend: defaultBlend(),
        blendGamma: 1.0,
        srcBlend: 1,
        dstBlend: 7,
        warp: true,
        gridW: 4,
        gridH: 4
    };
}

function createTriangle(offset) {
    var cx = 0.25 + offset, cy = 0.25 + offset;
    var r = 0.15;
    return {
        id: "shape-" + Date.now(),
        name: "Triangle",
        vertices: [
            [cx, cy - r],
            [cx + r * Math.cos(Math.PI / 6), cy + r * Math.sin(Math.PI / 6)],
            [cx - r * Math.cos(Math.PI / 6), cy + r * Math.sin(Math.PI / 6)]
        ],
        source: 0,
        blend: defaultBlend(),
        blendGamma: 1.0,
        srcBlend: 1,
        dstBlend: 7,
        warp: false
    };
}

function createRegularPolygon(n, name, offset) {
    var cx = 0.25 + offset, cy = 0.25 + offset;
    var r = 0.15;
    var verts = [];
    for (var i = 0; i < n; i++) {
        var angle = -Math.PI / 2 + (2 * Math.PI * i) / n;
        verts.push([cx + r * Math.cos(angle), cy + r * Math.sin(angle)]);
    }
    return {
        id: "shape-" + Date.now(),
        name: name,
        vertices: verts,
        source: 0,
        blend: defaultBlend(),
        blendGamma: 1.0,
        srcBlend: 1,
        dstBlend: 7,
        warp: false
    };
}

function createShape(type, count) {
    var offset = (count % 5) * 0.05;
    switch (type) {
        case "quad": return createQuad(offset);
        case "triangle": return createTriangle(offset);
        case "pentagon": return createRegularPolygon(5, "Pentagon", offset);
        case "hexagon": return createRegularPolygon(6, "Hexagon", offset);
        case "circle": return createRegularPolygon(12, "Circle", offset);
        case "star": return createStar(offset);
        default: return createQuad(offset);
    }
}

function createStar(offset) {
    var cx = 0.25 + offset, cy = 0.25 + offset;
    var outerR = 0.15, innerR = 0.07;
    var verts = [];
    for (var i = 0; i < 10; i++) {
        var angle = -Math.PI / 2 + (2 * Math.PI * i) / 10;
        var r = (i % 2 === 0) ? outerR : innerR;
        verts.push([cx + r * Math.cos(angle), cy + r * Math.sin(angle)]);
    }
    return {
        id: "shape-" + Date.now(),
        name: "Star",
        vertices: verts,
        source: 0,
        blend: defaultBlend(),
        blendGamma: 1.0,
        srcBlend: 1,
        dstBlend: 7,
        warp: false
    };
}

// Check if shapes array differs from another
function shapesDiffer(oldShapes, newShapes) {
    if (oldShapes.length !== newShapes.length) return true;
    for (var i = 0; i < newShapes.length; i++) {
        if (!shapesEqual(oldShapes[i], newShapes[i]))
            return true;
    }
    return false;
}
