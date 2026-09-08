import Score 1.0

// Extent of a cloud of points: corners, size, centre and barycentre.
// Feed it tracking data, a contour, a particle system — anything that arrives
// as a list of points — to know where "it" is and how big it is.
Script {
  ValueInlet  { id: input; objectName: "Points" }
  Toggle      { id: square; objectName: "Keep aspect"; checked: false }
  ValueOutlet { id: minOut; objectName: "Min" }
  ValueOutlet { id: maxOut; objectName: "Max" }
  ValueOutlet { id: sizeOut; objectName: "Size" }
  ValueOutlet { id: centerOut; objectName: "Center" }
  ValueOutlet { id: centroidOut; objectName: "Centroid" }
  ValueOutlet { id: countOut; objectName: "Count" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asVec(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = Number(v[i]) || 0.; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    const n = Number(v);
    return isFinite(n) ? [ n ] : [];
  }
  // Accepts [[x,y],...], [x,y,x,y,...] or a single point.
  function points(v) {
    if (!isList(v)) { const p = asVec(v); return p.length ? [ p ] : []; }
    if (v.length === 0) return [];
    if (isList(v[0]) || (v[0] !== null && typeof v[0] === "object")) {
      var out = [];
      for (var i = 0; i < v.length; ++i) {
        const p2 = asVec(v[i]);
        if (p2.length) out.push(p2);
      }
      return out;
    }
    const flat = asVec(v);
    if (flat.length <= 4) return [ flat ];
    var pairs = [];
    for (var j = 0; j + 1 < flat.length; j += 2) pairs.push([ flat[j], flat[j + 1] ]);
    return pairs;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const pts = points(input.value);
    countOut.value = pts.length;
    if (pts.length === 0)
      return;

    var dim = 0;
    for (var i = 0; i < pts.length; ++i) dim = Math.max(dim, pts[i].length);

    var lo = new Array(dim), hi = new Array(dim), sum = new Array(dim);
    for (var d = 0; d < dim; ++d) { lo[d] = Infinity; hi[d] = -Infinity; sum[d] = 0.; }

    for (var k = 0; k < pts.length; ++k) {
      for (var e = 0; e < dim; ++e) {
        const c = (e < pts[k].length) ? pts[k][e] : 0.;
        if (c < lo[e]) lo[e] = c;
        if (c > hi[e]) hi[e] = c;
        sum[e] += c;
      }
    }

    var size = new Array(dim), center = new Array(dim), centroid = new Array(dim);
    var biggest = 0.;
    for (var f = 0; f < dim; ++f) {
      size[f] = hi[f] - lo[f];
      if (size[f] > biggest) biggest = size[f];
      center[f] = 0.5 * (lo[f] + hi[f]);
      centroid[f] = sum[f] / pts.length;
    }

    if (boolOf(square)) {
      for (var g = 0; g < dim; ++g) {
        size[g] = biggest;
        lo[g] = center[g] - biggest / 2.;
        hi[g] = center[g] + biggest / 2.;
      }
    }

    minOut.value = lo;
    maxOut.value = hi;
    sizeOut.value = size;
    centerOut.value = center;
    centroidOut.value = centroid;
  }
}
