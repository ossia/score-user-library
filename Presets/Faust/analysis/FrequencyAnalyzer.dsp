declare name "Frequency analyzer";
declare version "0.0";
declare author "JOS, revised by RM, simplified by JM";
declare description "Linear frequency bands.";

import("stdfaust.lib");

spectral_level_linear(M,ftop,N,tau,gain) = _<:
    _,an.mth_octave_analyzer6e(M,ftop,N) :
    _,(display:>_):attach with {
  display = par(i,N,dbmeter(i));
  dbmeter(i) = abs : si.smooth(ba.tau2pole(tau)) : _ * gain : max(ma.EPSILON)  : meter(N-i-1);
    meter(i) = speclevel_group(vbargraph("[%2i]
     [tooltip: Spectral Band Level]", 0., 1.));
  O = int(((N-2)/M)+0.4999);
  speclevel_group(x)  = hgroup("[0] CONSTANT-Q SPECTRUM ANALYZER (6E), %N bands spanning
  	LP, %O octaves below %ftop Hz, HP
     [tooltip: See Faust's filters.lib for documentation and references]", x);
};

process = spectral_level_linear(M,ftop,N,tau,gain)
with{
    M = 1.5;
    ftop = 8000;
    Noct = 5; // number of octaves down from ftop
    // Lowest band-edge is at ftop*2^(-Noct+2) = 62.5 Hz when ftop=16 kHz:
    N = int(Noct*M); // without 'int()', segmentation fault observed for M=1.67
    ctl_group(x)  = hgroup("[1] SPECTRUM ANALYZER CONTROLS", x);
    tau = ctl_group(hslider("[0] Level Averaging Time [unit:ms] [scale:log]
        [tooltip: band-level averaging time in milliseconds]",
    100,1,10000,1)) * 0.001;
    gain = ctl_group(hslider("Gain", 5.,0.,10.,1.));
};
