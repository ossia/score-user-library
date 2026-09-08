import Score 1.0

// Emits the last value received once the input has been quiet for a while.
// The classic way to wait for a gesture to settle before acting on it.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: quiet; objectName: "Quiet time (ms)"; min: 0.; max: 600000.; init: 200. }
  Toggle       { id: leading; objectName: "Also emit first"; checked: false }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: settling; objectName: "Settling" }

  property var pendingValue: undefined
  property real lastSeen: 0.
  property bool armed: false

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
  function nowMs(token, state) {
    return 1000. * (token.date * state.model_to_physical) / state.sample_rate;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const now = nowMs(token, state);

    if (typeof input.value !== "undefined") {
      if (!armed) {
        if (boolOf(leading))
          output.value = input.value;
        settling.value = true;
      }
      pendingValue = copyOf(input.value);
      lastSeen = now;
      armed = true;
      return;
    }

    if (armed && (now - lastSeen) >= quiet.value) {
      armed = false;
      settling.value = false;
      if (pendingValue !== undefined)
        output.value = pendingValue;
      pendingValue = undefined;
    }
  }
}
