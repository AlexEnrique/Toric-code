module structures.vertex;

import structures.qubit;

struct Vertex
{
    private Qubit*[] qubits;
    public ubyte type; // [1, ..., 8]

    public ref Qubit*[] getQubits() {
        return qubits;
    }

    public void update()
    {
        if (*qubits[0] == +1) // odd vertex
        {
            if (*qubits[1] == +1)
            {
                if (*qubits[2] == +1)
                {
                    this.type = 1;
                }
                else
                {
                    this.type = 5;
                }
            }
            else // qubits[1] == -1
            {
                if (*qubits[2] == +1)
                {
                    this.type = 3;
                }
                else
                {
                    this.type = 7;
                }
            }
        }
        else // even vertex (qubits[0] == -1)
        {
            if (*qubits[1] == +1)
            {
                if (*qubits[2] == +1)
                {
                    this.type = 8;
                }
                else
                {
                    this.type = 4;
                }
            }
            else // qubits[1] == -1
            {
                if (*qubits[2] == +1)
                {
                    this.type = 6;
                }
                else
                {
                    this.type = 2;
                }
            }
        }
    }
}

void attach(V)(ref Qubit*[] qs, ref V v)
    if (is(V == Vertex) || is(V == Vertex*))
{
    v.qubits = qs.dup;
}

void updateAllVertices(V)(V[] vertices)
    if (is (V == Vertex) || is(V == Vertex*))
{
    vertices.each!((ref v) => v.update());
}

auto byTypeArray(V)(V[] vertices)
    if (is (V == Vertex) || is(V == Vertex*))
{
    struct ByTypeVertex
    {
        public ubyte type;
    }

    import std.algorithm.iteration : map;
    return vertices.map!((Vertex v) => ByTypeVertex(v.type));
}
