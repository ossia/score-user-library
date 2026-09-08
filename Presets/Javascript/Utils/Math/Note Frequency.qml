import Score 1.0

// [mtof] / [ftom] — MIDI note numbers to hertz and back.
// Also useful far outside music: it is the standard way to spread values
// geometrically rather than linearly.  Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  ComboBox     { id: dir; objectName: "Direction"; choices: [ "Note to Hz", "Hz to note" ]; index: 0 }
  FloatSpinBox { id: tuning; objectName: "A4 (Hz)"; min: 200.; max: 600.; init: 440. }
  IntSpinBox   { id: edo; objectName: "Steps per octave"; min: 1; max: 128; init: 12 }
  Toggle       { id: snap; objectName: "Snap to step"; checked: false }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: name; objectName: "Note name" }

  readonly property var names: [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function mapv(v, f) {
    if (isList(v)) {
      var r = new Array(v.length);
      for (var i = 0; i < v.length; ++i) r[i] = mapv(v[i], f);
      return r;
    }
    const n = Number(v);
    return isFinite(n) ? f(n) : v;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function noteName(n) {
    const k = Math.round(n);
    const pc = ((k % 12) + 12) % 12;
    return names[pc] + String(Math.floor(k / 12) - 1);
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const a4 = tuning.value;
    const steps = Math.max(1, edo.value);
    const toHz = (choice(dir) === "Note to Hz");
    const doSnap = boolOf(snap);
    var firstNote = undefined;

    output.value = mapv(input.value, function(x) {
      if (toHz) {
        const n = doSnap ? Math.round(x) : x;
        if (firstNote === undefined) firstNote = n;
        return a4 * Math.pow(2., (n - 69.) / steps);
      }
      if (x <= 0.) return 0.;
      var n2 = 69. + steps * Math.log(x / a4) / Math.LN2;
      if (doSnap) n2 = Math.round(n2);
      if (firstNote === undefined) firstNote = n2;
      return n2;
    });

    if (firstNote !== undefined && steps === 12)
      name.value = noteName(firstNote);
  }
}
