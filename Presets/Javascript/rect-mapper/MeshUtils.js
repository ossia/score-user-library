// MeshUtils.js — Mesh generation for the rect-mapper
// Provides quad bilinear mesh and polygon triangulation.

function computeQuadMesh(corners, N, w, h, z) {
    var c = corners;
    var total = (N + 1) * (N + 1);
    var positions = new Array(total);
    var normals = new Array(total);
    var uvs = new Array(total);
    var indices = [];
    var normalVec = Qt.vector3d(0, 0, 1);

    // Generate (N+1)x(N+1) vertices via bilinear interpolation
    var idx = 0;
    for (var row = 0; row <= N; row++) {
        var v = row / N;
        for (var col = 0; col <= N; col++) {
            var u = col / N;

            var nx = (1 - u) * (1 - v) * c[0][0] + u * (1 - v) * c[1][0]
                   + u * v * c[2][0] + (1 - u) * v * c[3][0];
            var ny = (1 - u) * (1 - v) * c[0][1] + u * (1 - v) * c[1][1]
                   + u * v * c[2][1] + (1 - u) * v * c[3][1];

            positions[idx] = Qt.vector3d((nx - 0.5) * w, (0.5 - ny) * h, z);
            normals[idx] = normalVec;
            uvs[idx] = Qt.vector2d(u, 1 - v);
            idx++;
        }
    }

    // Generate triangle indices for each grid cell
    var stride = N + 1;
    for (var row = 0; row < N; row++) {
        for (var col = 0; col < N; col++) {
            var a = row * stride + col;
            var b = row * stride + col + 1;
            var c2 = (row + 1) * stride + col + 1;
            var d = (row + 1) * stride + col;
            indices.push(a, d, c2);
            indices.push(a, c2, b);
        }
    }

    return { positions: positions, normals: normals, uvs: uvs, indices: indices };
}

// Catmull-Rom spline: interpolate between p1 and p2 using p0,p3 as neighbors
// Gives C1-continuous curve that passes through all control points
function catmullRom(t, p0, p1, p2, p3) {
    var t2 = t * t, t3 = t2 * t;
    return 0.5 * ((2*p1) + (-p0 + p2)*t
        + (2*p0 - 5*p1 + 4*p2 - p3)*t2
        + (-p0 + 3*p1 - 3*p2 + p3)*t3);
}

