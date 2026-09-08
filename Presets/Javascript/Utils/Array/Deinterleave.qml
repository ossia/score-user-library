import Score 1.0

// The reverse of Interleave: pulls one stream out of every N elements.
// Feed it [x, y, x, y, ...] with Streams = 2 to get the X list and the Y list.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSlider   { id: count; objectName: "Streams"; min: 1; max: 4; init: 2 }
  ValueOutlet { id: out1; objectName: "Out 1" }
  ValueOutlet { id: out2; objectName: "Out 2" }
  ValueOutlet { id: out3; objectName: "Out 3" }
  ValueOutlet { id: out4; objectName: "Out 4" }
  ValueOutlet { id: framesOut; objectName: "Frames" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    return [ v ];
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const outs = [ out1, out2, out3, out4 ];
    const l = asList(input.value);
    const n = Math.max(1, Math.min(count.value, outs.length));

    for (var s = 0; s < n; ++s) {
      var part = [];
      for (var i = s; i < l.length; i += n)
        part.push(l[i]);
      outs[s].value = part;
    }
    framesOut.value = Math.ceil(l.length / n);
  }
}
