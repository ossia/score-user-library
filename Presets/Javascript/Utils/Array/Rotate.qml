import Score 1.0

// Shifts the elements of a list around, and optionally reverses it.
// Animate "Shift" and any list turns into a chase / marquee.
Script {
  ValueInlet  { id: input; objectName: "In" }
  ValueInlet  { id: shiftIn; objectName: "Shift" }
  IntSpinBox  { id: shift; objectName: "Shift (if unconnected)"; min: -1000000; max: 1000000; init: 1 }
  Toggle      { id: reverse; objectName: "Reverse"; checked: false }
  ComboBox    { id: mode; objectName: "Edges"; choices: [ "Wrap", "Drop", "Pad" ]; index: 0 }
  FloatSpinBox { id: pad; objectName: "Padding"; min: -1000000.; max: 1000000.; init: 0. }
  ValueOutlet { id: output; objectName: "Out" }

  property var latchedShift: undefined

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
    if (typeof shiftIn.value !== "undefined") {
      const s = Number(isList(shiftIn.value) ? shiftIn.value[0] : shiftIn.value);
      if (isFinite(s)) latchedShift = Math.round(s);
    }
    if (typeof input.value === "undefined")
      return;

    var l = asList(input.value);
    if (boolOf(reverse)) l = l.slice().reverse();

    const n = l.length;
    if (n === 0) { output.value = []; return; }

    const k = (latchedShift !== undefined) ? latchedShift : shift.value;
    const m = choice(mode);
    var out = new Array(n);

    for (var i = 0; i < n; ++i) {
      // out[i] comes from l[i - k], so a positive shift moves elements right.
      var src = i - k;
      if (src < 0 || src >= n) {
        if (m === "Wrap") src = ((src % n) + n) % n;
        else { out[i] = pad.value; continue; }
      }
      out[i] = l[src];
    }

    if (m === "Drop") {
      const lo = Math.max(0, k), hi = Math.min(n, n + k);
      out = (lo < hi) ? out.slice(lo, hi) : [];
    }
    output.value = out;
  }
}
