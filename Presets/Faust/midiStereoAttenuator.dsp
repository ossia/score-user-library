declare name "midiStereoAtenuator";
declare author "SCRIME";

import("stdfaust.lib");

v =1 - ( hslider("attenuation", 127, 0, 127, 1) / 127): si.smoo : ba.lin2LogGain * 0.5;

process = _,_:*(v), *(v);
