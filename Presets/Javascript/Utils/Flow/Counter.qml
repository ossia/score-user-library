import Score 1.0

// [counter] — counts bangs between Min and Max, and tells you when it wraps.
Script {
  Impulse     { id: bang; objectName: "Bang"; onImpulse: pending++ }
  IntSpinBox  { id: minv; objectName: "Min"; min: -1000000; max: 1000000; init: 0 }
  IntSpinBox  { id: maxv; objectName: "Max"; min: -1000000; max: 1000000; init: 15 }
  IntSpinBox  { id: step; objectName: "Step"; min: -1000000; max: 1000000; init: 1 }
  ComboBox    { id: mode; objectName: "At bounds"; choices: [ "Wrap", "Clamp", "Ping-pong" ]; index: 0 }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  ValueOutlet { id: output; objectName: "Count" }
  ValueOutlet { id: phase; objectName: "Phase" }
  ValueOutlet { id: carry; objectName: "Carry" }

  property int count: 0
  property int dir: 1
  property int pending: 0
  property bool doReset: true

  // Control ports only carry their value once execution has started.
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  tick: function(token, state) {
    const lo = Math.min(minv.value, maxv.value);
    const hi = Math.max(minv.value, maxv.value);
    const span = hi - lo + 1;

    function emit(c) {
      output.value = c;
      phase.value = span > 1 ? (c - lo) / (span - 1) : 0.;
    }

    if (doReset) {
      doReset = false; pending = 0; dir = 1;
      count = lo;
      emit(count);
    }

    const m = choice(mode);
    while (pending > 0) {
      pending--;
      var next = count + step.value * (m === "Ping-pong" ? dir : 1);
      var wrapped = (next > hi || next < lo);
      if (wrapped) {
        if (m === "Clamp") {
          next = Math.max(lo, Math.min(hi, next));
        } else if (m === "Ping-pong") {
          dir = -dir;
          next = Math.max(lo, Math.min(hi, count + step.value * dir));
        } else {
          next = lo + ((((next - lo) % span) + span) % span);
        }
      }
      count = next;
      emit(count);
      if (wrapped) carry.value = true;
    }
  }
}
