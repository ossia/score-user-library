import Score 1.0

// [speedlim] — never lets more than one value per interval through.
//  * Drop   : anything arriving too early is thrown away.
//  * Latest : the most recent value waits and is emitted at the next slot.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: interval; objectName: "Interval (ms)"; min: 0.; max: 600000.; init: 50. }
  ComboBox     { id: mode; objectName: "Mode"; choices: [ "Latest", "Drop" ]; index: 0 }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: dropped; objectName: "Dropped" }

  property var pendingValue: undefined
  property real lastSent: -1e18
  property int nbDropped: 0

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function copyOf(v) {
    if (!isList(v)) return v;
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) r[i] = copyOf(v[i]);
    return r;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  // Date of this tick, in milliseconds of wall time.
  function nowMs(token, state) {
    return 1000. * (token.date * state.model_to_physical) / state.sample_rate;
  }

  tick: function(token, state) {
    const now = nowMs(token, state);
    const gap = Math.max(0., interval.value);
    const drop = (choice(mode) === "Drop");

    if (typeof input.value !== "undefined") {
      if (now - lastSent >= gap) {
        lastSent = now;
        output.value = input.value;
        pendingValue = undefined;
      } else if (drop) {
        nbDropped++;
        dropped.value = nbDropped;
      } else {
        pendingValue = copyOf(input.value);
      }
    } else if (pendingValue !== undefined && now - lastSent >= gap) {
      lastSent = now;
      output.value = pendingValue;
      pendingValue = undefined;
    }
  }
}
