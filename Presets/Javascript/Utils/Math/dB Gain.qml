import Score 1.0

// Decibels to linear gain and back.
// Faders and meters think in dB, multiplications think in linear.
// Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  ComboBox     { id: dir; objectName: "Direction"; choices: [ "dB to gain", "Gain to dB" ]; index: 0 }
  FloatSpinBox { id: floorDb; objectName: "Floor (dB)"; min: -240.; max: 0.; init: -96. }
  ValueOutlet  { id: output; objectName: "Out" }

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

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const fl = floorDb.value;
    const toGain = (choice(dir) === "dB to gain");

    output.value = mapv(input.value, function(x) {
      if (toGain)
        return (x <= fl) ? 0. : Math.pow(10., x / 20.);
      const a = Math.abs(x);
      return (a <= 0.) ? fl : Math.max(fl, 20. * Math.log(a) / Math.LN10);
    });
  }
}