function computeQuadMeshWithGrid(corners, gridW, gridH, gridOffsets, N, w, h, z) {
    var c = corners;
    var cw = gridW + 1;

    // Build control grid: bilinear defaults + offsets
    var grid = new Array(cw * (gridH + 1) * 2);
    for (var row = 0; row <= gridH; row++) {
        var v = row / gridH;
        for (var col = 0; col <= gridW; col++) {
            var u = col / gridW;
            var gi = row * cw + col;
            var nx = (1-u)*(1-v)*c[0][0] + u*(1-v)*c[1][0]
                   + u*v*c[2][0] + (1-u)*v*c[3][0];
            var ny = (1-u)*(1-v)*c[0][1] + u*(1-v)*c[1][1]
                   + u*v*c[2][1] + (1-u)*v*c[3][1];
            if (gridOffsets) {
                nx += gridOffsets[gi * 2] || 0;
                ny += gridOffsets[gi * 2 + 1] || 0;
            }
            grid[gi * 2] = nx;
            grid[gi * 2 + 1] = ny;
        }
    }

    // Generate render mesh with Catmull-Rom spline interpolation
    var total = (N + 1) * (N + 1);
    var positions = new Array(total);
    var normals = new Array(total);
    var uvs = new Array(total);
    var normalVec = Qt.vector3d(0, 0, 1);

    var idx = 0;
    for (var row = 0; row <= N; row++) {
        var gv = row / N * gridH;
        var gr = Math.min(Math.floor(gv), gridH - 1);
        var lv = gv - gr;

        // Clamped row indices for 4-point Catmull-Rom stencil
        var r0 = Math.max(0, gr - 1), r1 = gr;
        var r2 = gr + 1, r3 = Math.min(gridH, gr + 2);

        for (var col = 0; col <= N; col++) {
            var gu = col / N * gridW;
            var gc = Math.min(Math.floor(gu), gridW - 1);
            var lu = gu - gc;

            // Clamped column indices
            var c0 = Math.max(0, gc - 1), c1 = gc;
            var c2p = gc + 1, c3 = Math.min(gridW, gc + 2);

            // 4 horizontal CR interpolations (one per row of the stencil)
            var i00=(r0*cw+c0)*2, i01=(r0*cw+c1)*2, i02=(r0*cw+c2p)*2, i03=(r0*cw+c3)*2;
            var hx0 = catmullRom(lu, grid[i00], grid[i01], grid[i02], grid[i03]);
            var hy0 = catmullRom(lu, grid[i00+1], grid[i01+1], grid[i02+1], grid[i03+1]);

            var i10=(r1*cw+c0)*2, i11=(r1*cw+c1)*2, i12=(r1*cw+c2p)*2, i13=(r1*cw+c3)*2;
            var hx1 = catmullRom(lu, grid[i10], grid[i11], grid[i12], grid[i13]);
            var hy1 = catmullRom(lu, grid[i10+1], grid[i11+1], grid[i12+1], grid[i13+1]);

            var i20=(r2*cw+c0)*2, i21=(r2*cw+c1)*2, i22=(r2*cw+c2p)*2, i23=(r2*cw+c3)*2;
            var hx2 = catmullRom(lu, grid[i20], grid[i21], grid[i22], grid[i23]);
            var hy2 = catmullRom(lu, grid[i20+1], grid[i21+1], grid[i22+1], grid[i23+1]);

            var i30=(r3*cw+c0)*2, i31=(r3*cw+c1)*2, i32=(r3*cw+c2p)*2, i33=(r3*cw+c3)*2;
            var hx3 = catmullRom(lu, grid[i30], grid[i31], grid[i32], grid[i33]);
            var hy3 = catmullRom(lu, grid[i30+1], grid[i31+1], grid[i32+1], grid[i33+1]);

            // Vertical CR interpolation
            var px = catmullRom(lv, hx0, hx1, hx2, hx3);
            var py = catmullRom(lv, hy0, hy1, hy2, hy3);

            positions[idx] = Qt.vector3d((px - 0.5) * w, (0.5 - py) * h, z);
            normals[idx] = normalVec;
            uvs[idx] = Qt.vector2d(col / N, 1 - row / N);
            idx++;
        }
    }

    // Generate triangle indices
    var stride = N + 1;
    var indices = [];
    for (var row = 0; row < N; row++) {
        for (var col = 0; col < N; col++) {
            var a = row * stride + col;
            var b = row * stride + col + 1;
            var c2 = (row + 1) * stride + col + 1;
            var d = (row + 1) * stride + col;
            indices.push(a, d, c2);
            indices.push(a, c2, b);
        }
    }

    return { positions: positions, normals: normals, uvs: uvs, indices: indices };
}

// --- Polygon triangulation ---

function cross2d(ox, oy, ax, ay, bx, by) {
    return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox);
}

function pointInTriangle(px, py, ax, ay, bx, by, cx, cy) {
    var d1 = cross2d(px, py, ax, ay, bx, by);
    var d2 = cross2d(px, py, bx, by, cx, cy);
    var d3 = cross2d(px, py, cx, cy, ax, ay);
    var hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    var hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
}

function isConvex(prev, curr, next) {
    return cross2d(prev[0], prev[1], curr[0], curr[1], next[0], next[1]) > 0;
}

// Ensure vertices are in counter-clockwise order
function ensureCCW(verts) {
    var area = 0;
    for (var i = 0; i < verts.length; i++) {
        var j = (i + 1) % verts.length;
        area += verts[i][0] * verts[j][1];
        area -= verts[j][0] * verts[i][1];
    }
    if (area < 0) {
        verts.reverse();
    }
    return verts;
}

