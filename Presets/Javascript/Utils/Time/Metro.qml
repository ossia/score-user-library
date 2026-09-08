import Score 1.0

// A clock: emits a bang at a regular interval.
// Bangs are placed at their exact sample position inside the buffer rather than
// at the start of the tick, so the timing does not drift with the buffer size.
// The interval can be given in milliseconds, or in beats of the score tempo.
Script {
  Toggle       { id: active; objectName: "Active"; checked: true }
  ComboBox     { id: unit; objectName: "Unit"; choices: [ "Milliseconds", "Beats" ]; index: 0 }
  FloatSpinBox { id: interval; objectName: "Interval (ms)"; min: 1.; max: 600000.; init: 500. }
  FloatSpinBox { id: beats; objectName: "Interval (beats)"; min: 0.015625; max: 64.; init: 1. }
  FloatSlider  { id: swing; objectName: "Swing"; min: 0.; max: 0.9; init: 0. }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  ValueOutlet  { id: bang; objectName: "Bang" }
  ValueOutlet  { id: count; objectName: "Count" }
  ValueOutlet  { id: phase; objectName: "Phase" }

  property real nextAt: 0.
  property int ticks: 0
  property bool doReset: true

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const toMs = 1000. * state.model_to_physical / state.sample_rate;
    const t0 = token.previous_date * toMs;
    const t1 = token.date * toMs;

    if (doReset) { doReset = false; ticks = 0; nextAt = t0; }
    if (!boolOf(active)) { nextAt = Math.max(nextAt, t1); return; }

    // In "Beats" mode the period follows the score tempo, so it stays in sync
    // when the tempo changes.
    var period;
    if (choice(unit) === "Beats") {
      const tempo = (token.tempo > 0.) ? token.tempo : 120.;
      period = beats.value * 60000. / tempo;
    } else {
      period = interval.value;
    }
    period = Math.max(0.01, period);

    const tm = state.timings(token);
    const span = Math.max(1e-9, t1 - t0);

    var guard = 0;
    while (nextAt < t1 && guard++ < 1024) {
      if (nextAt >= t0) {
        // Where inside this buffer the bang falls.
        const frac = (nextAt - t0) / span;
        const at = tm.start_sample + Math.floor(frac * Math.max(0, tm.length));
        bang.addValue(at, true);
        count.addValue(at, ticks);
        ticks++;
      }
      // Odd beats are pushed late when swing is on.
      const shift = ((ticks % 2) === 1) ? (1. + swing.value) : (1. - swing.value);
      nextAt += period * shift;
    }

    phase.value = Math.max(0., Math.min(1., 1. - (nextAt - t1) / period));
  }
}
