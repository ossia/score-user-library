import Score 1.0

// Where the playhead is inside the interval that holds this process.
// Drop it into any interval and its whole timeline becomes a value you can
// route anywhere: 0 at the start, 1 at the end.
Script {
  FloatSlider { id: from; objectName: "From"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSlider { id: to; objectName: "To"; min: -1000000.; max: 1000000.; init: 1. }
  ComboBox    { id: shape; objectName: "Shape"; choices: [ "Linear", "Smooth", "Triangle", "Sine" ]; index: 0 }
  ValueOutlet { id: posOut; objectName: "Position" }
  ValueOutlet { id: valueOut; objectName: "Value" }
  ValueOutlet { id: dateOut; objectName: "Date (ms)" }
  ValueOutlet { id: durationOut; objectName: "Duration (ms)" }
  ValueOutlet { id: remainingOut; objectName: "Remaining (ms)" }
  ValueOutlet { id: speedOut; objectName: "Speed" }

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  tick: function(token, state) {
    const toMs = 1000. * state.model_to_physical / state.sample_rate;
    const date = token.date * toMs;
    const dur = token.parent_duration * toMs;

    var p = token.position();
    if (!isFinite(p)) p = 0.;
    p = Math.max(0., Math.min(1., p));

    var u;
    switch (choice(shape)) {
      case "Smooth":   u = p * p * (3. - 2. * p); break;
      // Goes up then back down over the interval.
      case "Triangle": u = 1. - Math.abs(2. * p - 1.); break;
      case "Sine":     u = 0.5 - 0.5 * Math.cos(p * 2. * Math.PI); break;
      default:         u = p; break;
    }

    posOut.value = p;
    valueOut.value = from.value + u * (to.value - from.value);
    dateOut.value = date;
    durationOut.value = isFinite(dur) ? dur : -1.;
    remainingOut.value = isFinite(dur) ? Math.max(0., dur - date) : -1.;
    speedOut.value = token.speed;
  }
}
