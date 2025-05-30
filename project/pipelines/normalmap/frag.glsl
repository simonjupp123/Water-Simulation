#version 410 core

in VS_OUT {
    vec3 FragPos;
    vec2 vTexCoords;
    mat3 TBN;
	vec4 clipSpace;
} fs_in; 
out vec4 fragColor;

uniform sampler2D albedomap; // colors from texture
uniform sampler2D normalmap; // The normal map
uniform sampler2D dudv;
uniform sampler2D reflectTex;
uniform sampler2D refractTex;

uniform vec3 lightPos;

uniform vec3 viewPos;

vec3 CalcPointLight(vec3 pos, vec3 normal, vec3 fragPos, vec3 viewDir);

const float TexScale = 50.0f;

uniform float offset;

void main()
{
	vec3 viewDir = normalize(viewPos - fs_in.FragPos);

	float frenselFactor = clamp(dot(viewDir, vec3(0.0f,1.0f,0.0f))*1.5, 0.001, 0.9999);
	vec2 distortion = texture(dudv,fs_in.vTexCoords + offset).rg * 2.0 - 1.0;
	vec2 ndc = fs_in.clipSpace.xy/fs_in.clipSpace.w / 2.0f + 0.5f;
	//IMO really cool effect when the distortion for the texture is slightly different than the normal map distort
	vec3 texColor = texture(albedomap,fs_in.vTexCoords * TexScale+ (distortion * 0.3)).rgb;
	vec3 refactColor = texture(refractTex,clamp(ndc+ (distortion *0.2),0.001,0.999)).rgb;
	ndc.y = 1 - ndc.y;
	vec3 reflectColor = texture(reflectTex,clamp(ndc+ (distortion *0.2),0.001,0.999)).rgb;
	
	vec3 colors = mix(reflectColor, refactColor, frenselFactor);
	colors = mix(colors, texColor, 0.2f);

	vec3 normal = texture(normalmap, fs_in.vTexCoords * TexScale+ (distortion *0.2)).rgb;
	normal = normal * 2.0 - 1.0;
	normal = normalize(fs_in.TBN * normal);

	//lighting
	
	vec3 result = CalcPointLight(lightPos, normal, fs_in.FragPos, viewDir) * colors;
	//result = vec3(result.x * colors.x, result.y * colors.y, result.z * colors.z);
	fragColor = vec4(result, 1.0);
}





vec3 CalcPointLight(vec3 pos, vec3 normal, vec3 fragPos, vec3 viewDir){
	vec3 lightDir = normalize(pos - fragPos);
    float diff = max(dot(normal, lightDir), 0.0f);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0f), 128);
    float distance = length(pos - fragPos);
	//works for now but want to switch back to one giant direcitonal light
    float attenuation = 300.0 / (1.0 + 0.09f * distance + 0.032 * (distance * distance));    
	float ambientStength = 0.1f;
	float specularStrength = 0.8f;
	vec3 ambient = vec3(1.0f,1.0f,1.0f) * ambientStength;
	vec3 diffuse = vec3(1.0f,1.0f,1.0f) *  diff;
	vec3 specular = vec3(1.0f,1.0f,1.0f) * spec * specularStrength;
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
}

