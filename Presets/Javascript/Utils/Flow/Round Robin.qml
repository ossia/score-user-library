import Score 1.0

// Spreads successive incoming values over N outputs, one after the other.
// The usual way to hand events out to a pool of voices / layers / fixtures.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSlider   { id: count; objectName: "Outputs"; min: 1; max: 4; init: 4 }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: cursor = 0 }
  ValueOutlet { id: out1; objectName: "Out 1" }
  ValueOutlet { id: out2; objectName: "Out 2" }
  ValueOutlet { id: out3; objectName: "Out 3" }
  ValueOutlet { id: out4; objectName: "Out 4" }
  ValueOutlet { id: index; objectName: "Index" }

  property int cursor: 0

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
    const n = Math.max(1, Math.min(count.value, outs.length));
    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i) {
      const k = cursor % n;
      outs[k].addValue(msgs[i].t, msgs[i].v);
      index.addValue(msgs[i].t, k + 1);
      cursor = (cursor + 1) % n;
    }
  }
}
