// An example of a normal map material
module normalmapmaterial;

import pipeline, materials, texture, uniform;
import bindbc.opengl;

/// Represents a normal mapped material 
/// Some notes on 'albedo' vs 'diffuse map' for naming: https://www.a23d.co/blog/difference-between-albedo-and-diffuse-map
class NormalMapMaterial : IMaterial
{
    Texture mTexture1;
    Texture mTexture2;
    Texture mTexture3;

    /// Construct a new material for a pipeline, and load a texture for that pipeline
    this(string pipelineName, string textureFileName, string normalmapFileName, string dudvmapFileName)
    {
        /// delegate to the base constructor to do initialization
        super(pipelineName);

        mTexture1 = new Texture(textureFileName);
        mTexture2 = new Texture(normalmapFileName);
        mTexture3 = new Texture(dudvmapFileName);

        /// Any additional code for setup after
        AddUniform(new Uniform("albedomap", 0));
        AddUniform(new Uniform("normalmap", 0));
        AddUniform(new Uniform("dudv", 0));
        AddUniform(new Uniform("viewPos", "vec3", null));
        AddUniform(new Uniform("lightPos", "vec3", null));
        AddUniform(new Uniform("reflectTex", 9));
        AddUniform(new Uniform("refractTex", 10));

    }

    /// TextureMaterial.Update()
    override void Update()
    {
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);

        // Set any uniforms for our mesh if they exist in the shader
        if ("albedomap" in mUniformMap)
        {
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, mTexture1.mTextureID);
            mUniformMap["albedomap"].Set(0);
        }
        // Set any uniforms for our mesh if they exist in the shader
        if ("normalmap" in mUniformMap)
        {
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, mTexture2.mTextureID);
            mUniformMap["normalmap"].Set(1);
        }
        if ("dudv" in mUniformMap)
        {
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, mTexture2.mTextureID);
            mUniformMap["dudv"].Set(2);
        }
        // if("reflectTex" in mUniformMap){
        //     glActiveTexture(GL_TEXTURE2);
        //     glBindTexture(GL_TEXTURE_2D,idk);
        //     mUniformMap["reflectTex"].Set(2);
        // }
        //  if("refractTex" in mUniformMap){
        //     glActiveTexture(GL_TEXTURE3);
        //     glBindTexture(GL_TEXTURE_2D,);
        //     mUniformMap["refractTex"].Set(3);
        // }
    }
}
