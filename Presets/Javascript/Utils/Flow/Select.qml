import Score 1.0

// [select] / [route] — compares the input against a list of targets.
// Emits the match on "Out", its rank on "Index", and anything else on "Reject".
Script {
  ValueInlet  { id: input; objectName: "In" }
  LineEdit    { id: targets; objectName: "Targets"; text: "0, 1, 2" }
  Toggle      { id: numeric; objectName: "Compare as numbers"; checked: true }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: index; objectName: "Index" }
  ValueOutlet { id: reject; objectName: "Reject" }

  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }

  function parseTargets() {
    const parts = str(targets).split(",");
    var r = [];
    for (var i = 0; i < parts.length; ++i) {
      const t = parts[i].trim();
      if (t.length === 0) continue;
      r.push(t);
    }
    return r;
  }

  function matches(v, target, asNumber) {
    if (asNumber) {
      const a = Number(v), b = Number(target);
      if (isFinite(a) && isFinite(b)) return a === b;
    }
    return String(v) === target;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const v = input.value;
    const list = parseTargets();
    const asNumber = boolOf(numeric);

    for (var i = 0; i < list.length; ++i) {
      if (matches(v, list[i], asNumber)) {
        index.value = i;
        output.value = v;
        return;
      }
    }
    index.value = -1;
    reject.value = v;
  }
}
