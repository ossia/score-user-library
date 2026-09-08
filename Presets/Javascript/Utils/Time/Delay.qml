import Score 1.0

// [delay] / [pipe] — holds every incoming value for a while, then releases it.
// Several values can be in flight at once, so a whole gesture is replayed
// later untouched.  Feed it a metro to get an echo, a canon, a trail.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: delayMs; objectName: "Delay (ms)"; min: 0.; max: 600000.; init: 250. }
  FloatSpinBox { id: spread; objectName: "Spread (ms)"; min: 0.; max: 600000.; init: 0. }
  IntSpinBox   { id: capacity; objectName: "Max in flight"; min: 1; max: 100000; init: 512 }
  Impulse      { id: flush; objectName: "Flush"; onImpulse: doFlush = true }
  Impulse      { id: clear; objectName: "Clear"; onImpulse: doClear = true }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: inFlight; objectName: "In flight" }

  property var queue: []
  property bool doFlush: false
  property bool doClear: false

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function copyOf(v) {
    if (!isList(v)) return v;
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) r[i] = copyOf(v[i]);
    return r;
  }

  tick: function(token, state) {
    const toMs = 1000. * state.model_to_physical / state.sample_rate;
    const t0 = token.previous_date * toMs;
    const t1 = token.date * toMs;
    const tm = state.timings(token);
    const span = Math.max(1e-9, t1 - t0);

    // Several values can come out in the same tick: each is written at its own
    // sample position, otherwise only the last one would survive.
    function emit(at, v) {
      const frac = Math.max(0., Math.min(1., (at - t0) / span));
      output.addValue(tm.start_sample + Math.floor(frac * Math.max(0, tm.length)), v);
    }

    if (doClear) { doClear = false; queue = []; }

    if (typeof input.value !== "undefined") {
      // Spread lets successive values fan out instead of arriving together.
      const jitter = (spread.value > 0.) ? (Math.random() * spread.value) : 0.;
      queue.push({ due: t1 + delayMs.value + jitter, v: copyOf(input.value) });
      while (queue.length > capacity.value)
        queue.shift();
    }

    if (doFlush) {
      doFlush = false;
      for (var f = 0; f < queue.length; ++f) emit(t1, queue[f].v);
      queue = [];
      inFlight.value = 0;
      return;
    }

    // The queue is chronological as long as the delay does not shrink mid-flight,
    // so a single pass over the head is enough in the common case; sort to be safe.
    var due = [];
    var kept = [];
    for (var i = 0; i < queue.length; ++i) {
      if (queue[i].due <= t1) due.push(queue[i]);
      else kept.push(queue[i]);
    }
    if (due.length > 0) {
      due.sort(function(a, b) { return a.due - b.due; });
      for (var j = 0; j < due.length; ++j)
        emit(due[j].due, due[j].v);
      queue = kept;
    }

    inFlight.value = queue.length;
  }
}
