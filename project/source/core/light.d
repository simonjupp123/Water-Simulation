module light;

import std.stdio;

import linear;
import materials;
import scene;
import geometry;

import bindbc.opengl;

class LightNode : ISceneNode{
    ISurface mGeometry;
    IMaterial mMaterial; // The 'shaders' and textures needed to render our mesh

    this(string name, ISurface geometry, IMaterial material){
        mNodeName = name;
        mGeometry = geometry; 
        mMaterial = material;
    }

    override void Update(){
        /// Update the material
        mMaterial.Update();

        // Update the model matrix based on the mesh we are attached to
        // mMaterial.mUniformMap["uModel"].Set(mModelMatrix.DataPtr());

        // Update all of the uniform values
        // This will happen prior to the draw call
        foreach(u ; mMaterial.mUniformMap){
            u.Transfer();
        }
        /// Render the Mesh
        // Draw our arrays
        mGeometry.Render();
    }

    /// Return the material associated with the mesh
    IMaterial GetMaterial(){
        return mMaterial;
    }

    /// Return the geometry associated with the mesh
    ISurface GetGeometry(){
        return mGeometry;
    }
}

