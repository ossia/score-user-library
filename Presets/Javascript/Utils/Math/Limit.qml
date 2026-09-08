import Score 1.0

// Keeps a value inside a range, in one of three classic ways:
//   Clip  — anything outside sticks to the bound
//   Wrap  — leaving on one side comes back on the other (phase, hue, angle)
//   Fold  — bounces back inside (mirror)
// Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1. }
  ComboBox     { id: mode; objectName: "Mode"; choices: [ "Clip", "Wrap", "Fold" ]; index: 0 }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: outside; objectName: "Outside" }

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

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const a = Math.min(lo.value, hi.value);
    const b = Math.max(lo.value, hi.value);
    const span = b - a;
    const m = choice(mode);
    var wasOutside = false;

    output.value = mapv(input.value, function(x) {
      if (x < a || x > b) wasOutside = true;
      if (span <= 0.) return a;
      if (m === "Clip")
        return Math.max(a, Math.min(b, x));
      if (m === "Wrap")
        return a + (((x - a) % span) + span) % span;
      // Fold: wrap over twice the span, then mirror the upper half.
      const two = 2. * span;
      var u = (((x - a) % two) + two) % two;
      return a + (u > span ? two - u : u);
    });

    outside.value = wasOutside;
  }
}
