module utils.binary;

ubyte[n] binary(long n)(uint number) @property
    if (n > 0)
{
    ubyte[n] bin = new ubyte[n];
    foreach (i; 0 .. n) {
        bin[$ - 1 - i] = (number & 2^^i) != 0 ? 1 : 0;
    }

    return bin;
}


unittest
{
    import std.range : chunks;
    import std.algorithm.iteration : map;
    import std.stdio;
    import utils.by_chuncks;

    immutable uint k = 4;
    writeln( 1.binary!((k + 1)^^2).byChuncks!(k+1) );
}
