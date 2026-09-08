import Score 1.0

// Sample & hold — latches the current input when banged, and keeps it.
// "Track" makes it follow the input again until the next bang.
Script {
  ValueInlet  { id: input; objectName: "In" }
  Impulse     { id: sample; objectName: "Sample"; onImpulse: pending++ }
  Toggle      { id: track; objectName: "Track"; checked: false }
  Toggle      { id: repeatOut; objectName: "Repeat every tick"; checked: false }
  Impulse     { id: clear; objectName: "Clear"; onImpulse: doClear = true }
  ValueOutlet { id: output; objectName: "Out" }

  property var held: undefined
  property int pending: 0
  property bool doClear: false

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

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (doClear) { doClear = false; held = undefined; }

    const live = (typeof input.value !== "undefined") ? input.value : undefined;

    if (boolOf(track) && live !== undefined) {
      held = copyOf(live);
      output.value = held;
      pending = 0;
      return;
    }

    while (pending > 0) {
      pending--;
      if (live !== undefined) {
        held = copyOf(live);
        output.value = held;
      }
    }

    if (boolOf(repeatOut) && held !== undefined)
      output.value = held;
  }
}
