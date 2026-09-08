import Score 1.0

// Remembers the last N values and hands them back as a list.
// This is what turns a stream into something you can look at: plot it, take
// its average, find its peaks, compare now against a moment ago.
Script {
  ValueInlet   { id: input; objectName: "In" }
  IntSpinBox   { id: size; objectName: "Size"; min: 1; max: 100000; init: 128 }
  ComboBox     { id: mode; objectName: "Record"; choices: [ "On new value", "Every tick", "Every N ms" ]; index: 0 }
  FloatSpinBox { id: period; objectName: "Period (ms)"; min: 1.; max: 600000.; init: 20. }
  Toggle       { id: fillFirst; objectName: "Prefill"; checked: true }
  Impulse      { id: clear; objectName: "Clear"; onImpulse: doClear = true }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: newest; objectName: "Newest" }
  ValueOutlet  { id: oldest; objectName: "Oldest" }
  ValueOutlet  { id: filled; objectName: "Filled" }

  property var buf: []
  property var lastValue: undefined
  property bool doClear: false
  property real lastWrite: -1e18

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

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (doClear) { doClear = false; buf = []; lastValue = undefined; }

    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const n = Math.max(1, size.value);
    const m = choice(mode);

    if (typeof input.value !== "undefined")
      lastValue = copyOf(input.value);

    var push = false;
    if (m === "On new value")      push = (typeof input.value !== "undefined");
    else if (m === "Every tick")   push = (lastValue !== undefined);
    else if (lastValue !== undefined && (t - lastWrite) >= period.value) {
      push = true;
      lastWrite = t;
    }

    if (!push)
      return;

    // Prefill so that downstream analysis sees a full window right away.
    if (boolOf(fillFirst) && buf.length === 0)
      for (var i = 0; i < n - 1; ++i) buf.push(lastValue);

    buf.push(lastValue);
    while (buf.length > n) buf.shift();

    output.value = buf.slice();
    newest.value = buf[buf.length - 1];
    oldest.value = buf[0];
    filled.value = buf.length / n;
  }
}
