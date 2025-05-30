module watergeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import error;
import linear;
import std.math;

// class SurfaceWater : ISurface
// {
//     GLuint mVBO;
//     GLuint mIBO;

//     GLfloat[] vbo_data;
//     GLuint[] mIndices;

//     size_t mTriangles;
//     int mWidth;

//     int mDepth;
//     float mWaterLevel = 0.0f;

//     /// Geometry data
//     this(int x, int z, float height)
//     {
//         // vbo_data = vbo;
//         mWidth = x;
//         mDepth = z;
//         mWaterLevel = height;
//         MakeTriangleFactory(x, z, height);
//     }

//     /// Render our geometry
//     override void Render()
//     {
//         // Bind to our geometry that we want to draw
//         glBindVertexArray(mVAO);
//         // Call our draw call
//         // glDrawArrays(GL_TRIANGLES, 0, cast(int) mTriangles);
//         glDrawElements(GL_TRIANGLES, cast(int) mTriangles * 6, GL_UNSIGNED_INT, null);
//     }

// void Update()
// {
//     //https://www.youtube.com/watch?v=_Ij24zRI9J0&ab_channel=DitzelGames
//     static float time = 0;
//     time += 0.01f;
//     GLfloat[] vbo;
//     for (int z = 0; z < mDepth; z++)
//     {
//         for (int x = 0; x < mWidth; x++)
//         {
//             vbo ~= [
//                 GLfloat(x), cos(z + time) * sin(time + x) + mWaterLevel,
//                 GLfloat(z), // Vertex position
//                 //0.0f, 1.0f, 0.0f, // Normal vector
//                 0.0f, 0.0f, 1.0f
//             ];
//         }
//     }
//     glBindBuffer(GL_ARRAY_BUFFER, mVBO);
//     glBufferData(GL_ARRAY_BUFFER, vbo.length * GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);
// }
//     /// Setup MeshNode as a Triangle
//     void MakeTriangleFactory(int width, int depth, float height)
//     {
//         GLfloat[] vbo;
//         for (int z = 0; z < depth; z++)
//         {
//             for (int x = 0; x < width; x++)
//             {
//                 vbo ~= [
//                     GLfloat(x), height, GLfloat(z), // Vertex position
//                     //0.0f, 1.0f, 0.0f, // Normal vector
//                     0.0f, 0.0f, 1.0f
//                 ];
//             }
//         }
//         // Compute the number of traingles.
//         // Note: 6 floats per vertex, is why we are dividing by 6
//         mTriangles = vbo.length / 6;

//         for (int z = 0; z < depth - 1; z++)
//         {
//             for (int x = 0; x < width - 1; x++)
//             {

//                 mIndices ~= (z * width) + x;
//                 mIndices ~= ((z + 1) * width) + x;
//                 mIndices ~= (z * width) + (x + 1);

//                 mIndices ~= ((z + 1) * width) + x;
//                 mIndices ~= ((z + 1) * width) + (x + 1);
//                 mIndices ~= (z * width) + (x + 1);
//             }
//         }

//         // Vertex Arrays Object (VAO) Setup
//         glGenVertexArrays(1, &mVAO);
//         // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
//         glBindVertexArray(mVAO);

//         // Vertex Buffer Object (VBO) creation
//         glGenBuffers(1, &mVBO);
//         glBindBuffer(GL_ARRAY_BUFFER, mVBO);
//         glBufferData(GL_ARRAY_BUFFER, vbo.length * GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

//         glGenBuffers(1, &mIBO);
//         glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);

//         glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndices.length * GLuint.sizeof, mIndices.ptr, GL_STATIC_DRAW);

//         // Function call to setup attributes
//         SetVertexAttributes!VertexFormat3F3F();

//         // Unbind our currently bound Vertex Array Object
//         glBindVertexArray(0);

//         // Turn off attributes
//         DisableVertexAttributes!VertexFormat3F3F();
//     }
// }

class SurfaceWater : ISurface
{
    GLuint mVBO;
    size_t mTriangles;
    int mWidth;
    int mDepth;
    float mHeight;
    float time = 0;

    /// Geometry data
    this(GLfloat[] vbo, int width, int depth, float height)
    {
        mWidth = width;
        mDepth = depth;
        mHeight = height;
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render()
    {
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES, 0, cast(int) mTriangles);
    }

