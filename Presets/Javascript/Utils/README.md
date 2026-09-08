# Utility scripts

Small, single-purpose JavaScript nodes for the parts of a patch that are not
the idea itself: reshaping numbers, taming a stream, slicing a list, keeping
time. Think of the objects you reach for without thinking in Max, PureData,
TouchDesigner or vvvv — this is that layer.

Nothing here touches protocols, files, devices or the GPU. Every node takes
values in and gives values out, so they compose freely and behave the same
whether they are driven by a fader, an OSC stream or a rendered timeline.

Drop any of them onto a track, then open the script to see how it works —
they are meant to be read and modified, not treated as black boxes.

## The folders

| | |
|---|---|
| **Flow** | when a value is allowed through, and where it goes |
| **Math** | arithmetic, ranges, curves, comparisons |
| **Vector** | 2D / 3D geometry: directions, distances, transforms, layouts |
| **Array** | list processing: cut, join, sort, resample, analyse |
| **Time** | smoothing, delays, clocks, and the position of the playhead |
| **Random** | seeded randomness, noise, walks, weighted choices |
| **Text** | strings and JSON |

## Conventions used throughout

**Values may be scalars or lists.** Most maths nodes work element-wise: give
`Scale` a number and you get a number, give it a list and every element is
scaled. Two-operand nodes broadcast a scalar over a list, and cycle the
shorter of two lists — the vvvv "spread" behaviour.

**Lists coming off a cable are not always real JS arrays**, so every script
tests for a `length` property rather than calling `Array.isArray`. The helper
is called `isList` and appears wherever it is needed. Copy it if you write
your own node; `Array.isArray` will pass your unit test and fail on a patch.

**A second operand can usually be left unconnected.** Nodes with an A/B pair
latch B to its last received value, and fall back to a control in the
inspector when nothing has ever arrived. So the same node works as
"add two streams" and as "add 0.5".

**Timing comes from the token, not from the wall clock.** Time in
milliseconds is computed as

```js
const t = 1000 * (token.date * state.model_to_physical) / state.sample_rate;
```

which follows the transport: it is correct when the score is played faster,
slower, or rendered offline. Filters that depend on a rate — `Smooth`,
`Slew`, `Envelope Follower` — recompute their coefficients from the real tick
duration, so their feel does not change with the buffer size.

**Events keep their position inside the buffer.** Nodes that pass values
along (`Gate`, `Change`, `Demux`, `Divider`, `Delay`, `Metro`) use
`outlet.addValue(sampleOffset, v)` rather than `outlet.value = v`, so several
events can be emitted in one tick and each keeps its own timestamp. Nodes
that sample a continuous signal use the simpler `outlet.value`.

**Randomness is seeded.** Everything in `Random` uses a small reproducible
generator: the same seed replays the same sequence, so a piece can be
rehearsed. Set the seed to 0 when you want a different run every time.

## The nodes

### Flow

| | |
|---|---|
| `Change` | forwards a value only when it differs from the previous one |
| `Gate` | opens and closes a connection |
| `Switch` | several inputs, one output |
| `Demux` | one input, several outputs |
| `Round Robin` | hands successive values to successive outputs |
| `Select` | matches against a list of targets, routes match / reject |
| `Last Active` | follows whichever of several sources moved last |
| `Once` | passes the first N values, then closes |
| `Flip Flop` | every bang inverts the state |
| `Counter` | counts bangs, wraps / clamps / ping-pongs |
| `Threshold` | Schmitt trigger: a clean on/off out of a noisy signal |
| `Deadband` | forwards only once the value has moved far enough |
| `Rate Limit` | at most one value per interval |
| `Debounce` | emits once the input has been quiet for a while |
| `Sample Hold` | latches the input on a bang |
| `Watchdog` | detects a stream that stopped, substitutes a fallback |

### Math

