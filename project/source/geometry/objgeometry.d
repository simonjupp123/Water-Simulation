/// OBJ File Creation
module objgeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import error;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.typecons : Tuple, tuple;

/// Geometry stores all of the vertices and/or indices for a 3D object.
/// Geometry also has the responsibility of setting up the 'attributes'
class BasicOBJ : ISurface
{
    GLuint mVBO;
    GLuint mIBO;
    GLfloat[] mVertexData;
    GLfloat[] mNormalData;
    GLuint[] mIndexData;
    GLfloat[] mTextureData;
    GLfloat[] allData; // All data in one array, used to create VBO
    size_t mTriangles;

    /// Geometry data
    this(string objfilename)
    {
        MakeOBJ(objfilename);

    }

    void Update()
    {
        //recalculates vertex data and resets VBO

    }
    /// Render our geometry
    override void Render()
    {
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawElements(GL_TRIANGLES, cast(GLuint) mIndexData.length, GL_UNSIGNED_INT, null);
    }

    void MakeOBJ(string filepath)
    {

        string obj_data = readText(filepath);
        auto lines = obj_data.splitLines();

        // Vertex Buffer Object (VBO) creation
        // writeln(vertNormMap);

        alias FaceKey = Tuple!(GLuint, GLuint, GLuint);
        GLuint[FaceKey] tupleData;
        int counter = 0;
        foreach (line; lines)
        {

            if (line.startsWith("v "))
            {
                // Parse vertex data
                auto verts = line.split(" ")[1 .. $].map!(to!GLfloat).array;
                assert(verts.length == 3);
                mVertexData ~= verts;
            }
            else if (line.startsWith("vn "))
            {
                auto vert_normals = line.split(" ")[1 .. $].map!(to!GLfloat).array;
                assert(vert_normals.length == 3);
                mNormalData ~= vert_normals;

            }
            else if (line.startsWith("vt "))
            {
                auto vert_textures = line.split(" ")[1 .. $].map!(to!GLfloat).array;
                assert(vert_textures.length == 2);
                mTextureData ~= vert_textures;

            }
            else if (line.startsWith("f "))
            {
                auto face_data_raw = line.split(" ")[1 .. $]; // will be in the form of int//int
                // assert (face_data_raw.length == 3);
                foreach (e; face_data_raw)
                {

                    auto face_data = e.split("/");
                    // writeln(face_data);
                    auto vert_text_norm = tuple(face_data[0].to!GLuint - 1,
                        face_data[1].to!GLuint - 1,
                        face_data[2].to!GLuint - 1);
                    //Used ChatGPT to help learn the syntax for tuples in D lang
                    if (vert_text_norm !in tupleData)
                    {
                        auto vert_ind = vert_text_norm[0] * 3;
                        auto norm_ind = vert_text_norm[2] * 3;
                        auto text_ind = vert_text_norm[1] * 2;
                        allData ~= mVertexData[vert_ind .. vert_ind + 3];
                        allData ~= mNormalData[norm_ind .. norm_ind + 3];
                        allData ~= mTextureData[text_ind .. text_ind + 2];

                        tupleData[vert_text_norm] = counter;
                        mIndexData ~= counter;
                        counter++;

                    }
                    else
                    {
                        mIndexData ~= tupleData[vert_text_norm];
                    }
                    //check if vert_text_norm already exists in our buffer, otherwise add it, adjust index data 

                }

            }

        }

        //end of import

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) 
        // that we want to work withn.
        glBindVertexArray(mVAO);

        // Index Buffer Object (IBO)
        glGenBuffers(1, &mIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndexData.length * GLuint.sizeof, mIndexData.ptr, GL_STATIC_DRAW);

        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, allData.length * VertexFormat3F3F2F.sizeof, allData.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F3F2F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);
        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F3F2F();
    }

}
