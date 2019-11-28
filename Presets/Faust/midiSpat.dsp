declare name "midiSpat";
declare author "SCRIME";

import("stdfaust.lib");

N = 9; // Numbre of speaker pairs

window = (hslider("window", 0, 0, 127, 1) / 127) * 5; // attack and release time;

master = nentry("master", 0, 0, 127, 1) / 127 : ba.lin2LogGain; // master volume slider;
sub = nentry("sub", 0, 0, 127, 1) / 127 : ba.lin2LogGain; // subwofer volume slider;

left(i) = nentry("[(%i *2) +1]left_%i", 0, 0, 127, 1) / 127: ba.lin2LogGain; // left volume slider;
wright(i) = nentry("[(%i *2) +2]wright_%i", 0, 0, 127, 1) / 127 : ba.lin2LogGain; // wright volume slider;

winMaster = en.asr(window, 1, window, master);
winSub = en.asr(window, 1, window, sub);

winLeft(i) = en.asr(window, 1, window, left(i));
winWright(i) = en.asr(window, 1, window, wright(i));

demixer(n) = *(winMaster), *(winMaster) <: par( j, n, *(winLeft(j)), *(winWright(j)) ),
                                                (+ : *(winSub) *(0.2));

process = demixer(N);
