import Score 1.0

// Reads a value out of a table, with interpolation.
// The table can be typed in, or arrive on a cable — which lets any list become
// a transfer curve, a colour ramp, a scale, an envelope shape.
Script {
  ValueInlet  { id: input; objectName: "In" }
  ValueInlet  { id: tableIn; objectName: "Table" }
  LineEdit    { id: tableText; objectName: "Table (if unconnected)"; text: "0, 0.25, 1, 0.25, 0" }
  ComboBox    { id: addressing; objectName: "Input is"; choices: [ "Phase 0..1", "Index" ]; index: 0 }
  ComboBox    { id: interp; objectName: "Interpolation"; choices: [ "Linear", "Nearest", "Cubic" ]; index: 0 }
  ComboBox    { id: edges; objectName: "Edges"; choices: [ "Clamp", "Wrap", "Mirror" ]; index: 0 }
  ValueOutlet { id: output; objectName: "Out" }

  property var latchedTable: undefined

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
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function parseTable(text) {
    const parts = text.split(",");
    var r = [];
    for (var i = 0; i < parts.length; ++i) {
      const n = Number(parts[i].trim());
      if (isFinite(n)) r.push(n);
    }
    return r;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  tick: function(token, state) {
    if (typeof tableIn.value !== "undefined") {
      const t = asList(tableIn.value);
      if (t.length > 0) latchedTable = t;
    }
    if (typeof input.value === "undefined")
      return;

    const table = (latchedTable !== undefined) ? latchedTable : parseTable(str(tableText));
    const n = table.length;
    if (n === 0)
      return;

    const phaseMode = (choice(addressing) === "Phase 0..1");
    const mode = choice(interp);
    const edge = choice(edges);

    function at(i) {
      if (i >= 0 && i < n) return Number(table[i]) || 0.;
      if (edge === "Wrap") return Number(table[((i % n) + n) % n]) || 0.;
      if (edge === "Mirror" && n > 1) {
        const period = 2 * (n - 1);
        var k = ((i % period) + period) % period;
        if (k >= n) k = period - k;
        return Number(table[k]) || 0.;
      }
      return Number(table[Math.max(0, Math.min(n - 1, i))]) || 0.;
    }
    function cubic(y0, y1, y2, y3, t) {
      const a0 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3;
      const a1 = y0 - 2.5 * y1 + 2. * y2 - 0.5 * y3;
      const a2 = -0.5 * y0 + 0.5 * y2;
      return ((a0 * t + a1) * t + a2) * t + y1;
    }
    function read(x) {
      // Phase 0..1 spans the whole table; with Wrap, 1 comes back to the start.
      const u = phaseMode ? (x * ((edge === "Wrap") ? n : (n - 1))) : x;
      const i0 = Math.floor(u), f = u - i0;
      if (mode === "Nearest") return at(Math.round(u));
      if (mode === "Cubic") return cubic(at(i0 - 1), at(i0), at(i0 + 1), at(i0 + 2), f);
      return at(i0) + (at(i0 + 1) - at(i0)) * f;
    }

    const v = input.value;
    if (isList(v)) {
      const l = asList(v);
      var out = new Array(l.length);
      for (var i = 0; i < l.length; ++i) out[i] = read(Number(l[i]) || 0.);
      output.value = out;
    } else {
      output.value = read(Number(v) || 0.);
    }
  }
}
