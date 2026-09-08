import Score 1.0

// Counts how many values fall into each slice of a range.
// Drives a level display, tells you how a tracked crowd is spread out,
// or feeds a shader that wants a distribution rather than raw samples.
Script {
  ValueInlet   { id: input; objectName: "In" }
  IntSpinBox   { id: bins; objectName: "Bins"; min: 1; max: 4096; init: 16 }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1. }
  Toggle       { id: autoRange; objectName: "Auto range"; checked: false }
  ComboBox     { id: norm; objectName: "Scaling"; choices: [ "Counts", "Fraction", "Peak" ]; index: 0 }
  ValueOutlet  { id: output; objectName: "Bins" }
  ValueOutlet  { id: centersOut; objectName: "Centers" }
  ValueOutlet  { id: peakOut; objectName: "Peak bin" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function flatten(v, out) {
    if (isList(v)) { for (var i = 0; i < v.length; ++i) flatten(v[i], out); }
    else if (v !== null && typeof v === "object" && typeof v.x === "number") {
      out.push(v.x, v.y);
      if (typeof v.z === "number") out.push(v.z);
    }
    else { const n = Number(v); if (isFinite(n)) out.push(n); }
    return out;
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

    const xs = flatten(input.value, []);
    const nb = Math.max(1, bins.value);
    var a = lo.value, b = hi.value;

    if (boolOf(autoRange) && xs.length > 0) {
      a = xs[0]; b = xs[0];
      for (var i = 0; i < xs.length; ++i) { if (xs[i] < a) a = xs[i]; if (xs[i] > b) b = xs[i]; }
    }
    if (b <= a) b = a + 1e-9;

    var counts = new Array(nb), centers = new Array(nb);
    for (var k = 0; k < nb; ++k) {
      counts[k] = 0;
      centers[k] = a + (b - a) * (k + 0.5) / nb;
    }

    for (var j = 0; j < xs.length; ++j) {
      var idx = Math.floor((xs[j] - a) / (b - a) * nb);
      if (idx < 0) idx = 0;
      if (idx >= nb) idx = nb - 1;
      counts[idx]++;
    }

    var peak = 0, peakIdx = 0;
    for (var m = 0; m < nb; ++m)
      if (counts[m] > peak) { peak = counts[m]; peakIdx = m; }

    const scaling = choice(norm);
    if (scaling === "Fraction" && xs.length > 0)
      for (var p = 0; p < nb; ++p) counts[p] = counts[p] / xs.length;
    else if (scaling === "Peak" && peak > 0)
      for (var q = 0; q < nb; ++q) counts[q] = counts[q] / peak;

    output.value = counts;
    centersOut.value = centers;
    peakOut.value = peakIdx;
  }
}
