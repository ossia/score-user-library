import Score 1.0

// Finds the local maxima of a list: where the bumps are and how tall.
// Point it at a spectrum, a histogram, a scan line or a recorded gesture.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: minHeight; objectName: "Min height"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: prominence; objectName: "Min prominence"; min: 0.; max: 1000000.; init: 0. }
  IntSpinBox   { id: minDistance; objectName: "Min distance"; min: 1; max: 100000; init: 1 }
  IntSpinBox   { id: maxCount; objectName: "Max peaks"; min: 1; max: 10000; init: 16 }
  Toggle       { id: troughs; objectName: "Find troughs"; checked: false }
  ValueOutlet  { id: indicesOut; objectName: "Indices" }
  ValueOutlet  { id: valuesOut; objectName: "Values" }
  ValueOutlet  { id: countOut; objectName: "Count" }
  ValueOutlet  { id: bestOut; objectName: "Strongest" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asNumbers(v) {
    if (!isList(v)) return [];
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) {
      const n = Number(v[i]);
      r[i] = isFinite(n) ? n : 0.;
    }
    return r;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    var xs = asNumbers(input.value);
    if (xs.length < 3) { indicesOut.value = []; valuesOut.value = []; countOut.value = 0; return; }

    const flip = boolOf(troughs);
    if (flip) for (var f = 0; f < xs.length; ++f) xs[f] = -xs[f];
    const floorH = flip ? -minHeight.value : minHeight.value;

    // Candidate peaks: strictly higher than the previous sample, and not lower
    // than the next one (so flat tops are caught once, on their left edge).
    var cand = [];
    for (var i = 1; i < xs.length - 1; ++i) {
      if (xs[i] > xs[i - 1] && xs[i] >= xs[i + 1] && xs[i] >= floorH)
        cand.push(i);
    }

    // Prominence: how far down you must go before reaching higher ground.
    if (prominence.value > 0.) {
      var kept = [];
      for (var c = 0; c < cand.length; ++c) {
        const k = cand[c];
        var left = xs[k], j;
        for (j = k - 1; j >= 0 && xs[j] <= xs[k]; --j) left = Math.min(left, xs[j]);
        var right = xs[k];
        for (j = k + 1; j < xs.length && xs[j] <= xs[k]; ++j) right = Math.min(right, xs[j]);
        if (xs[k] - Math.max(left, right) >= prominence.value)
          kept.push(k);
      }
      cand = kept;
    }

    // Keep the tallest first, then drop anything too close to an accepted peak.
    cand.sort(function(a, b) { return xs[b] - xs[a]; });
    var chosen = [];
    for (var p = 0; p < cand.length && chosen.length < maxCount.value; ++p) {
      var ok = true;
      for (var q = 0; q < chosen.length; ++q) {
        if (Math.abs(cand[p] - chosen[q]) < minDistance.value) { ok = false; break; }
      }
      if (ok) chosen.push(cand[p]);
    }

    const strongest = (chosen.length > 0) ? chosen[0] : -1;
    chosen.sort(function(a, b) { return a - b; });

    var vals = new Array(chosen.length);
    for (var r = 0; r < chosen.length; ++r)
      vals[r] = flip ? -xs[chosen[r]] : xs[chosen[r]];

    indicesOut.value = chosen;
    valuesOut.value = vals;
    countOut.value = chosen.length;
    bestOut.value = strongest;
  }
}
