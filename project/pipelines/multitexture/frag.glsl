#version 410 core

in vec2 vTexCoords;
in vec4 vWorldCoords;
in vec3 vNormal;
in vec3 vFragPos;

out vec4 fragColor;

uniform sampler2D sampler1;
uniform sampler2D sampler2;
uniform sampler2D sampler3;
uniform sampler2D sampler4;

uniform float gHeight0 = 19;
uniform float gHeight1 = 21;
uniform float gHeight2 = 35;
uniform float gHeight3 = 48;

uniform vec3 lightPos;

uniform vec3 viewPos;

vec3 CalcPointLight(vec3 pos, vec3 normal, vec3 fragPos, vec3 viewDir);

vec3 GetColor(){
		vec3 color;

		float Height = vWorldCoords.y;
		if (Height < gHeight0) {
			color = texture(sampler1, vTexCoords).rgb;
		} 
		else if (Height < gHeight1) {
			vec3 Color0 = texture(sampler1, vTexCoords).rgb;
			vec3 Color1 = texture(sampler2, vTexCoords).rgb;
			float Delta = gHeight1 - gHeight0;
			float Factor = (Height - gHeight0) / Delta;
			color = mix(Color0, Color1, Factor);
		} 
		else if (Height < gHeight2) {

			if(dot(vNormal,vec3(0,-1.0,0)) > 0.7f){
				color = texture(sampler3, vTexCoords).rgb;

			}else{
				color = texture(sampler2, vTexCoords).rgb;
			}

			float Factor = dot(vNormal,vec3(0,-1.0,0));

			//vec3 Color0 = texture(sampler2, vTexCoords).rgb;
			//vec3 Color1 = texture(sampler3, vTexCoords).rgb;
			//float Delta = gHeight2 - gHeight1;
			//float Factor = (Height - gHeight1) / Delta;
			//color = mix(Color0, Color1, Factor);
		} else if (Height < gHeight3) {
			vec3 Color0 = texture(sampler3, vTexCoords).rgb;
			vec3 Color1 = texture(sampler4, vTexCoords).rgb;
			float Delta = gHeight3 - gHeight2;
			float Factor = (Height - gHeight2) / Delta;
			color = mix(Color0, Color1, Factor);
		} else {
			color = texture(sampler4, vTexCoords).rgb;
		}
		
		return color;
}

void main(){

	//fragColor = vec4(GetColor(), 1.0);

	vec3 viewDir = normalize(viewPos - vFragPos);
	vec3 result = CalcPointLight(lightPos, vNormal, vFragPos, viewDir) * GetColor();
	
	fragColor = vec4(result, 1.0);
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
