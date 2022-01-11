module utils.by_chuncks;

import std.traits : isArray;
import std.array : array;
import std.algorithm.iteration : map;
import std.range : chunks;

ubyte[][] byChuncks(long n, Array)(Array bitArray) @property
    if (n > 0 && isArray!Array)
{
    return bitArray.dup.chunks(n).array();
}
