import Score 1.0

// Forwards only the first N values received, then closes until reset.
// Handy to capture an initial state: a calibration, a first frame, a seed...
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: howMany; objectName: "How many"; min: 1; max: 1000000; init: 1 }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: seen = 0 }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: done; objectName: "Done" }

  property int seen: 0
  property bool wasDone: false

  tick: function(token, state) {
    if (typeof input.value !== "undefined" && seen < howMany.value) {
      output.value = input.value;
      seen++;
    }
    const d = (seen >= howMany.value);
    if (d !== wasDone) {
      wasDone = d;
      done.value = d;
    }
  }
}
