module utils.join_numbers;

ushort joinNumbers(const ushort[] numbers)
{
    ushort sum = 0;
    foreach (i, n; numbers)
    {
        sum += n * 10^^(3 - i);
    }

    return sum;
}
