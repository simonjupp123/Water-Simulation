#version 410 core

layout(location=0) in vec3 aPosition;
layout(location=1) in vec3 aNormal;
layout(location=2) in vec2 aTexCoords;

out vec2 vTexCoords;
out vec4 vWorldCoords;
out vec3 vNormal;
out vec3 vFragPos;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

//-1 clips anything above, one clips anything below the OPPOSITE height
//const vec4 plane = vec4(0,1,0,-15);
//const vec4 plane = vec4(0,-1,0,15);

uniform vec4 uClipPlane;

void main()
{
	
	vTexCoords = aTexCoords;
	vNormal = aNormal;
	vWorldCoords = vec4(aPosition,1.0f);
	//vFragPos = vec3(uModel * vec4(aPosition, 1.0));
	vFragPos = aPosition;
	gl_ClipDistance[0] = dot(vWorldCoords, uClipPlane);

	vec4 finalPosition = uProjection * uView * uModel * vec4(aPosition,1.0f);

	// Note: Something subtle, but we need to use the finalPosition.w to do the perspective divide
	gl_Position = vec4(finalPosition.x, finalPosition.y, finalPosition.z, finalPosition.w);
}


