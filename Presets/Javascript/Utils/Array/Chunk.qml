import Score 1.0

// Cuts a flat list into groups of N.
// [x, y, x, y, ...] with Size 2 becomes [[x, y], [x, y], ...] — the shape most
// point-consuming nodes expect.
Script {
  ValueInlet   { id: input; objectName: "In" }
  IntSpinBox   { id: size; objectName: "Size"; min: 1; max: 100000; init: 2 }
  IntSpinBox   { id: hop; objectName: "Hop"; min: 0; max: 100000; init: 0 }
  ComboBox     { id: tail; objectName: "Last group"; choices: [ "Drop", "Keep", "Pad" ]; index: 0 }
  FloatSpinBox { id: pad; objectName: "Padding"; min: -1000000.; max: 1000000.; init: 0. }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: countOut; objectName: "Groups" }

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

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const l = asList(input.value);
    const s = Math.max(1, size.value);
    // Hop 0 means "no overlap": step by a whole group.
    const h = (hop.value > 0) ? hop.value : s;
    const m = choice(tail);

    var out = [];
    for (var i = 0; i < l.length; i += h) {
      var g = l.slice(i, i + s);
      if (g.length < s) {
        if (m === "Drop") break;
        if (m === "Pad") while (g.length < s) g.push(pad.value);
      }
      out.push(g);
      if (i + s >= l.length) break;
    }

    output.value = out;
    countOut.value = out.length;
  }
}
