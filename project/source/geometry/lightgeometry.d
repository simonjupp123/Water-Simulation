/// Create a triangle strip for terrain
module lightgeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import core;
import error;
import linear;

/// Geometry stores all of the vertices and/or indices for a 3D object.
/// Geometry also has the responsibility of setting up the 'attributes'
class LightGeometry : ISurface
{
    GLuint mVBO;
    // GLuint mIBO;

    GLfloat[] mVertices;
    GLfloat[] tempVertices;
    // GLuint[] mIndices;
    size_t mTriangles; //use this TODO

    this()
    {
        InitLight(vec3(1.0f, 1.0f, 1.0f));
    }

    this(vec3 color)
    {
        InitLight(color);
    }

    override void Render()
    {
        glBindVertexArray(mVAO);
        glDrawArrays(GL_TRIANGLES, 0, 36);

    }

    void InitLight(vec3 color)
    {
        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);
        tempVertices = [
            -0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, 0.5f, -0.5f,
            0.5f, 0.5f, -0.5f,
            -0.5f, 0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,

            -0.5f, -0.5f, 0.5f,
            0.5f, -0.5f, 0.5f,
            0.5f, 0.5f, 0.5f,
            0.5f, 0.5f, 0.5f,
            -0.5f, 0.5f, 0.5f,
            -0.5f, -0.5f, 0.5f,

            -0.5f, 0.5f, 0.5f,
            -0.5f, 0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,
            -0.5f, -0.5f, 0.5f,
            -0.5f, 0.5f, 0.5f,

            0.5f, 0.5f, 0.5f,
            0.5f, 0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, 0.5f,
            0.5f, 0.5f, 0.5f,

            -0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, 0.5f,
            0.5f, -0.5f, 0.5f,
            -0.5f, -0.5f, 0.5f,
            -0.5f, -0.5f, -0.5f,

            -0.5f, 0.5f, -0.5f,
            0.5f, 0.5f, -0.5f,
            0.5f, 0.5f, 0.5f,
            0.5f, 0.5f, 0.5f,
            -0.5f, 0.5f, 0.5f,
            -0.5f, 0.5f, -0.5f,
        ];
        for (int i = 0; i < tempVertices.length; i += 3)
        {
            mVertices ~= tempVertices[i];
            mVertices ~= tempVertices[i + 1];
            mVertices ~= tempVertices[i + 2];
            mVertices ~= color[0];
            mVertices ~= color[1];
            mVertices ~= color[2];
        }
        // writeln(colorVec);
        // writeln(mVertices.length);
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER,
            mVertices.length * GLfloat.sizeof,
            mVertices.ptr,
            GL_STATIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(GLvoid*) 0);

        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(GLvoid*)(
                3 * GLfloat.sizeof));

        glBindVertexArray(0);
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
    }

}
