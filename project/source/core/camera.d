/// This represents a camera abstraction.
module camera;

import linear;
import bindbc.opengl;
import std.math;

/// Camera abstraction.
class Camera
{
    mat4 mViewMatrix;
    mat4 mProjectionMatrix;

    vec3 mEyePosition; /// This is our 'translation' value
    // Axis of the camera
    vec3 mUpVector; /// This is 'up' in the world
    vec3 mForwardVector; /// This is on the camera axis
    vec3 mRightVector; /// This is where 'right' is
    float yaw = -90.0f; // yaw is initialized to -90.0 degrees since a yaw of 0.0 results in a direction vector pointing to the right
    float pitch = 0.0f;

    /// Constructor for a camera
    this()
    {
        // Setup our camera (view matrix) 
        mViewMatrix = MatrixMakeIdentity();

        // Setup our perspective projection matrix
        // NOTE: Assumption made here is our window is always 640/480 or the similar aspect ratio.
        mProjectionMatrix = MatrixMakePerspective(90.0f.ToRadians, 480.0f / 640.0f, 0.1f, 1000.0f);

        /// Initial Camera setup
        // mEyePosition = vec3(0.0f, 0.0f, 0.0f);
        mEyePosition = vec3(51.634f, 0f, -19.2909f);
        // Eye position
        // Forward vector matching the positive z-axis
        mForwardVector = vec3(0.0f, 0.0f, 1.0f);
        // Where up is in the world initially
        mUpVector = vec3(0.0f, 1.0f, 0.0f);
        // Where right is initially
        mRightVector = vec3(1.0f, 0.0f, 0.0f);

    }

    /// Position the eye of the camera in the world
    void SetCameraPosition(vec3 v)
    {

        mEyePosition = v;
        UpdateViewMatrix();
    }
    /// Position the eye of the camera in the world
    void SetCameraPosition(float x, float y, float z)
    {

        mEyePosition = vec3(x, y, z);
        UpdateViewMatrix();
    }

    /// Builds a matrix for where the matrix is looking
    /// given the following parameters
    mat4 LookAt(vec3 eye, vec3 direction, vec3 up)
    {
        // Handle the translation, but negate the values
        mat4 translation = MatrixMakeTranslation(-mEyePosition);

        mat4 look = mat4(mRightVector.x, mRightVector.y, mRightVector.z, 0.0f,
            mUpVector.x, mUpVector.y, mUpVector.z, 0.0f,
            mForwardVector.x, mForwardVector.y, mForwardVector.z, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f);
        // look = look.MatrixTranspose();

        return (look * translation);
    }

    /// Sets the view matrix and also retrieves it
    /// Retrieves the camera view matrix
    mat4 UpdateViewMatrix()
    {
        mViewMatrix = LookAt(mEyePosition,
            mEyePosition + mForwardVector,
            mUpVector);
        return mViewMatrix;
    }

    void MouseLook(int mouseX, int mouseY)
    {

        // TODO 

        static bool firstMouse = true;
        static lastX = 0;
        static lastY = 0;
        // pitch is initialized to 0.0 degrees
        if (firstMouse)
        {
            firstMouse = false;
            lastX = mouseX;
            lastY = mouseY;
        }

        float deltaX = (mouseX - lastX) * -0.2;
        float deltaY = (lastY - mouseY) * -0.2;
        yaw += deltaX;
        pitch += deltaY;
        if (pitch > 89.0f)
            pitch = 89.0f;
        if (pitch < -89.0f)
            pitch = -89.0f;

        vec3 direction = vec3(0.0f, 0.0f, 0.0f);
        direction.x = cos(ToRadians(yaw)) * cos(ToRadians(pitch));
        direction.y = sin(ToRadians(pitch));
        direction.z = sin(ToRadians(yaw)) * cos(ToRadians(pitch));
        mForwardVector = Normalize(direction);
        mRightVector = Cross(mForwardVector, vec3(0.0f, 1.0f, 0.0f));
        mRightVector = mRightVector.Normalize();

        mUpVector = Cross(mRightVector, mForwardVector);
        mUpVector = mUpVector.Normalize();

        lastX = mouseX;
        lastY = mouseY;
        UpdateViewMatrix();
    }

    void InvertPitch()
    {
        pitch = -pitch;
        vec3 direction = vec3(0.0f, 0.0f, 0.0f);
        direction.x = cos(ToRadians(yaw)) * cos(ToRadians(pitch));
        direction.y = sin(ToRadians(pitch));
        direction.z = sin(ToRadians(yaw)) * cos(ToRadians(pitch));
        mForwardVector = Normalize(direction);
        mRightVector = Cross(mForwardVector, vec3(0.0f, 1.0f, 0.0f));
        mRightVector = mRightVector.Normalize();

        mUpVector = Cross(mRightVector, mForwardVector);
        mUpVector = mUpVector.Normalize();
        UpdateViewMatrix();
        // import std.stdio;

        // writeln("Pitch inverted: ", pitch);
    }

    void MoveForward()
    {
        //UpdateViewMatrix();
        // TODO 
        vec3 direction = mForwardVector;
        direction = direction * 1.0f;

        SetCameraPosition(mEyePosition.x - direction.x,
            mEyePosition.y - direction.y,
            mEyePosition.z - direction.z);
    }

    void MoveBackward()
    {
        //UpdateViewMatrix();
        // TODO 
        vec3 direction = mForwardVector;
        direction = direction * 1.0f;

        SetCameraPosition(mEyePosition.x + direction.x,
            mEyePosition.y + direction.y,
            mEyePosition.z + direction.z);
    }

    void MoveLeft()
    {
        //UpdateViewMatrix();
        // TODO 

        SetCameraPosition(mEyePosition.x - mRightVector.x,
            mEyePosition.y - mRightVector.y,
            mEyePosition.z - mRightVector.z);

    }

    void MoveRight()
    {
        //UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x + mRightVector.x,
            mEyePosition.y + mRightVector.y,
            mEyePosition.z + mRightVector.z);
    }

    void MoveUp()
    {
        // UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x,
            mEyePosition.y + 1.0f,
            mEyePosition.z);
    }

    void MoveDown()
    {
        //UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x,
            mEyePosition.y - 1.0f,
            mEyePosition.z);
    }
}
