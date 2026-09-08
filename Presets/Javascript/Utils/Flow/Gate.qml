import Score 1.0

// [gate] — lets values through only while "Open" is on.
// Keeps the sub-tick timestamp of every message.
Script {
  ValueInlet  { id: input; objectName: "In" }
  Toggle      { id: open; objectName: "Open"; checked: true }
  Toggle      { id: invert; objectName: "Invert"; checked: false }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: blocked; objectName: "Blocked" }

  function incoming(inl) {
    var vs = inl.values, out = [];
    if (vs && typeof vs.length === "number" && vs.length > 0) {
      var ok = true;
      for (var i = 0; i < vs.length; ++i) {
        var m = vs[i];
        if (m === null || typeof m !== "object" || typeof m.timestamp !== "number") { ok = false; break; }
        out.push({ t: m.timestamp, v: m.value });
      }
      if (ok) return out;
    }
    return (typeof inl.value !== "undefined") ? [ { t: 0, v: inl.value } ] : [];
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const pass = boolOf(invert) ? !boolOf(open) : !!boolOf(open);
    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i) {
      if (pass)
        output.addValue(msgs[i].t, msgs[i].v);
      else
        blocked.addValue(msgs[i].t, msgs[i].v);
    }
  }
}
