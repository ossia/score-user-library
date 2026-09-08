import Score 1.0

// Converts between rectangular and angular coordinates.
//   Polar     : [angle, radius]        <-> [x, y]
//   Spherical : [azimuth, elevation, radius] <-> [x, y, z]
// Angles can be read as radians, degrees or turns (0..1), which is often the
// friendliest unit when the angle comes from a normalised control.
Script {
  ValueInlet  { id: input; objectName: "In" }
  ComboBox    { id: mode; objectName: "Conversion"
                choices: [ "Polar to cartesian", "Cartesian to polar",
                           "Spherical to cartesian", "Cartesian to spherical" ]
                index: 0 }
  ComboBox    { id: unit; objectName: "Angle unit"; choices: [ "Turns", "Degrees", "Radians" ]; index: 0 }
  ValueOutlet { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asVec(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = Number(v[i]) || 0.; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    const n = Number(v);
    return isFinite(n) ? [ n ] : [];
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function toRad(a, u) {
    if (u === "Degrees") return a * Math.PI / 180.;
    if (u === "Turns") return a * 2. * Math.PI;
    return a;
  }
  function fromRad(a, u) {
    if (u === "Degrees") return a * 180. / Math.PI;
    if (u === "Turns") return a / (2. * Math.PI);
    return a;
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const v = asVec(input.value);
    if (v.length === 0)
      return;
    const u = choice(unit);

    switch (choice(mode)) {
      case "Polar to cartesian": {
        const th = toRad(v[0], u), r = (v.length > 1) ? v[1] : 1.;
        output.value = [ r * Math.cos(th), r * Math.sin(th) ];
        break;
      }
      case "Cartesian to polar": {
        const x = v[0], y = (v.length > 1) ? v[1] : 0.;
        output.value = [ fromRad(Math.atan2(y, x), u), Math.sqrt(x * x + y * y) ];
        break;
      }
      case "Spherical to cartesian": {
        const az = toRad(v[0], u);
        const el = toRad((v.length > 1) ? v[1] : 0., u);
        const r2 = (v.length > 2) ? v[2] : 1.;
        const ce = Math.cos(el);
        output.value = [ r2 * ce * Math.cos(az), r2 * Math.sin(el), r2 * ce * Math.sin(az) ];
        break;
      }
      default: {
        const X = v[0];
        const Y = (v.length > 1) ? v[1] : 0.;
        const Z = (v.length > 2) ? v[2] : 0.;
        const R = Math.sqrt(X * X + Y * Y + Z * Z);
        output.value = [ fromRad(Math.atan2(Z, X), u),
                         fromRad((R > 0.) ? Math.asin(Y / R) : 0., u),
                         R ];
        break;
      }
    }
  }
}
