import Score 1.0

// A stopwatch. Time since the last reset, and time between two bangs.
// Also outputs an estimate of how often the graph is being ticked, which is
// the quickest way to notice a performance problem.
Script {
  Impulse     { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  Impulse     { id: lap; objectName: "Lap"; onImpulse: doLap = true }
  ValueOutlet { id: msOut; objectName: "Elapsed (ms)" }
  ValueOutlet { id: secOut; objectName: "Elapsed (s)" }
  ValueOutlet { id: lapOut; objectName: "Lap (ms)" }
  ValueOutlet { id: ticksOut; objectName: "Ticks" }
  ValueOutlet { id: rateOut; objectName: "Ticks per s" }

  property real origin: 0.
  property real lastLap: 0.
  property bool started: false
  property bool doReset: false
  property bool doLap: false
  property int nbTicks: 0
  property real rateT: 0.
  property int rateN: 0

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;

    if (!started || doReset) {
      started = true; doReset = false;
      origin = t; lastLap = t; nbTicks = 0;
      rateT = t; rateN = 0;
    }

    if (doLap) {
      doLap = false;
      lapOut.value = t - lastLap;
      lastLap = t;
    }

    nbTicks++;
    const e = t - origin;
    msOut.value = e;
    secOut.value = e / 1000.;
    ticksOut.value = nbTicks;

    // Averaged over half a second so the number stays readable.
    rateN++;
    if (t - rateT >= 500.) {
      rateOut.value = 1000. * rateN / (t - rateT);
      rateT = t;
      rateN = 0;
    }
  }
}
