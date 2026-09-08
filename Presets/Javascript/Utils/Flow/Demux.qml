import Score 1.0

// [gate] with several outputs — sends the incoming value down one branch.
// Output 0 discards it.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSlider   { id: sel; objectName: "Output"; min: 0; max: 4; init: 1 }
  ValueOutlet { id: out1; objectName: "Out 1" }
  ValueOutlet { id: out2; objectName: "Out 2" }
  ValueOutlet { id: out3; objectName: "Out 3" }
  ValueOutlet { id: out4; objectName: "Out 4" }

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

  tick: function(token, state) {
    const outs = [ out1, out2, out3, out4 ];
    const k = sel.value - 1;
    if (k < 0 || k >= outs.length)
      return;
    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i)
      outs[k].addValue(msgs[i].t, msgs[i].v);
  }
}
