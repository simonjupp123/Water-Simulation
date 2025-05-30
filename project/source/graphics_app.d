/// The main graphics application with the main graphics loop.
module graphics_app;
import std.stdio;
import core;
import mesh, linear, scene, materials, geometry, rendertarget, graphics_window;
import platform;

import bindbc.sdl;
import bindbc.opengl;

/// The main graphics application.
struct GraphicsApp
{
	bool mGameIsRunning = true;
	bool mRenderWireframe = false;

	// Window for the graphics application
	GraphicsWindow mWindow;
	// Scene
	SceneTree mSceneTree;
	SceneTree mSceneTreePre; // For pre-rendering to render targets
	// Camera
	Camera mCamera;
	vec3 mLightPos;
	vec4 mClipPlane = vec4(0.0f, 1.0f, 0.0f, 0.0f); // x,y,z,d for plane equation Ax + By + Cz + D = 0
	float mWaterHeight;
	// Renderer
	Renderer mRenderer;
	// Note: For future, you can use for post rendering effects on the renderer
	//		PostRenderDraw mPostRenderer;

	RenderTarget mReflectionRenderTarget;
	RenderTarget mRefractionRenderTarget;

	/// Setup OpenGL and any libraries
	this(string title, int major_ogl_version, int minor_ogl_version)
	{
		// Create a window
		mWindow = new OpenGLWindow(title, major_ogl_version, minor_ogl_version);
		// Create a renderer
		// NOTE: For now, our renderer will draw into the default renderbuffer (so 'null' for final pamater.
		mReflectionRenderTarget = new RenderTarget(640, 480);
		mRefractionRenderTarget = new RenderTarget(640, 480);

		mRenderer = new Renderer(mWindow, 640, 480, null);
		// NOTE: In future, you can create a custom render target to draw to as follows.
		//       mRenderer = new Renderer(mWindow,640,480, new RenderTarget(640,480));
		// Handle effects for the renderer
		// mPostRenderer = new PostRenderDraw("screen","./pipelines/screen/"); 

		// Create a camera
		mCamera = new Camera();
		// Create (or load) a Scene Tree
		mSceneTree = new SceneTree("root");
		mSceneTreePre = new SceneTree("root");
	}

	/// Destructor
	~this()
	{
	}

	/// Handle input
	void Input()
	{
		// Store an SDL Event
		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			if (event.type == SDL_QUIT)
			{
				writeln("Exit event triggered (probably clicked 'x' at top of the window)");
				mGameIsRunning = false;
			}
			if (event.type == SDL_KEYDOWN)
			{
				if (event.key.keysym.scancode == SDL_SCANCODE_ESCAPE)
				{
					writeln("Pressed escape key and now exiting...");
					mGameIsRunning = false;
				}
				else if (event.key.keysym.sym == SDLK_TAB)
				{
					mRenderWireframe = !mRenderWireframe;
				}
				if (event.key.keysym.sym == SDLK_s)
				{
					mCamera.MoveBackward();
				}
				if (event.key.keysym.sym == SDLK_w)
				{
					mCamera.MoveForward();
				}
				if (event.key.keysym.sym == SDLK_a)
				{
					mCamera.MoveLeft();
				}
				if (event.key.keysym.sym == SDLK_d)
				{
					mCamera.MoveRight();
				}
				if (event.key.keysym.sym == SDLK_q)
				{
					mCamera.MoveUp();
				}
				if (event.key.keysym.sym == SDLK_z)
				{
					mCamera.MoveDown();
				}
				else if (event.key.keysym.sym == SDLK_c)
				{
					writeln("Camera forward: ", mCamera.mForwardVector);
					writeln("Camera up: ", mCamera.mUpVector);
					writeln("Camera right: ", mCamera.mRightVector);
					writeln("Camera pitch: ", mCamera.pitch);
				}
				writeln("Camera Position: ", mCamera.mEyePosition);
			}
		}

