import Score 1.0

// Everything you usually want to know about a list of numbers.
// Chain it after Ring buffer to analyse a signal over a sliding window.
Script {
  ValueInlet  { id: input; objectName: "In" }
  Toggle      { id: ignoreBad; objectName: "Ignore non-numbers"; checked: true }
  ValueOutlet { id: lengthOut; objectName: "Length" }
  ValueOutlet { id: sumOut; objectName: "Sum" }
  ValueOutlet { id: meanOut; objectName: "Mean" }
  ValueOutlet { id: minOut; objectName: "Min" }
  ValueOutlet { id: maxOut; objectName: "Max" }
  ValueOutlet { id: medianOut; objectName: "Median" }
  ValueOutlet { id: devOut; objectName: "Deviation" }
  ValueOutlet { id: rmsOut; objectName: "RMS" }
  ValueOutlet { id: argMinOut; objectName: "Index of min" }
  ValueOutlet { id: argMaxOut; objectName: "Index of max" }

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
      if (typeof v.w === "number") out.push(v.w);
    }
    else out.push(v);
    return out;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const raw = flatten(input.value, []);
    var xs = [];
    for (var i = 0; i < raw.length; ++i) {
      const n = Number(raw[i]);
      if (isFinite(n)) xs.push(n);
      else if (!boolOf(ignoreBad)) xs.push(0.);
    }

    lengthOut.value = xs.length;
    if (xs.length === 0) {
      sumOut.value = 0.; meanOut.value = 0.; devOut.value = 0.; rmsOut.value = 0.;
      argMinOut.value = -1; argMaxOut.value = -1;
      return;
    }

    var sum = 0., sq = 0., lo = xs[0], hi = xs[0], iLo = 0, iHi = 0;
    for (var j = 0; j < xs.length; ++j) {
      const x = xs[j];
      sum += x; sq += x * x;
      if (x < lo) { lo = x; iLo = j; }
      if (x > hi) { hi = x; iHi = j; }
    }
    const mean = sum / xs.length;

    var variance = 0.;
    for (var k = 0; k < xs.length; ++k) {
      const d = xs[k] - mean;
      variance += d * d;
    }
    variance /= xs.length;

    const sorted = xs.slice().sort(function(a, b) { return a - b; });
    const mid = sorted.length >> 1;
    const median = (sorted.length % 2) ? sorted[mid] : 0.5 * (sorted[mid - 1] + sorted[mid]);

    sumOut.value = sum;
    meanOut.value = mean;
    minOut.value = lo;
    maxOut.value = hi;
    medianOut.value = median;
    devOut.value = Math.sqrt(variance);
    rmsOut.value = Math.sqrt(sq / xs.length);
    argMinOut.value = iLo;
    argMaxOut.value = iHi;
  }
}
