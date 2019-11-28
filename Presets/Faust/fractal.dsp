declare name "fractal";
declare author "SCRIME";

V = 5; // number of voisces

import("stdfaust.lib");
import("delays.lib");
import("maths.lib");

transpose (w, x, s, sig)  =
	fdelay1s(d,sig)*fmin(d/x,1) + fdelay1s(d+w,sig)*(1-fmin(d/x,1))
	   	with {
			i = 1 - pow(2, s/12);
			d = i : (+ : +(w) : fmod(_,w)) ~ _;
	        };

fractales(1) = (+:transpose(1097, 461, t):@(d):*(r))~(*(c))
	with{
		d = vslider("duree1", 0.5, 0, 2, 0.001)*SR;
		r = 1-vslider("diminution1", 0.5, 0, 1, 0.01);
		t = vslider("transposition1", 0, -40, +40, 0.1);
		c = checkbox("recursive");
};
fractales(S) = _<:*(b),((+:transpose(1097, 461, t):@(d):*(r))~*(c)):_,(_<:*(1-(b)),_):(+:fractales(S-1)),_
	with{
		d = vslider("duree%S", 0.5, 0, 2, 0.001)*SR;
		r = 1-vslider("diminution%S", 0.5, 0, 1, 0.01);
		t = vslider("transposition%S", 0, -40, +40, 0.1);
		c = checkbox("recursive");
		b = checkbox("paralelle");
};

process = hgroup("extensions_fractales", _<:*(checkbox("passe")),fractales(V):>_);
