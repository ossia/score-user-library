declare name "demixer";
declare author "SCRIME";

import("stdfaust.lib");

N = 7; // Numbre of speaker pairs

master = hslider("master", 0.5, 0, 1, 0.00001) : ba.lin2LogGain : si.smoo; // master volume slider;
sub = hslider("sub", 0.5, 0, 1, 0.00001) : ba.lin2LogGain : si.smoo; // subwofer volume slider;

left(i) = hslider("[(%i *2) +1]left_%i", 0.5, 0, 1, 0.00001) : ba.lin2LogGain : si.smoo; // left volume slider;
wright(i) = hslider("[(%i *2) +2]wright_%i", 0.5, 0, 1, 0.00001) : ba.lin2LogGain : si.smoo; // wright volume slider;

demixer(n) = *(master), *(master) <: par( j, n, *(left(j)), *(wright(j)) ),
                                                (+ : *(sub) *(0.2));

process = demixer(N);
