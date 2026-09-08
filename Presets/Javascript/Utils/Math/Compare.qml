import Score 1.0

// Compares A against B and emits a boolean.
// B keeps its last received value, so it can be left unconnected and typed in.
// On lists, the comparison is element-wise.
Script {
  ValueInlet   { id: inA; objectName: "A" }
  ValueInlet   { id: inB; objectName: "B" }
  FloatSpinBox { id: constB; objectName: "B (if unconnected)"; min: -1000000.; max: 1000000.; init: 0. }
  ComboBox     { id: op; objectName: "Test"
                 choices: [ "Less", "Less or equal", "Greater", "Greater or equal",
                            "Equal", "Not equal", "Close to" ]
                 index: 2 }
  FloatSpinBox { id: tol; objectName: "Tolerance"; min: 0.; max: 1000000.; init: 0.001 }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: allTrue; objectName: "All" }
  ValueOutlet  { id: anyTrue; objectName: "Any" }

  property var latchedB: undefined

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function copyOf(v) {
    if (!isList(v)) return v;
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) r[i] = copyOf(v[i]);
    return r;
  }
  function zipWith(a, b, f) {
    const la = isList(a), lb = isList(b);
    if (!la && !lb) return f(a, b);
    if (la && !lb) {
      var r = new Array(a.length);
      for (var i = 0; i < a.length; ++i) r[i] = zipWith(a[i], b, f);
      return r;
    }
    if (!la && lb) {
      var r2 = new Array(b.length);
      for (var j = 0; j < b.length; ++j) r2[j] = zipWith(a, b[j], f);
      return r2;
    }
    if (a.length === 0 || b.length === 0) return [];
    const n = Math.max(a.length, b.length);
    var r3 = new Array(n);
    for (var k = 0; k < n; ++k) r3[k] = zipWith(a[k % a.length], b[k % b.length], f);
    return r3;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function flatten(v, out) {
    if (isList(v)) { for (var i = 0; i < v.length; ++i) flatten(v[i], out); }
    else out.push(v);
    return out;
  }

  tick: function(token, state) {
    if (typeof inB.value !== "undefined")
      latchedB = copyOf(inB.value);
    if (typeof inA.value === "undefined")
      return;

    const b = (latchedB !== undefined) ? latchedB : constB.value;
    const eps = tol.value;
    const name = choice(op);
    const f = function(x, y) {
      // Strings compare lexically, everything else numerically.
      if (typeof x === "string" || typeof y === "string") {
        const sx = String(x), sy = String(y);
        switch (name) {
          case "Less": return sx < sy;
          case "Less or equal": return sx <= sy;
          case "Greater": return sx > sy;
          case "Greater or equal": return sx >= sy;
          case "Not equal": return sx !== sy;
          default: return sx === sy;
        }
      }
      const nx = Number(x), ny = Number(y);
      switch (name) {
        case "Less": return nx < ny;
        case "Less or equal": return nx <= ny;
        case "Greater": return nx > ny;
        case "Greater or equal": return nx >= ny;
        case "Equal": return nx === ny;
        case "Not equal": return nx !== ny;
        default: return Math.abs(nx - ny) <= eps;
      }
    };

    const res = zipWith(inA.value, b, f);
    output.value = res;

    const flat = flatten(res, []);
    var all = true, any = false;
    for (var i = 0; i < flat.length; ++i) {
      if (flat[i]) any = true; else all = false;
    }
    allTrue.value = flat.length > 0 && all;
    anyTrue.value = any;
  }
}
