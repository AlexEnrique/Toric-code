module structures.lattice;

import structures.qubit;
import structures.site;
import structures.vertex;
import structures.state;

import std.stdio; // for debug

struct Lattice(ubyte k) // k-by-k sites
{
    private Site[k][k] sites;
    private Vertex[][] vertices;
    private Qubit[2 * (k + 1) * (k + 2)] qubits;
    private State initialState;


    // constructors
    @disable this();

    this(State state)
    {
        initialState = state;
        _allocVertices();

        _linkSites();
        _linkQubits();

        setState(state);
    }

    // public methods
    public void operator(string op)(size_t x, size_t y) @property
        if (op == "A")
    {
        x = (x + k) % k;
        y = (y + k) % k;

        import std.range : lockstep;
        ushort[] config = new ushort[4];
        foreach (ref c, Vertex* v; lockstep(config, sites[x][y].getVertices()))
        {
            c = v.type;
        }

        import functions.novais : opA;
        import utils.join_numbers;
        import utils.split_number;
        auto newConfig = opA(config.joinNumbers()).splitNumber();

        foreach (i, ref Vertex* v; sites[x][y].getVertices())
        {
            v.type = cast(ubyte)newConfig[i]; // remove this cast latter
        }
    }

    public void operator(string op)() @property
        if (op == "x1")
    {
         foreach (ref row_vertices; vertices)
        {
            row_vertices[0].type = 3;
        }
    }

    public void operator(string op)() @property
        if (op == "x2")
    {
        foreach (ref v; vertices[0]) {
            v.type = 4;
        }
    }

    public void operator(string op)() @property
        if (op == "x1x2")
    {
        foreach (ref row_vertices; vertices)
        {
            row_vertices[0].type = 3;
        }
        foreach (ref v; vertices[0]) {
            v.type = 4;
        }

        vertices[0][0].type = 2;
    }

    public Vertex[] getVertices()
    {
        import std.algorithm.iteration : joiner;
        import std.array : array;
        return vertices.joiner().array();
    }

    public void printVertices() const
    {
        foreach (row_vertices; vertices)
        {
            write(" ");
            foreach (v; row_vertices)
            {
                write(v.type, " ");
            }
            writeln();
        }
        writeln();
    }

    public void setState(State state)
    {
        final switch (state)
        {
            case State.ferromagnetic:
            {
                _allQubitsUp();
                break;
            }

            case State.x1:
            {
                _allQubitsUp();
                operator!"x1"();
                break;
            }

            case State.x2:
            {
                _allQubitsUp();
                operator!"x2"();
                break;
            }

            case State.x1x2:
            {
                _allQubitsUp();
                operator!"x1x2"();
                break;
            }
        }
    }

    public void resetInitialState()
    {
        setState(initialState);
    }


    // private methods
    private void _allocVertices()
    {
        vertices = new Vertex[][k + 1];
        foreach (ref row_vertices; vertices)
        {
            row_vertices = new Vertex[k + 1];
        }
    }

    private void _linkSites()
    {
        foreach(x, ref row_sites; sites)
        {
            foreach (y, ref site; row_sites) {
                site = Site([_v(x, y), _v(x, y+1), _v(x+1, y), _v(x+1, y+1)]);
            }
        }
    }

    private void _linkQubits()
    {
        import std.algorithm.iteration : each;
        import std.typecons : tuple;
        import std.range : recurrence, sequence, take, lockstep;
        import std.array : array;

        // creating pointers
        Qubit*[] refsQubits;
        qubits.each!((ref Qubit q) => refsQubits ~= &q);

        // add boundary conditions (-1 applied to all)
        auto boundary =
        recurrence!((a, n) => (
            tuple(a[n - 1][0] + 2 * (k + 1) + 1 ,
                  a[n - 1][1] + 2 * (k + 1) + 1)
        ))( tuple(k + 1, 2 * (k + 1)) )
            .take(k + 1)
            .array();
        //

        boundary ~=
        recurrence!((a, n) => (
            tuple(a[n - 1][0] + 1,
                  a[n - 1][1] + 1)
        ))( tuple(0, (k + 1) * (2 * (k + 1) + 1) - 1) )
            .take(k + 1)
            .array();
        //

        boundary.each!(pair => refsQubits[pair[0]] = refsQubits[pair[1]]);

        // link qubits to vertices
        auto plaquettes =
        sequence!((a, n) => [
            refsQubits[n],
            refsQubits[n + k + 1],
            refsQubits[n + k + 2],
            refsQubits[n + 2 * (k + 1) + 1]
        ]).take(2 * k^^2 + 4 * k).array();

        //

        foreach (plaq, ref Vertex* ver; lockstep(plaquettes, this._vertRefs()))
        {
            plaq.attach(ver);
        }
    }

    private void _allQubitsUp()
    {
        import std.algorithm.iteration : each;
        qubits.each!((ref q) => q = +1);
        vertices.each!((ref row) => row.each!((ref v) => v.type = 1));
    }

    private void _allQubitsDown()
    {
        import std.algorithm.iteration : each;
        qubits.each!((ref q) => q = -1);
        vertices.each!((ref row) => row.each!((ref v) => v.type = 2));
    }

    private Vertex* _v(size_t x, size_t y)
    {
        // boundary (toric) conditions
        x = (x + k + 1) % (k + 1);
        y = (y + k + 1) % (k + 1);
        return &vertices[x][y];
    }

    private Vertex*[] _vertRefs()
    {
        import std.algorithm.iteration : map, joiner;
        import std.array : array;
        return vertices.map!((ref row) => row.map!((ref e) => &e))
                       .joiner()
                       .array();
    }
}
