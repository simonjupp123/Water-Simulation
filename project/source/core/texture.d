/// Module to handle texture loading
module texture;

import image;

import bindbc.opengl;

/// Abstraction for generating an OpenGL texture on GPU memory from an image filename.
class Texture
{
	GLuint mTextureID;

	/// Create a new texture that stores RGB values
	this(string filename)
	{
		CreateTextureRGBFromImage(filename);
	}
	/// Allocate memory for a texture with either color or depth 
	this(int width, int height, bool bColor = true)
	{
		if (bColor)
		{
			CreateTextureRGB(width, height);
		}
		else
		{
			CreateTextureDepth(width, height);
		}
	}

	GLuint GetTextureID() const
	{
		return mTextureID;
	}

	/// Creates an empty texture that can be populated with pixel data
	/// later on.
	/// Also useful if you will write to the texture in a framebuffer
	/// for instance.
	GLuint CreateTextureDepth(int width, int height)
	{
		glGenTextures(1, &mTextureID);
		glBindTexture(GL_TEXTURE_2D, mTextureID);

		glTexImage2D(
			GL_TEXTURE_2D, // 2D Texture
			0, // mimap level 0
			GL_DEPTH_COMPONENT, // Internal format for OpenGL
			width, // width of incoming data
			height, // height of incoming data
			0, // border (must be 0)
			GL_DEPTH_COMPONENT, // image format
			GL_UNSIGNED_BYTE, // image data 
			null); // pixel array on CPU data

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

		return mTextureID;
	}

	/// Creates an empty texture that can be populated with pixel data
	/// later on.
	/// Also useful if you will write to the texture in a framebuffer
	/// for instance.
	GLuint CreateTextureRGB(int width, int height)
	{
		glGenTextures(1, &mTextureID);
		glBindTexture(GL_TEXTURE_2D, mTextureID);

		glTexImage2D(
			GL_TEXTURE_2D, // 2D Texture
			0, // mimap level 0
			GL_RGB, // Internal format for OpenGL
			width, // width of incoming data
			height, // height of incoming data
			0, // border (must be 0)
			GL_RGB, // image format
			GL_UNSIGNED_BYTE, // image data 
			null); // pixel array on CPU data

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

		return mTextureID;
	}

	/// Load a texture by filename
	/// TODO: Only supports .ppm -- should check file extension
	/// 			prior to otherwise loading.
	GLuint CreateTextureRGBFromImage(string filename)
	{
		import std.file;

		if (!exists(filename))
		{
			assert(0, "Attempt to create texture from image: '" ~ filename ~ "' failed");
		}

		glGenTextures(1, &mTextureID);
		glBindTexture(GL_TEXTURE_2D, mTextureID);

		PPM ppm;
		ubyte[] image_data = ppm.LoadPPMImage(filename);
		import std.stdio;

		writeln("Loaded image: ", filename, " with size: ", ppm.mWidth, "x", ppm.mHeight);
		glTexImage2D(
			GL_TEXTURE_2D, // 2D Texture
			0, // mimap level 0
			GL_RGB, // Internal format for OpenGL
			ppm.mWidth, // width of incoming data
			ppm.mHeight, // height of incoming data
			0, // border (must be 0)
			GL_RGB, // image format
			GL_UNSIGNED_BYTE, // image data 
			image_data.ptr); // pixel array on CPU data

		glGenerateMipmap(GL_TEXTURE_2D);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

		// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
		// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
		// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
		// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	
		return mTextureID;
	}
}