| | |
|---|---|
| `Expression` | evaluate a JS expression on every value |
| `Conditional` | pick between two expressions on a test |
| `Scale` | map one range onto another, with a curve |
| `Limit` | clip, wrap or fold into a range |
| `Quantize` | snap onto a grid |
| `Arithmetic` | two-operand maths with broadcasting |
| `Easing` | the usual easing curves, in / out / in-out |
| `Accumulate` | running sum, or integrator when scaled by time |
| `Delta` | how much a value moved, and how fast |
| `Compare` | comparisons, plus all / any over a list |
| `Logic` | boolean operations |
| `dB Gain` | decibels to linear gain and back |
| `Note Frequency` | MIDI note numbers to hertz and back |

### Vector

| | |
|---|---|
| `Vector Math` | add, dot, cross, normalize, lerp, reflect, project... |
| `Polar Cartesian` | polar and spherical conversions |
| `Distance Angle` | how far apart two points are, and in which direction |
| `Transform 2D` | translate / rotate / scale points around an anchor |
| `Bounding Box` | extent, centre and barycentre of a point cloud |
| `Layout` | generate a ring, a line, a grid or a spiral of positions |

### Array

| | |
|---|---|
| `Pack` / `Unpack` | separate values to a list, and back |
| `Join` | concatenate several lists |
| `Slice` | sub-range, with step and negative indices |
| `Nth` | read one element, clamping or wrapping |
| `Chunk` / `Flatten` | group a flat list into tuples, and back |
| `Interleave` / `Deinterleave` | weave several streams together, and apart |
| `Sort` | sort, and give back the permutation |
| `Rotate` | shift elements around; animate for a chase |
| `Unique` | remove duplicates and count occurrences |
| `Map` / `Filter` / `Reduce` | expression-driven list processing |
| `Resample` | stretch or shrink a list to N points |
| `Normalize` | min-max, sum, peak, z-score, unit vector |
| `Spread` | generate N values around a centre |
| `Histogram` | distribution of a list over bins |
| `Ring Buffer` | remember the last N values as a list |
| `Peaks` | local maxima, with height, prominence and distance |
| `Lookup` | read a table with interpolation |
| `Array Stats` | length, sum, mean, min, max, median, deviation, RMS |
| `Crossfade` | blend two values or two lists |

### Time

| | |
|---|---|
| `Smooth` | one-pole smoothing, frame-rate independent |
| `Slew` | cap the rate of change, separately up and down |
| `Ramp` | walk to a target over a fixed duration |
| `Metro` | a clock, in milliseconds or in beats of the score tempo |
| `Delay` | hold every value for a while, then release it |
| `Divider` | pass one event out of N |
| `Envelope Follower` | fast up, slow down: energy a light can follow |
| `Elapsed` | stopwatch, lap times, and the actual tick rate |
| `Beat Clock` | bar, beat and phases from the score's tempo track |
| `Position` | where the playhead is inside the parent interval |

### Random

| | |
|---|---|
| `Random` | uniform, bell, low or high biased draws |
| `Noise` | smooth value noise over time, with octaves |
| `Drunk` | a random walk, with inertia |
| `Shuffle` | reorder a list, optionally taking a subset |
| `Urn` | random without repetition |
| `Chance` | pass each value with a given probability |
| `Weighted Pick` | choose an index according to live weights |

### Text

| | |
|---|---|
| `Format` | build a string from a template |
| `String Ops` | case, trim, split, join, replace, pad, search |
| `JSON` | parse, stringify, and read a path inside a structure |

## Some combinations worth knowing

* `Ring Buffer` → `Array Stats` — running statistics over a sliding window.
* `Ring Buffer` → `Peaks` — find the bumps in a recorded gesture.
* `Noise` → `Scale` — organic motion inside a range you control.
* `Metro` → `Urn` → `Nth` — never play the same clip twice in a row.
* `Threshold` → `Flip Flop` — one sensor crossing toggles a state.
* `Delta` → `Envelope Follower` — "how energetic is this movement right now".
* `Layout` → `Transform 2D` — place N objects, then move the whole set.
* `Sort` gives an `Order` outlet; feed it to `Nth` to reorder a parallel list
  the same way.
