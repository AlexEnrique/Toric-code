module utils.write_spaced;

private import std.stdio : write;
void writeSpaced(T...)(T items)
{
    foreach (it; items)
    {
        write(it, "\t\t");
    }
}
