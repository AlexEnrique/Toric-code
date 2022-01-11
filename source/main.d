module main;

import std.range : iota, lockstep, chain, repeat, walkLength, zip;
import std.algorithm.iteration : each, sum, joiner, map;
import std.array : array, assocArray, byPair;
import std.math : isNaN;
import std.stdio : File, write, writeln, writefln, writef;
import std.file : dirEntries, SpanMode;
import std.format : format;
import std.conv : to;

import structures.lattice;
import structures.site;
import structures.vertex;
import structures.qubit;
import structures.state;

import functions.calculate_weight;
import functions.save_data;

import utils.binary;
import utils.by_chuncks;
import utils.write_spaced;
import utils.progress_bar;


void main()
{
    // create lattices
    immutable ubyte k = 5; // k-by-k lattices
    auto lattices = [
        Lattice!k(State.ferromagnetic /* default */),
        Lattice!k(State.x1),
        Lattice!k(State.x2),
        Lattice!k(State.x1x2)
    ];

    auto a = .0;
    auto b = 2.20;
    auto d = .005;
    auto lambdas = iota(a, b + d, d);
    real[] zeros = 0.repeat(lattices.length).array().to!(real[]);
    real[][double] w;
    foreach (lamb; lambdas)
    {
        w[lamb] = zeros.dup;
    }

    writeln(); // new line
    ProgressBar progressBar = new ProgressBar("Calculating weights", 2 ^^ (k^^ 2));
    foreach (number; iota(0, 2 ^^ (k ^^ 2)))
    {
        // apply operator A
        auto whereApplyOperatorA = number.binary!(k^^2).byChuncks!k;
        foreach (x, row; whereApplyOperatorA)
        {
            foreach (y, bit; row)
            {
                if (bit == 1)
                {
                    lattices.each!((ref lat) => lat.operator!"A"(x, y));
                }
            }
        }

        // calculating weights for all values of lambda
        foreach (lamb; lambdas)
        {
            foreach (ref w, ref lat; lockstep(w[lamb], lattices))
            {
                w += calculateWeight(lamb, lat.getVertices());
            }
        }

        lattices.each!((ref lat) => lat.resetInitialState());
        progressBar.next(); // update progress bar
    }
    progressBar.finish();


    // calculating the fidelity for all lambdas
    writeln("Calculating fidelity");
    real[double] fidelity;
    foreach (lamb; lambdas)
    {
        fidelity[lamb] = real.init;
    }

    foreach (pair; w.byPair)
    {
        fidelity[pair.key] =
            isNaN(pair.value[0] / sum(pair.value)) ? 1 : pair.value[0] / sum(pair.value);
    }


    // Generating data file
    auto fileName = saveData(w, fidelity);
    writeln("Data file created at ", fileName);
}
