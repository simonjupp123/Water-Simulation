#version 410 core

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoords;
layout(location=2) in vec3 aNormal;
layout(location=3) in vec3 aBiNormal;
layout(location=4) in vec3 aBiTangent;

out VS_OUT {
    vec3 FragPos;
    vec2 vTexCoords;
    mat3 TBN;
	vec4 clipSpace;
} vs_out; 

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void main()
{
	vs_out.vTexCoords = aTexCoords;
	
	vec4 finalPosition = uProjection * uView * uModel * vec4(aPosition,1.0f);

	vs_out.FragPos = vec3(uModel * vec4(aPosition, 1.0));
	vs_out.clipSpace = finalPosition;
	vec3 T = normalize(vec3(uModel * vec4(aBiNormal,   0.0)));
	vec3 B = normalize(vec3(uModel * vec4(aBiTangent, 0.0)));
	vec3 N = normalize(vec3(uModel * vec4(aNormal,    0.0)));
	mat3 TBN = mat3(T, B, N);
	vs_out.TBN = TBN;
	// Note: Something subtle, but we need to use the finalPosition.w to do the perspective divide
	gl_Position = vec4(finalPosition.x, finalPosition.y, finalPosition.z, finalPosition.w);
}


