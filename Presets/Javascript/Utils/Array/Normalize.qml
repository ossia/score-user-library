import Score 1.0

// Rescales a whole list at once, so that it fits a known range.
//   Min-max   : the smallest becomes 0, the largest 1
//   Sum       : the elements add up to 1 (a probability distribution)
//   Peak      : the largest magnitude becomes 1
//   Z-score   : mean 0, deviation 1
//   Unit      : the list read as a vector gets length 1
Script {
  ValueInlet  { id: input; objectName: "In" }
  ComboBox    { id: mode; objectName: "Mode"
                choices: [ "Min-max", "Sum", "Peak", "Z-score", "Unit vector" ]; index: 0 }
  Toggle      { id: signed; objectName: "Output -1..1"; checked: false }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: scaleOut; objectName: "Applied scale" }

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

    const raw = asList(input.value);
    var xs = new Array(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      const n = Number(raw[i]);
      xs[i] = isFinite(n) ? n : 0.;
    }
    if (xs.length === 0) { output.value = []; return; }

    var lo = xs[0], hi = xs[0], sum = 0., sq = 0., peak = 0.;
    for (var j = 0; j < xs.length; ++j) {
      if (xs[j] < lo) lo = xs[j];
      if (xs[j] > hi) hi = xs[j];
      sum += xs[j];
      sq += xs[j] * xs[j];
      peak = Math.max(peak, Math.abs(xs[j]));
    }
    const mean = sum / xs.length;

    var out = new Array(xs.length);
    var applied = 1.;

    switch (choice(mode)) {
      case "Sum": {
        applied = (sum !== 0.) ? 1. / sum : 0.;
        for (var k = 0; k < xs.length; ++k) out[k] = xs[k] * applied;
        break;
      }
      case "Peak": {
        applied = (peak > 0.) ? 1. / peak : 0.;
        for (var m = 0; m < xs.length; ++m) out[m] = xs[m] * applied;
        break;
      }
      case "Z-score": {
        var variance = 0.;
        for (var p = 0; p < xs.length; ++p) { const d = xs[p] - mean; variance += d * d; }
        variance /= xs.length;
        const sd = Math.sqrt(variance);
        applied = (sd > 0.) ? 1. / sd : 0.;
        for (var q = 0; q < xs.length; ++q) out[q] = (xs[q] - mean) * applied;
        break;
      }
      case "Unit vector": {
        const L = Math.sqrt(sq);
        applied = (L > 0.) ? 1. / L : 0.;
        for (var r = 0; r < xs.length; ++r) out[r] = xs[r] * applied;
        break;
      }
      default: {
        const span = hi - lo;
        applied = (span > 0.) ? 1. / span : 0.;
        for (var s = 0; s < xs.length; ++s)
          out[s] = (span > 0.) ? (xs[s] - lo) * applied : 0.;
        break;
      }
    }

    if (boolOf(signed) && choice(mode) === "Min-max")
      for (var t = 0; t < out.length; ++t) out[t] = out[t] * 2. - 1.;

    output.value = out;
    scaleOut.value = applied;
  }
}
