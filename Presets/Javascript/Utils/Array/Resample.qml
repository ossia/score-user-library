import Score 1.0

// Stretches or shrinks a list to a given number of points.
// Use it to match two lists that must line up, to reduce a heavy contour
// before sending it out, or to smooth a coarse envelope into a fine one.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: count; objectName: "Count"; min: 1; max: 100000; init: 64 }
  ComboBox    { id: interp; objectName: "Interpolation"; choices: [ "Linear", "Nearest", "Cubic" ]; index: 0 }
  Toggle      { id: loop; objectName: "Loop"; checked: false }
  ValueOutlet { id: output; objectName: "Out" }

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
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const src = asList(input.value);
    const n = src.length;
    const want = Math.max(1, count.value);
    if (n === 0) { output.value = []; return; }
    if (n === 1) {
      var flat = new Array(want);
      for (var f = 0; f < want; ++f) flat[f] = src[0];
      output.value = flat;
      return;
    }

    const mode = choice(interp);
    const wrap = boolOf(loop);
    // Points are the same objects when both lists are lists (interpolate per component).
    const vector = isList(src[0]);
    const dim = vector ? asList(src[0]).length : 1;

    function at(i) {
      const k = wrap ? (((i % n) + n) % n) : Math.max(0, Math.min(n - 1, i));
      return vector ? asList(src[k]) : [ Number(src[k]) || 0. ];
    }
    function cubic(y0, y1, y2, y3, t) {
      // Catmull-Rom
      const a0 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3;
      const a1 = y0 - 2.5 * y1 + 2. * y2 - 0.5 * y3;
      const a2 = -0.5 * y0 + 0.5 * y2;
      return ((a0 * t + a1) * t + a2) * t + y1;
    }

    // With Loop on, position "want" maps back to position 0.
    const span = wrap ? n : (n - 1);
    const div = wrap ? want : Math.max(1, want - 1);

    var out = new Array(want);
    for (var o = 0; o < want; ++o) {
      const u = (o / div) * span;
      const i0 = Math.floor(u);
      const t = u - i0;

      var comp = new Array(dim);
      for (var d = 0; d < dim; ++d) {
        if (mode === "Nearest") {
          comp[d] = at(Math.round(u))[d];
        } else if (mode === "Cubic") {
          comp[d] = cubic(at(i0 - 1)[d], at(i0)[d], at(i0 + 1)[d], at(i0 + 2)[d], t);
        } else {
          const y1 = at(i0)[d], y2 = at(i0 + 1)[d];
          comp[d] = y1 + (y2 - y1) * t;
        }
      }
      out[o] = vector ? comp : comp[0];
    }
    output.value = out;
  }
}
