import Score 1.0

// Passes one event out of every N — a clock divider.
// Chain a few after a metro to get a whole rhythmic hierarchy out of one clock.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: divide; objectName: "Divide by"; min: 1; max: 10000; init: 4 }
  IntSpinBox  { id: offset; objectName: "Offset"; min: 0; max: 10000; init: 0 }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: { counter = 0; passed = 0; } }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: other; objectName: "Others" }
  ValueOutlet { id: countOut; objectName: "Count" }

  property int counter: 0
  property int passed: 0

  function incoming(inl) {
    var vs = inl.values, out = [];
    if (vs && typeof vs.length === "number" && vs.length > 0) {
      var ok = true;
      for (var i = 0; i < vs.length; ++i) {
        var m = vs[i];
        if (m === null || typeof m !== "object" || typeof m.timestamp !== "number") { ok = false; break; }
        out.push({ t: m.timestamp, v: m.value });
      }
      if (ok) return out;
    }
    return (typeof inl.value !== "undefined") ? [ { t: 0, v: inl.value } ] : [];
  }

  tick: function(token, state) {
    const n = Math.max(1, divide.value);
    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i) {
      if (((counter + offset.value) % n) === 0) {
        output.addValue(msgs[i].t, msgs[i].v);
        countOut.addValue(msgs[i].t, passed);
        passed++;
      } else {
        other.addValue(msgs[i].t, msgs[i].v);
      }
      counter++;
    }
  }
}