// Check if a polygon is convex (O(n))
function isConvexPolygon(verts) {
    var n = verts.length;
    if (n < 3) return false;
    var sign = 0;
    for (var i = 0; i < n; i++) {
        var a = verts[i];
        var b = verts[(i + 1) % n];
        var c = verts[(i + 2) % n];
        var cross = (b[0] - a[0]) * (c[1] - b[1]) - (b[1] - a[1]) * (c[0] - b[0]);
        if (cross !== 0) {
            if (sign === 0) sign = cross > 0 ? 1 : -1;
            else if ((cross > 0 ? 1 : -1) !== sign) return false;
        }
    }
    return true;
}

// Ear-clipping triangulation (O(n²) typical, O(n³) worst case)
function triangulatePolygon(vertices) {
    if (vertices.length < 3) return [];
    if (vertices.length === 3) return [0, 1, 2];

    var verts = [];
    for (var i = 0; i < vertices.length; i++)
        verts.push([vertices[i][0], vertices[i][1]]);
    ensureCCW(verts);

    var remaining = [];
    for (var i = 0; i < verts.length; i++) remaining.push(i);

    var indices = [];

    while (remaining.length > 3) {
        var earFound = false;
        for (var i = 0; i < remaining.length; i++) {
            var pi = (i - 1 + remaining.length) % remaining.length;
            var ni = (i + 1) % remaining.length;
            var prev = remaining[pi], curr = remaining[i], next = remaining[ni];

            if (!isConvex(verts[prev], verts[curr], verts[next]))
                continue;

            var isEar = true;
            for (var j = 0; j < remaining.length; j++) {
                if (remaining[j] === prev || remaining[j] === curr || remaining[j] === next)
                    continue;
                var p = verts[remaining[j]];
                if (pointInTriangle(p[0], p[1],
                        verts[prev][0], verts[prev][1],
                        verts[curr][0], verts[curr][1],
                        verts[next][0], verts[next][1])) {
                    isEar = false;
                    break;
                }
            }

            if (isEar) {
                indices.push(prev, curr, next);
                remaining.splice(i, 1);
                earFound = true;
                break;
            }
        }
        if (!earFound) break;
    }

    if (remaining.length === 3) {
        indices.push(remaining[0], remaining[1], remaining[2]);
    }

    return indices;
}

// Fan triangulation for convex polygons (O(n))
function fanTriangulate(n) {
    var indices = [];
    for (var i = 1; i < n - 1; i++)
        indices.push(0, i, i + 1);
    return indices;
}

function computePolygonMesh(vertices, edges, N, w, h, z) {
    if (!vertices || vertices.length < 3)
        return { positions: [], normals: [], uvs: [], indices: [] };

    // Flatten bezier edges
    var flatVerts = flattenEdges(vertices, edges, N);

    // Triangulate: use O(n) fan for convex, ear-clipping for concave
    var triIndices;
    if (isConvexPolygon(flatVerts)) {
        triIndices = fanTriangulate(flatVerts.length);
    } else {
        // For concave shapes, cap vertex count to keep ear-clipping tractable
        if (flatVerts.length > 128) {
            var cappedN = Math.max(4, Math.floor(128 / vertices.length));
            flatVerts = flattenEdges(vertices, edges, cappedN);
        }
        triIndices = triangulatePolygon(flatVerts);
    }

    // Compute bounding box on flattened vertices for correct UV mapping
    var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (var i = 0; i < flatVerts.length; i++) {
        if (flatVerts[i][0] < minX) minX = flatVerts[i][0];
        if (flatVerts[i][1] < minY) minY = flatVerts[i][1];
        if (flatVerts[i][0] > maxX) maxX = flatVerts[i][0];
        if (flatVerts[i][1] > maxY) maxY = flatVerts[i][1];
    }
    var bboxW = maxX - minX || 1;
    var bboxH = maxY - minY || 1;

    // Build mesh directly from triangulation — no subdivision needed for planar UV
    var nv = flatVerts.length;
    var positions = new Array(nv);
    var normals = new Array(nv);
    var uvs = new Array(nv);
    var normalVec = Qt.vector3d(0, 0, 1);

    for (var i = 0; i < nv; i++) {
        var px = flatVerts[i][0];
        var py = flatVerts[i][1];
        positions[i] = Qt.vector3d((px - 0.5) * w, (0.5 - py) * h, z);
        normals[i] = normalVec;
        uvs[i] = Qt.vector2d((px - minX) / bboxW, 1 - (py - minY) / bboxH);
    }

    return { positions: positions, normals: normals, uvs: uvs, indices: triIndices };
}

