module fss;
import std.stdio : File, writeln, write, writef, writefln;
import std.array : array;
import std.range : dropOne;
import std.algorithm;
import std.conv;
import std.typecons;

void main()
{
	auto dataFile = File("../simulations_data/sim_16.dat", "r");

	Tuple!(double, double)[] fidelityVsLambda;
	foreach (line; dataFile.byLine.dropOne())
	{
		auto data = line.strip(' ').splitter("\t\t").array();
		fidelityVsLambda ~= tuple(data[0].to!double, data[$ - 1].to!double);
	}

	Tuple!(double, double)[] derivativeVsLambda;
	foreach (i; 0 .. fidelityVsLambda.length - 1)
	{
		derivativeVsLambda ~= tuple(
			(fidelityVsLambda[i + 1][0] + fidelityVsLambda[i][0]) / 2,
			(fidelityVsLambda[i + 1][1] - fidelityVsLambda[i][1]) /
			(fidelityVsLambda[i + 1][0] - fidelityVsLambda[i][0])
		);
	}


	auto derivFile = File("../simulations_data/definitive/derivative.dat", "w");
	derivativeVsLambda.sort!("a[0] < b[0]");
	foreach (tup; derivativeVsLambda)
	{
		derivFile.writefln("%.5f\t\t%.5f", tup[0], tup[1]);
		derivFile.flush();
	}



}