		// Retrieve the mouse position
		int mouseX, mouseY;
		SDL_GetMouseState(&mouseX, &mouseY);
		mCamera.MouseLook(mouseX, mouseY);
	}

	/// A helper function to setup a scene.
	/// NOTE: In the future this can use a configuration file to otherwise make our graphics applications
	///       data-driven.
	void SetupScene()
	{
		// Create a pipeline and associate it with a material
		// that can be attached to meshes.
		// Pipeline basicLightPipeline = new Pipeline("basic", "./pipelines/basic/");
		// IMaterial basicLightMaterial = new BasicMaterial("basic");

		// Create an object and add it to our scene tree
		//make a surface, meshnode and add to scene tree

		//Create a basic terrain

		//create basic quad for water 
		// MakeMeshFromHeightmap();
		Pipeline texturePipeline = new Pipeline("multiTexturePipeline", "./pipelines/multitexture/");
		IMaterial multiTextureMaterial = new MultiTextureMaterial("multiTexturePipeline", "./assets/sand.ppm", "./assets/dirt.ppm", "./assets/grass.ppm", "./assets/snow.ppm");
		multiTextureMaterial.AddUniform(new Uniform("sampler1", 0));
		multiTextureMaterial.AddUniform(new Uniform("sampler2", 1));
		multiTextureMaterial.AddUniform(new Uniform("sampler3", 2));
		multiTextureMaterial.AddUniform(new Uniform("sampler4", 3));
		multiTextureMaterial.AddUniform(new Uniform("uModel", "mat4", null));
		multiTextureMaterial.AddUniform(new Uniform("uView", "mat4", mCamera.mViewMatrix.DataPtr()));
		multiTextureMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
		multiTextureMaterial.AddUniform(new Uniform("uClipPlane", "vec4", mClipPlane.DataPtr()));
		multiTextureMaterial.AddUniform(new Uniform("lightPos", "vec3", null));
		multiTextureMaterial.AddUniform(new Uniform("viewPos", "vec3", mCamera.mEyePosition.DataPtr()));

		ISurface terrain = new SurfaceTerrain(150, 150, "./assets/heightmapPerlin.ppm", 150, 150);
		MeshNode m2 = new MeshNode("terrain", terrain, multiTextureMaterial);
		mSceneTree.GetRootNode().AddChildSceneNode(m2);
		mSceneTreePre.GetRootNode().AddChildSceneNode(m2);

		Pipeline basicPipeline = new Pipeline("basicPipeline", "./pipelines/basic/");
		IMaterial basicMaterial = new BasicMaterial("basicPipeline");
		basicMaterial.AddUniform(new Uniform("uModel", "mat4", null));
		basicMaterial.AddUniform(new Uniform("uView", "mat4", mCamera.mViewMatrix.DataPtr()));
		basicMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
		mWaterHeight = 15.0f;

		Pipeline normalMap = new Pipeline("normalmap", "./pipelines/normalmap/");
		IMaterial normalMaterial = new NormalMapMaterial("normalmap", "./assets/Water.ppm", "./assets/water_normal.ppm", "./assets/waterDUDV.ppm");
		normalMaterial.AddUniform(new Uniform("offset", 0.0f));
		// Create an object and add it to our scene tree
		SurfaceWater obj = MakeWaterTexturedNormalMappedQuad(150, 150, mWaterHeight);
		WaterNode m1 = new WaterNode("quad", obj, normalMaterial);
		mSceneTree.GetRootNode().AddChildSceneNode(m1);

		// // //create a basic light
		ISurface lightGeo1 = new LightGeometry(vec3(1.0f, 1.0f, 1.0f)); // actually creates the vertcs for cube light
		LightNode light1 = new LightNode("light1", lightGeo1, basicMaterial);
		mSceneTree.GetRootNode().AddChildSceneNode(light1);

		Pipeline texture = new Pipeline("texture", "./pipelines/texture/");
		IMaterial textureMaterial = new TextureMaterial("texture", "./assets/brick.ppm");
		textureMaterial.AddUniform(new Uniform("lightPos", "vec3", null));
		textureMaterial.AddUniform(new Uniform("viewPos", "vec3", mCamera.mEyePosition.DataPtr()));
		ISurface boat = new BasicOBJ("./assets/boat.obj");
		MeshNode boatNode = new MeshNode("boat", boat, textureMaterial);
		mSceneTree.GetRootNode().AddChildSceneNode(boatNode);
		mSceneTreePre.GetRootNode().AddChildSceneNode(boatNode);

	}

	/// Update gamestate
	void Update()
	{
		static float time = 0;
		time += 0.0001;

		// MeshNode terrain = cast(MeshNode) mSceneTree.FindNode("terrain");
		// terrain.mModelMatrix = MatrixMakeTranslation(vec3(1.0f, -50.0, 0.0f));

		// WaterNode water = cast(WaterNode) mSceneTree.FindNode("water");
		// water.mModelMatrix = MatrixMakeTranslation(vec3(1.0f, -50.0, 0.0f));

		WaterNode quad = cast(WaterNode) mSceneTree.FindNode("quad");
		quad.mMaterial.mUniformMap["offset"].Set(time % 1.0f);
		// quad.mModelMatrix = MatrixMakeTranslation(vec3(1.0f, -50.0, 0.0f));

		LightNode n = cast(LightNode) mSceneTree.FindNode("light1");
		n.mModelMatrix = MatrixMakeTranslation(vec3(75.0f, 100.0, 75.0f));
		// mLightPos = vec3(75.0f, 15.0, 75.0f);
		n.mModelMatrix = n.mModelMatrix * MatrixMakeScale(vec3(5.2f, 5.2f, 5.2f));

		vec3 worldTranslate = vec3(77.8188, mWaterHeight + .7, 40.4416);
		MeshNode boat = cast(MeshNode) mSceneTree.FindNode("boat");

		auto surface2 = cast(BasicOBJ) boat.GetGeometry();
		auto waterSurface = cast(SurfaceWater) quad.GetGeometry(); //cast to surface water to get height
		float[] contactPoints;
		//hardcoded... but works
		contactPoints ~= surface2
			.allData[surface2.mIndexData[334] * 8 .. surface2.mIndexData[334] * 8 + 3];
		contactPoints ~= surface2
			.allData[surface2.mIndexData[58] * 8 .. surface2.mIndexData[58] * 8 + 3];
		contactPoints ~= surface2
			.allData[surface2.mIndexData[100] * 8 .. surface2.mIndexData[100] * 8 + 3];
		//round x,z to nearest water point:

		contactPoints[0] = cast(int) contactPoints[0] + worldTranslate[0];
		contactPoints[2] = cast(int) contactPoints[2] + worldTranslate[2];
		contactPoints[6] = cast(int) contactPoints[6] + worldTranslate[0];
		contactPoints[8] = cast(int) contactPoints[8] + worldTranslate[2];
		import std.math : cos, sin, atan2;

		float h1 = (cos(contactPoints[2] + waterSurface.time) * sin(
				waterSurface.time + contactPoints[0])) * 0.5 + mWaterHeight;
		float h2 = (cos(contactPoints[8] + waterSurface.time) * sin(
				waterSurface.time + contactPoints[6])) * 0.5 + mWaterHeight;
		float distance = contactPoints[8] - contactPoints[2];
		float angle = atan2(h1 - h2, distance);
		//writeln("h1: ", h1, " h2: ", h2, " distance: ", distance, " angle: ", angle);
		boat.mModelMatrix = MatrixMakeTranslation(worldTranslate) * MatrixMakeXRotation(angle);

	}

	/// Render our scene by traversing the scene tree from a specific viewpoint
	void Render()
	{
		if (mRenderWireframe)
		{
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
		}
		else
		{
			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		}

		glEnable(GL_CLIP_DISTANCE0);
		// Render the scene tree form a specific camera
		//should get waterheight var and unifrom plane variable

		//general algo for reflect is you invert camera pitch and drop the height 2x above water height

		float heightChange = 2 * (mCamera.mEyePosition.y - mWaterHeight);
		mCamera.SetCameraPosition(mCamera.mEyePosition.x, mCamera.mEyePosition.y - heightChange, mCamera
				.mEyePosition.z);
		mCamera.InvertPitch();
		mClipPlane = vec4(0.0f, 1.0f, 0.0f, -1 * mWaterHeight);
		MeshNode terrain = cast(MeshNode) mSceneTreePre.FindNode("terrain");
		terrain.mMaterial.mUniformMap["uClipPlane"].Set(mClipPlane.DataPtr());
		mRenderer.mRenderTarget = mReflectionRenderTarget;
		mRenderer.Render(mSceneTreePre, mCamera);

		mCamera.SetCameraPosition(mCamera.mEyePosition.x, mCamera.mEyePosition.y + heightChange, mCamera
				.mEyePosition.z);
		mCamera.InvertPitch();
		mClipPlane = vec4(0.0f, -1.0f, 0.0f, mWaterHeight);
		terrain = cast(MeshNode) mSceneTreePre.FindNode("terrain");
		terrain.mMaterial.mUniformMap["uClipPlane"].Set(mClipPlane.DataPtr());
		mRenderer.mRenderTarget = mRefractionRenderTarget;
		mRenderer.Render(mSceneTreePre, mCamera);

		//Hard coding GL_texture calls, was not working with initialziation stage,
		// GL_texture 3 wouldnt update properly,?
		PipelineUse("normalmap");
		WaterNode water = cast(WaterNode) mSceneTree.FindNode("quad");
		glActiveTexture(GL_TEXTURE9);
		glBindTexture(GL_TEXTURE_2D, mReflectionRenderTarget.mTexture.GetTextureID());
		water.mMaterial.mUniformMap["reflectTex"].Set(9);
		glActiveTexture(GL_TEXTURE10);
		glBindTexture(GL_TEXTURE_2D, mRefractionRenderTarget.mTexture.GetTextureID());
		water.mMaterial.mUniformMap["refractTex"].Set(10);
		glDisable(GL_CLIP_DISTANCE0); //in case glip distance disable doesnt work:
		//mClipPlane = vec4(0.0f, -1.0f, 0.0f, 10000);
		// MeshNode terrain = cast(MeshNode) mSceneTree.FindNode("terrain");
		// terrain.mMaterial.mUniformMap["uClipPlane"].Set(mClipPlane.DataPtr());
		mRenderer.mRenderTarget = null;
		mRenderer.Render(mSceneTree, mCamera);
	}

	/// Process 1 frame
	void AdvanceFrame()
	{
		Input();
		Update();
		Render();

		SDL_Delay(16); // NOTE: This is a simple way to cap framerate at 60 FPS,
		// 		   you might be inclined to improve things a bit.
	}

	/// Main application loop
	void Loop()
	{
		// Setup the graphics scene
		SetupScene();

		// Lock mouse to center of screen
		// This will help us get a continuous rotation.
		// NOTE: On occasion folks on virtual machine or WSL may not have this work,
		//       so you'll have to compute the 'diff' and reposition the mouse yourself.
		SDL_WarpMouseInWindow(mWindow.mWindow, 640 / 2, 320 / 2);

		// Run the graphics application loop
		while (mGameIsRunning)
		{
			AdvanceFrame();
		}
	}
}
