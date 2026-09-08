import Score 1.0

// Removes duplicates from a list, and counts how often each value appeared.
// Also handy as a "who is here" reducer over a stream of ids.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: tol; objectName: "Tolerance"; min: 0.; max: 1000000.; init: 0. }
  Toggle       { id: sorted; objectName: "Sort result"; checked: false }
  ValueOutlet  { id: output; objectName: "Unique" }
  ValueOutlet  { id: countsOut; objectName: "Counts" }
  ValueOutlet  { id: lengthOut; objectName: "Length" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    return [ v ];
  }
  function same(a, b, eps) {
    if (isList(a) && isList(b)) {
      if (a.length !== b.length) return false;
      for (var i = 0; i < a.length; ++i) if (!same(a[i], b[i], eps)) return false;
      return true;
    }
    const na = Number(a), nb = Number(b);
    if (isFinite(na) && isFinite(nb)) return Math.abs(na - nb) <= eps;
    return String(a) === String(b);
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const l = asList(input.value);
    const eps = tol.value;
    var uniq = [], counts = [];

    for (var i = 0; i < l.length; ++i) {
      var found = -1;
      for (var j = 0; j < uniq.length; ++j) {
        if (same(l[i], uniq[j], eps)) { found = j; break; }
      }
      if (found >= 0) counts[found]++;
      else { uniq.push(l[i]); counts.push(1); }
    }

    if (boolOf(sorted)) {
      var idx = [];
      for (var k = 0; k < uniq.length; ++k) idx.push(k);
      idx.sort(function(a, b) {
        const na = Number(uniq[a]), nb = Number(uniq[b]);
        if (isFinite(na) && isFinite(nb)) return na - nb;
        return String(uniq[a]) < String(uniq[b]) ? -1 : 1;
      });
      var su = [], sc = [];
      for (var m = 0; m < idx.length; ++m) { su.push(uniq[idx[m]]); sc.push(counts[idx[m]]); }
      uniq = su; counts = sc;
    }

    output.value = uniq;
    countsOut.value = counts;
    lengthOut.value = uniq.length;
  }
}
