import Score 1.0

// Only forwards a value once it has moved far enough from the last one sent.
// The cheapest way to tame a jittery sensor or OSC stream.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: threshold; objectName: "Threshold"; min: 0.; max: 1000000.; init: 0.01 }
  Toggle       { id: relative; objectName: "Relative"; checked: false }
  ValueOutlet  { id: output; objectName: "Out" }

  property var last: undefined

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
  // Largest per-component move between two values.
  function maxMove(a, b, rel) {
    const la = asList(a), lb = asList(b);
    if (la.length !== lb.length) return Infinity;
    var m = 0;
    for (var i = 0; i < la.length; ++i) {
      const x = Number(la[i]), y = Number(lb[i]);
      if (!isFinite(x) || !isFinite(y))
        { if (la[i] !== lb[i]) return Infinity; continue; }
      var d = Math.abs(x - y);
      if (rel) d /= Math.max(1e-9, Math.abs(y));
      if (d > m) m = d;
    }
    return m;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const v = input.value;
    if (last === undefined || maxMove(v, last, boolOf(relative)) > threshold.value) {
      last = isList(v) ? asList(v) : v;
      output.value = last;
    }
  }
}
