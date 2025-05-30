/// Create a triangle strip for terrain
module terraingeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import core;
import error;
import linear;

/// Geometry stores all of the vertices and/or indices for a 3D object.
/// Geometry also has the responsibility of setting up the 'attributes'
class SurfaceTerrain : ISurface
{
    GLuint mVBO;
    GLuint mIBO;

    VertexFormat3F3F2F[] mVertices;
    GLuint[] mIndices;
    size_t mTriangles;

    uint mXDimensions;
    uint mZDimensions;
    uint NUM_STRIPS;
    uint NUM_VERTS_PER_STRIP;

    /// Constructor to make a new terrain.
    /// filename - heightmap filename
    this(uint xDim, uint zDim, string heightmap_file, uint xOffset = 0, uint zOffset = 0)
    {
        mXDimensions = xDim;
        mZDimensions = zDim;
        MakeTerrain(xDim, zDim, heightmap_file, xOffset, zOffset);
        NUM_STRIPS = mZDimensions - 1;
        NUM_VERTS_PER_STRIP = mXDimensions * 2;
    }

    /// Render our geometry
    // NOTE: It can be handy with terrains to draw them in wireframe
    //       mode to otherwise debug them.
    // NOTE: It can be handy with terrains to draw as 'points' to make sure
    //  		 the 'grid' is otherwise generated correctly if you have trouble
    // 			 with indexing.
    override void Render()
    {
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        //From tutorial:
        //https://learnopengl.com/Guest-Articles/2021/Tessellation/Height-map

        for (int strip = 0; strip < NUM_STRIPS; strip++)
        {
            glDrawElements(GL_TRIANGLE_STRIP,
                NUM_VERTS_PER_STRIP,
                GL_UNSIGNED_INT,
                cast(void*)(GLuint.sizeof * NUM_VERTS_PER_STRIP * strip));
        }

        // TODO glDrawElements(GL_TRIANGLE_STRIP, ....)
    }

    void CalculateNormalsTerrain(ref VertexFormat3F3F2F[] vertexDataArray, int xDim, int zDim)
    {

        // Accumulate each triangle normal into each of the triangle vertices
        for (int z = 0; z < zDim - 1; z++)
        {
            for (int x = 0; x < xDim - 1; x++)
            {
                int BaseVertex = z * xDim + x;
                uint Index0 = BaseVertex;
                uint Index1 = BaseVertex + 1;
                uint Index2 = BaseVertex + xDim;
                vec3 v1 = vec3(vertexDataArray[Index1].aPostition) - vec3(
                    vertexDataArray[Index0].aPostition);
                vec3 v2 = vec3(vertexDataArray[Index2].aPostition) - vec3(
                    vertexDataArray[Index0].aPostition);
                vec3 Normal = v1.Cross(v2);
                Normal = Normal.Normalize();
                vertexDataArray[Index0].aNormal[0] = vertexDataArray[Index0].aNormal[0] + Normal[0];
                vertexDataArray[Index0].aNormal[1] = vertexDataArray[Index0].aNormal[1] + Normal[1];
                vertexDataArray[Index0].aNormal[2] = vertexDataArray[Index0].aNormal[2] + Normal[2];
                vertexDataArray[Index1].aNormal[0] = vertexDataArray[Index1].aNormal[0] + Normal[0];
                vertexDataArray[Index1].aNormal[1] = vertexDataArray[Index1].aNormal[1] + Normal[1];
                vertexDataArray[Index1].aNormal[2] = vertexDataArray[Index1].aNormal[2] + Normal[2];
                vertexDataArray[Index2].aNormal[0] = vertexDataArray[Index2].aNormal[0] + Normal[0];
                vertexDataArray[Index2].aNormal[1] = vertexDataArray[Index2].aNormal[1] + Normal[1];
                vertexDataArray[Index2].aNormal[2] = vertexDataArray[Index2].aNormal[2] + Normal[2];
            }
        }

        foreach (ref vertex; vertexDataArray)
        {
            vec3 temp = Normalize(vec3(vertex.aNormal));
            vertex.aNormal[0] = temp.x;
            vertex.aNormal[1] = temp.y;
            vertex.aNormal[2] = temp.z;
        }
    }

    /// Setup MeshNode as a Triangle
    void MakeTerrain(uint xDim, uint zDim, string heightmap_file, uint xOffset, uint zOffset)
    {
        // Create a grid of vertices
        // Important to keep track of how we generate grid.
        // We iterate trough 'x' on inner loop, so we produce
        // 'rows' across first.
        PPM heights;

        ubyte[] height_values = heights.LoadPPMImage(heightmap_file);
        float yScale = 0.2f, yShift = 0.0f;
        for (int z = zOffset; z < (zDim + zOffset); z++)
        {
            for (int x = xOffset; x < (xDim + xOffset); x++)
            {
                // Add vertices in a grid
                auto y = cast(int)(height_values[(z * heights.mWidth + x) * 3] * yScale + yShift);

                //add temp normals
                mVertices ~= VertexFormat3F3F2F([x - xOffset, y, z - zOffset], [
                        0, 0, 0
                    ], [
                        1.0f * (x - xOffset) / xDim * 100,
                        1.0f * (z - zOffset) / zDim * 100
                    ]);
            }
        }

        //calc normals:
        CalculateNormalsTerrain(mVertices, xDim, zDim);
        // Connect the grid of vertices with indices
        for (uint z = 0; z < zDim - 1; z++)
        {
            for (uint x = 0; x < xDim; x++)
            {
                int index1 = x + (xDim * (z));
                int index2 = x + (xDim * (z + 1));
                mIndices ~= index1;
                mIndices ~= index2;
            }
        }

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Index Buffer Object (IBO)
        glGenBuffers(1, &mIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndices.length * GLuint.sizeof, mIndices.ptr, GL_STATIC_DRAW);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, mVertices.length * VertexFormat3F3F2F.sizeof, mVertices.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F3F2F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F3F2F();
    }
}
