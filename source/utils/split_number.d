module utils.split_number;

import std.range : retro;
import std.array : array;

ushort[] splitNumber(ushort number)
{
    // 1234 => [1, 2, 3, 4]
    ushort[] reversedDigits;
    while (number != 0)
    {
        reversedDigits ~= number % 10;
        number = (number - number % 10) / 10;
    }

    return reversedDigits.retro().array();
}

unittest {
    import std.algorithm : equal;
    assert(splitNumber(1111).equal([1, 1, 1, 1]));
    assert(splitNumber(1241).equal([1, 2, 4, 1]));
    assert(splitNumber(8467).equal([8, 4, 6, 7]));
    assert(splitNumber(3479).equal([3, 4, 7, 9]));
}
