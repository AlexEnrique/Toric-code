module structures.site;

import structures.vertex;
import structures.qubit;

struct Site
{
    Vertex*[] vertices;

    ref Vertex*[] getVertices()
    {
        return vertices;
    }
}
