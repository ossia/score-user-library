import Score 1.0

// Tells you when a stream has stopped arriving, and can substitute a fallback.
// Essential for anything fed by a sensor, a camera or a remote machine.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: timeout; objectName: "Timeout (ms)"; min: 1.; max: 600000.; init: 1000. }
  LineEdit     { id: fallback; objectName: "Fallback (JSON)"; text: "0" }
  Toggle       { id: emitFallback; objectName: "Emit fallback"; checked: true }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: alive; objectName: "Alive" }
  ValueOutlet  { id: silence; objectName: "Silence (ms)" }

  property real lastSeen: -1.
  property bool wasAlive: false
  property bool started: false

  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function nowMs(token, state) {
    return 1000. * (token.date * state.model_to_physical) / state.sample_rate;
  }
  function parseFallback() {
    const t = str(fallback);
    try { return JSON.parse(t); } catch (e) { return t; }
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const now = nowMs(token, state);
    if (!started) { started = true; lastSeen = now; }

    if (typeof input.value !== "undefined") {
      lastSeen = now;
      output.value = input.value;
    }

    const dt = now - lastSeen;
    silence.value = dt;

    const isAlive = dt < timeout.value;
    if (isAlive !== wasAlive) {
      wasAlive = isAlive;
      alive.value = isAlive;
      if (!isAlive && boolOf(emitFallback))
        output.value = parseFallback();
    }
  }
}