    void Update()
    {

        time += 0.01f;

        GLfloat[] data;
        for (int z = 0; z < mDepth - 1; z += 1)
        {
            for (int x = 0; x < mWidth - 1; x += 1)
            {
                // float height = 
                float scale = 0.5f;
                vec3 pos1 = vec3(x, (cos(z + time) * sin(time + x)) * scale + mHeight, z);
                vec3 pos2 = vec3(x, (cos(z + 1 + time) * sin(time + x)) * scale + mHeight, z + 1);
                vec3 pos3 = vec3(x + 1, (cos(z + time) * sin(time + x + 1)) * scale + mHeight, z);
                vec3 pos4 = vec3(x + 1, (cos(z + 1 + time) * sin(time + x + 1)) * scale + mHeight, z + 1);
                // vec2 uv1 = vec2(0.0, 0.0);
                // vec2 uv2 = vec2(0.0, 1.0);
                // vec2 uv3 = vec2(1.0, 0.0);
                // vec2 uv4 = vec2(1.0, 1.0);
                //TODO MAY JUST NEED TO SETS OF UV TEXTURES FOR EACH QUAD
                //SO THAT WE CAN HAVE TILED TEXTURES< AND UV reflections between 0,1
                vec2 uv1 = vec2(1.0 * x / mWidth, 1.0 * z / mDepth);
                vec2 uv2 = vec2(1.0 * x / mWidth, 1.0 * (z + 1) / mDepth);
                vec2 uv3 = vec2(1.0 * (x + 1) / mWidth, 1.0 * z / mDepth);
                vec2 uv4 = vec2(1.0 * (x + 1) / mWidth, 1.0 * (z + 1) / mDepth);

                data ~= QuadHelper(pos1, pos2, pos3, uv1, uv2, uv3);
                data ~= QuadHelper(pos2, pos4, pos3, uv2, uv4, uv3);
                // writeln(z, " ", x, " ", pos1, " ", pos2, " ", pos3, " ", pos4);
            }
        }
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, data.length * GLfloat.sizeof, data.ptr, GL_STATIC_DRAW);
    }
    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo)
    {

        // Compute the number of traingles.
        // Note: 14 floats per vertex, is why we are dividing by 14
        mTriangles = vbo.length / 14;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length * GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F2F3F3F3F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F2F3F3F3F();
    }
}

float[] QuadHelper(vec3 pos1, vec3 pos2, vec3 pos3, vec2 uv1, vec2 uv2, vec2 uv3)
{
    //TODO NEED TO CALCULATE NORMALS OF surfaces
    vec3 n = vec3(0.0f, 1.0f, 0.0f);
    vec3 edge1 = pos2 - pos1;
    vec3 edge2 = pos3 - pos1;
    vec2 deltaUV1 = uv2 - uv1;
    vec2 deltaUV2 = uv3 - uv1;
    float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);

    vec3 tangent1;
    vec3 bitangent1;
    tangent1.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
    tangent1.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
    tangent1.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);

    bitangent1.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
    bitangent1.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
    bitangent1.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);

    return [
        pos1.x, pos1.y, pos1.z, uv1.x, uv1.y, n.x, n.y, n.z, tangent1.x,
        tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
        pos2.x, pos2.y, pos2.z, uv2.x, uv2.y, n.x, n.y, n.z, tangent1.x,
        tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
        pos3.x, pos3.y, pos3.z, uv3.x, uv3.y, n.x, n.y, n.z, tangent1.x,
        tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
    ];
}
/// Helper function to return a textured quad with normals, binormals, and bitangents
SurfaceWater MakeWaterTexturedNormalMappedQuad(int width, int depth, float height)
{

    //Changing PSET 9 function to account for width,depth and a starting height
    float[] data;
    for (int z = 0; z < depth - 1; z += 1)
    {
        for (int x = 0; x < width - 1; x += 1)
        {
            vec3 pos1 = vec3(x, height, z);
            vec3 pos2 = vec3(x, height, z + 1);
            vec3 pos3 = vec3(x + 1, height, z);
            vec3 pos4 = vec3(x + 1, height, z + 1);
            vec2 uv1 = vec2(1.0 * x / width, 1.0 * z / depth);
            vec2 uv2 = vec2(1.0 * x / width, 1.0 * (z + 1) / depth);
            vec2 uv3 = vec2(1.0 * (x + 1) / width, 1.0 * z / depth);
            vec2 uv4 = vec2(1.0 * (x + 1) / width, 1.0 * (z + 1) / depth);

            data ~= QuadHelper(pos1, pos2, pos3, uv1, uv2, uv3);
            data ~= QuadHelper(pos2, pos4, pos3, uv2, uv4, uv3);
            // writeln(z, " ", x, " ", pos1, " ", pos2, " ", pos3, " ", pos4);
        }
    }

    // assert(data.length == (14 * width * depth * 2));

    return new SurfaceWater(data, width, depth, height);
}
