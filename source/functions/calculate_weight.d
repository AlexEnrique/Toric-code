module functions.calculate_weight;

import std.algorithm.iteration : group;
import std.math : tanh, approxEqual;

import structures.vertex;

import std.stdio;

real calculateWeight(float lambda, Vertex[] vertices)
{
    immutable ubyte[ubyte] powers = [
        1 : 0,
        2 : 2,
        3 : 1,
        4 : 1,
        5 : 1,
        6 : 1,
        7 : 1,
        8 : 1
    ];
    //

    ulong power = 0;
    foreach (v, count; vertices.byTypeArray().group())
    {
	    power += powers[v.type] * count;
    }

    /* if ((tanh(lambda).approxEqual(0, 1e-5, 1e-12) ? cast(real).0 : cast(real)tanh(lambda) ^^ power) != 0)
        writeln("* ", lambda, " ", tanh(lambda), " ", tanh(lambda) ^^ power); */

    return tanh(lambda).approxEqual(0, 1e-3) ? cast(real).0 : cast(real)tanh(lambda) ^^ power;
}
