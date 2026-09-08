import Score 1.0

// Blends between two values or two lists.
// Works on anything numeric: positions, colours, envelopes, whole point clouds.
// Lists of different lengths are matched by resampling B onto A.
Script {
  ValueInlet  { id: inA; objectName: "A" }
  ValueInlet  { id: inB; objectName: "B" }
  ValueInlet  { id: mixIn; objectName: "Mix" }
  FloatSlider { id: mix; objectName: "Mix (if unconnected)"; min: 0.; max: 1.; init: 0.5 }
  ComboBox    { id: curve; objectName: "Curve"; choices: [ "Linear", "Equal power", "Smooth" ]; index: 0 }
  ValueOutlet { id: output; objectName: "Out" }

  property var latchedA: undefined
  property var latchedB: undefined
  property var latchedMix: undefined

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
  // Reads list l at a fractional position, so it can be stretched onto another.
  function sampleAt(l, u) {
    if (l.length === 0) return 0.;
    if (l.length === 1) return l[0];
    const p = u * (l.length - 1);
    const i = Math.floor(p), f = p - i;
    const y1 = l[Math.min(i, l.length - 1)];
    const y2 = l[Math.min(i + 1, l.length - 1)];
    if (isList(y1) || isList(y2)) return f < 0.5 ? y1 : y2;
    const n1 = Number(y1) || 0., n2 = Number(y2) || 0.;
    return n1 + (n2 - n1) * f;
  }
  function blend(a, b, ga, gb) {
    if (isList(a) || isList(b)) {
      const la = asList(a), lb = asList(b);
      const n = Math.max(la.length, lb.length);
      var out = new Array(n);
      for (var i = 0; i < n; ++i) {
        const u = (n === 1) ? 0. : i / (n - 1);
        out[i] = blend(sampleAt(la, u), sampleAt(lb, u), ga, gb);
      }
      return out;
    }
    return (Number(a) || 0.) * ga + (Number(b) || 0.) * gb;
  }

  tick: function(token, state) {
    if (typeof inA.value !== "undefined") latchedA = copyOf(inA.value);
    if (typeof inB.value !== "undefined") latchedB = copyOf(inB.value);
    if (typeof mixIn.value !== "undefined") {
      const mv = Number(isList(mixIn.value) ? mixIn.value[0] : mixIn.value);
      if (isFinite(mv)) latchedMix = mv;
    }
    if (latchedA === undefined || latchedB === undefined)
      return;

    var k = (latchedMix !== undefined) ? latchedMix : mix.value;
    k = Math.max(0., Math.min(1., k));

    var ga, gb;
    switch (choice(curve)) {
      case "Equal power":
        ga = Math.cos(k * Math.PI / 2.);
        gb = Math.sin(k * Math.PI / 2.);
        break;
      case "Smooth": {
        const s = k * k * (3. - 2. * k);
        ga = 1. - s; gb = s;
        break;
      }
      default:
        ga = 1. - k; gb = k;
        break;
    }

    output.value = blend(latchedA, latchedB, ga, gb);
  }
}
