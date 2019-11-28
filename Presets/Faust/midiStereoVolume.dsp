declare name "midiStereoVolume";
declare author "SCRIME";

import("stdfaust.lib");

v = hslider("volume", 0, 0, 127, 1) /127: si.smoo : ba.lin2LogGain;

process = _,_:*(v), *(v);
