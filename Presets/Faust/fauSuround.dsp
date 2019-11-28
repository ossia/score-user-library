declare name "faustSuround";
declare author "SCRIME";

import("stdfaust.lib");
import("basics.lib");
import("maths.lib");

Inputs = 1;

Outputs = (-1, 1, // Quadriphonic setup 
		   -1, -1, 
		   1, -1, 
		   1, 1);

halfSize(a) = count(a) * 0.5; // Half the size of a list

xaxe(n) = hslider("x_%n", 0, -1, 1, 0.001):si.smoo;
yaxe(n) = vslider("y_%n", 0, -1, 1, 0.001):si.smoo;
inf(n) = 0 - (1 - vslider("influence_%n", 0.5, 0, 1, 0.001)):si.smoo;

process = par(j, Inputs, fausuround(xaxe(j), yaxe(j), inf(j), Outputs)) :> par(h, halfSize(Outputs), _);

//Definition-------------------------------------------------------------------------------------------------

influence(r, p) = sqrt(max((0, (r*p) + 1))); // Diameter around the speaker inside withch a source can be heard. 

fausuround(x, y, disp, coordinates) = _ <: par(i, halfSize(coordinates), // Poccess in parallel the gain for each individual spaekers.
									  _ *(influence(disp, // Gain as square root of 1 - distance betwen a speeaker and the source, relative to the influence.
									  hypot(take((i * 2)+1, coordinates) - x, take((1 + i * 2)+1, coordinates) - y)))); // distance betwen 2 points on the cartesian plain. the first will be a speaker and the second a sound source.
