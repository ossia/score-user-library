import Score 1.0

// Weaves several lists together: A B C A B C ...
// The classic way to turn separate coordinate streams into vertex data,
// or separate channels into an interleaved frame.
Script {
  ValueInlet  { id: in1; objectName: "In 1" }
  ValueInlet  { id: in2; objectName: "In 2" }
  ValueInlet  { id: in3; objectName: "In 3" }
  ValueInlet  { id: in4; objectName: "In 4" }
  IntSlider   { id: count; objectName: "Streams"; min: 1; max: 4; init: 2 }
  ComboBox    { id: lengthMode; objectName: "Length"; choices: [ "Shortest", "Longest (cycle)", "Longest (pad)" ]; index: 0 }
  FloatSpinBox { id: pad; objectName: "Padding"; min: -1000000.; max: 1000000.; init: 0. }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: framesOut; objectName: "Frames" }

  property var held: [ undefined, undefined, undefined, undefined ]

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
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  tick: function(token, state) {
    const ins = [ in1, in2, in3, in4 ];
    var touched = false;
    for (var i = 0; i < ins.length; ++i) {
      if (typeof ins[i].value !== "undefined") { held[i] = asList(ins[i].value); touched = true; }
    }
    if (!touched)
      return;

    const n = Math.max(1, Math.min(count.value, ins.length));
    var lists = [];
    for (var j = 0; j < n; ++j)
      lists.push(held[j] !== undefined ? held[j] : []);

    var frames = lists[0].length;
    const m = choice(lengthMode);
    for (var k = 1; k < lists.length; ++k)
      frames = (m === "Shortest") ? Math.min(frames, lists[k].length)
                                  : Math.max(frames, lists[k].length);

    var out = [];
    for (var f = 0; f < frames; ++f) {
      for (var s = 0; s < lists.length; ++s) {
        const L = lists[s];
        if (L.length === 0) { out.push(pad.value); continue; }
        if (f < L.length) out.push(L[f]);
        else out.push(m === "Longest (cycle)" ? L[f % L.length] : pad.value);
      }
    }

    output.value = out;
    framesOut.value = frames;
  }
}
