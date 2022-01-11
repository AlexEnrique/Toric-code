module functions.save_data;

import std.file : dirEntries, SpanMode;
import std.range : walkLength, chain;
import std.format : format;
import std.stdio : File, writeln;
import std.algorithm.iteration : joiner, map;
import std.array : array;

string saveData(real[][double] w, real[double] fidelity)
{
    // creating file
    auto fileNumber = dirEntries("./simulations_data/", "*.dat",
        SpanMode.shallow).walkLength + 2;
    //
    auto fileName = "simulations_data/sim_%d.dat".format(fileNumber);
    auto file = File(fileName, "w");

    // header
    file.writeln(
        ["# lambda", "w_0", "w_1", "w_2", "w_3", "F_0"].joiner("\t\t")
    );


    auto lambdas = fidelity.keys;
    foreach (lamb; lambdas)
    {
        file.writeln(
            "  %.5f\t\t".format(lamb),
            w[lamb].chain([fidelity[lamb]])
                .map!(e => "%.8e".format(e))
                .array()
                .joiner("\t\t")
        );
        file.flush();
    }

    return fileName;
}
