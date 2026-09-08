import Score 1.0

// Takes a sub-range out of a list.
// Start counts from the end when negative; Count -1 means "up to the end".
// A Step above 1 decimates, a negative Step reads backwards.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: start; objectName: "Start"; min: -1000000; max: 1000000; init: 0 }
  IntSpinBox  { id: count; objectName: "Count"; min: -1; max: 1000000; init: -1 }
  IntSpinBox  { id: step; objectName: "Step"; min: -1000; max: 1000; init: 1 }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: lengthOut; objectName: "Length" }

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

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const l = asList(input.value);
    const n = l.length;
    var s = start.value;
    if (s < 0) s = Math.max(0, n + s);
    const st = (step.value === 0) ? 1 : step.value;
    const want = (count.value < 0) ? n : count.value;

    var out = [];
    for (var i = s, k = 0; k < want && i >= 0 && i < n; i += st, ++k)
      out.push(l[i]);

    output.value = out;
    lengthOut.value = out.length;
  }
}