// --- Warped polygon mesh (boundary UV mapping + subdivision) ---

// Map polygon boundary vertices to unit square perimeter proportional to arc length
function computeBoundaryUVs(flatVerts) {
    var n = flatVerts.length;
    var uvs = new Array(n);

    // Cumulative perimeter distances
    var dists = new Array(n);
    dists[0] = 0;
    var totalDist = 0;
    for (var i = 1; i < n; i++) {
        var dx = flatVerts[i][0] - flatVerts[i-1][0];
        var dy = flatVerts[i][1] - flatVerts[i-1][1];
        totalDist += Math.sqrt(dx*dx + dy*dy);
        dists[i] = totalDist;
    }
    // Closing edge
    var dx = flatVerts[0][0] - flatVerts[n-1][0];
    var dy = flatVerts[0][1] - flatVerts[n-1][1];
    totalDist += Math.sqrt(dx*dx + dy*dy);

    // Map to unit square perimeter: bottom→right→top→left
    for (var i = 0; i < n; i++) {
        var t = (dists[i] / totalDist) * 4;
        if (t <= 1) {
            uvs[i] = [t, 0];
        } else if (t <= 2) {
            uvs[i] = [1, t - 1];
        } else if (t <= 3) {
            uvs[i] = [3 - t, 1];
        } else {
            uvs[i] = [0, 4 - t];
        }
    }

    return uvs;
}

// Subdivide a triangle with per-vertex UV interpolation (barycentric)
function subdivideTriangleWarped(v0, v1, v2, uv0, uv1, uv2, N, w, h, z, normalVec) {
    var total = ((N + 1) * (N + 2)) >> 1;
    var positions = new Array(total);
    var normals = new Array(total);
    var uvs = new Array(total);
    var indices = [];
    var vertMap = [];
    var idx = 0;

    for (var i = 0; i <= N; i++) {
        vertMap[i] = [];
        for (var j = 0; j <= N - i; j++) {
            var k = N - i - j;
            var bi = i / N, bj = j / N, bk = k / N;

            var px = bi * v0[0] + bj * v1[0] + bk * v2[0];
            var py = bi * v0[1] + bj * v1[1] + bk * v2[1];

            var u = bi * uv0[0] + bj * uv1[0] + bk * uv2[0];
            var v_uv = bi * uv0[1] + bj * uv1[1] + bk * uv2[1];

            positions[idx] = Qt.vector3d((px - 0.5) * w, (0.5 - py) * h, z);
            normals[idx] = normalVec;
            uvs[idx] = Qt.vector2d(u, 1 - v_uv);
            vertMap[i][j] = idx++;
        }
    }

    for (var i = 0; i < N; i++) {
        for (var j = 0; j < N - i; j++) {
            indices.push(vertMap[i][j], vertMap[i][j + 1], vertMap[i + 1][j]);
            if (j + 1 <= N - i - 1)
                indices.push(vertMap[i][j + 1], vertMap[i + 1][j + 1], vertMap[i + 1][j]);
        }
    }

    return { positions: positions, normals: normals, uvs: uvs, indices: indices };
}

