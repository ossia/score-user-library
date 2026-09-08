import Score 1.0

// Snaps values onto a grid — for stepped faders, pixel snapping,
// scale degrees, integer indices...
// Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: step; objectName: "Step"; min: 0.; max: 1000000.; init: 0.1 }
  FloatSpinBox { id: offset; objectName: "Offset"; min: -1000000.; max: 1000000.; init: 0. }
  ComboBox     { id: mode; objectName: "Rounding"; choices: [ "Nearest", "Down", "Up", "Toward zero" ]; index: 0 }
  Toggle       { id: asIndex; objectName: "Output step index"; checked: false }
  ValueOutlet  { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function mapv(v, f) {
    if (isList(v)) {
      var r = new Array(v.length);
      for (var i = 0; i < v.length; ++i) r[i] = mapv(v[i], f);
      return r;
    }
    const n = Number(v);
    return isFinite(n) ? f(n) : v;
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

    const s = step.value;
    const off = offset.value;
    const m = choice(mode);
    const wantIndex = boolOf(asIndex);

    output.value = mapv(input.value, function(x) {
      if (s <= 0.) return wantIndex ? 0 : x;
      const u = (x - off) / s;
      var k;
      if (m === "Down") k = Math.floor(u);
      else if (m === "Up") k = Math.ceil(u);
      else if (m === "Toward zero") k = (u < 0) ? Math.ceil(u) : Math.floor(u);
      else k = Math.round(u);
      return wantIndex ? k : off + k * s;
    });
  }
}
