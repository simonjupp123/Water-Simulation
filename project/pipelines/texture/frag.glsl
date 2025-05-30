#version 410 core

in vec2 vTexCoords;
in vec3 vNormal;
in vec3 vFragPos;
out vec4 fragColor;

uniform sampler2D sampler1;
uniform vec3 lightPos;

uniform vec3 viewPos;

vec3 CalcPointLight(vec3 pos, vec3 normal, vec3 fragPos, vec3 viewDir);

void main()
{	
	vec3 viewDir = normalize(viewPos - vFragPos);
	//vec3 color = texture(sampler1,vTexCoords).rgb;
	vec3 color = vec3(0.588f, 0.29f, 0.0f);
	vec3 result = CalcPointLight(lightPos, vNormal, vFragPos, viewDir) * color;
	fragColor = vec4(result,1.0);
}


vec3 CalcPointLight(vec3 pos, vec3 normal, vec3 fragPos, vec3 viewDir){
	vec3 lightDir = normalize(pos - fragPos);
    float diff = max(dot(normal, lightDir), 0.0f);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0f), 64);
    float distance = length(pos - fragPos);
    float attenuation = 1000.0 / (1.0 + 0.09f * distance + 0.032 * (distance * distance));    
	float ambientStength = 0.2f;
	float specularStrength = 0.2f;
	vec3 ambient = vec3(1.0f,1.0f,1.0f) * ambientStength;
	vec3 diffuse = vec3(1.0f,1.0f,1.0f) *  diff ;
	vec3 specular = vec3(1.0f,1.0f,1.0f) * spec * specularStrength;
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
}