function computePolygonMeshWarped(vertices, edges, N, w, h, z) {
    if (!vertices || vertices.length < 3)
        return { positions: [], normals: [], uvs: [], indices: [] };

    // Flatten bezier edges (cap segments for performance in warp mode)
    var bezierSegments = Math.max(4, Math.min(N, 16));
    var flatVerts = flattenEdges(vertices, edges, bezierSegments);

    // Boundary UV mapping (perimeter → unit square)
    var boundaryUVs = computeBoundaryUVs(flatVerts);

    // Centroid as interior anchor
    var cx = 0, cy = 0;
    var nf = flatVerts.length;
    for (var i = 0; i < nf; i++) {
        cx += flatVerts[i][0];
        cy += flatVerts[i][1];
    }
    var centroid = [cx / nf, cy / nf];
    var centroidUV = [0.5, 0.5];

    // Fan-triangulate from centroid, subdivide each triangle
    var positions = [];
    var normals = [];
    var uvs = [];
    var indices = [];
    var vertexOffset = 0;
    var normalVec = Qt.vector3d(0, 0, 1);

    for (var i = 0; i < nf; i++) {
        var j = (i + 1) % nf;
        var sub = subdivideTriangleWarped(
            centroid, flatVerts[i], flatVerts[j],
            centroidUV, boundaryUVs[i], boundaryUVs[j],
            N, w, h, z, normalVec
        );

        for (var k = 0; k < sub.positions.length; k++)
            positions.push(sub.positions[k]);
        for (var k = 0; k < sub.normals.length; k++)
            normals.push(sub.normals[k]);
        for (var k = 0; k < sub.uvs.length; k++)
            uvs.push(sub.uvs[k]);
        for (var k = 0; k < sub.indices.length; k++)
            indices.push(sub.indices[k] + vertexOffset);

        vertexOffset += sub.positions.length;
    }

    return { positions: positions, normals: normals, uvs: uvs, indices: indices };
}

// --- Bezier flattening ---

function flattenBezierEdge(p0, p1, cp1, cp2, segments) {
    var points = [];
    for (var i = 1; i < segments; i++) {
        var t = i / segments;
        var mt = 1 - t;
        var x = mt*mt*mt * p0[0] + 3*mt*mt*t * cp1[0] + 3*mt*t*t * cp2[0] + t*t*t * p1[0];
        var y = mt*mt*mt * p0[1] + 3*mt*mt*t * cp1[1] + 3*mt*t*t * cp2[1] + t*t*t * p1[1];
        points.push([x, y]);
    }
    return points;
}

function flattenEdges(vertices, edges, N) {
    if (!edges || edges.length === 0) return vertices;

    var result = [];
    var segments = Math.max(4, N || 8);

    for (var i = 0; i < vertices.length; i++) {
        result.push(vertices[i]);
        var edge = (i < edges.length) ? edges[i] : null;
        if (edge && edge.cp1 && edge.cp2) {
            var next = vertices[(i + 1) % vertices.length];
            var midPts = flattenBezierEdge(vertices[i], next, edge.cp1, edge.cp2, segments);
            for (var j = 0; j < midPts.length; j++)
                result.push(midPts[j]);
        }
    }

    return result;
}

// Build a cache key string from shape parameters that affect the mesh
function meshCacheKey(shape, N, w, h) {
    var key = N + ":" + w + ":" + h + ":" + (shape.warp ? "W" : "P") + ":";
    var verts = shape.vertices;
    for (var i = 0; i < verts.length; i++)
        key += verts[i][0] + "," + verts[i][1] + ",";
    var edges = shape.edges;
    if (edges) {
        for (var i = 0; i < edges.length; i++) {
            if (edges[i] && edges[i].cp1 && edges[i].cp2) {
                key += "b" + edges[i].cp1[0] + "," + edges[i].cp1[1] + ","
                     + edges[i].cp2[0] + "," + edges[i].cp2[1] + ",";
            } else {
                key += "s,";
            }
        }
    }
    if (shape.gridOffsets) {
        key += "g" + (shape.gridW || 4) + "x" + (shape.gridH || 4) + ":";
        for (var i = 0; i < shape.gridOffsets.length; i++)
            key += shape.gridOffsets[i] + ",";
    }
    return key;
}
