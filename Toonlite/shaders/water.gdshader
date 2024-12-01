shader_type spatial;
render_mode cull_disabled;

uniform vec3 albedo: source_color;
uniform float metallic: hint_range(0.0, 1.0) = 0;
uniform float roughness: hint_range(0.0, 1.0) = 0.02;
uniform float alpha: hint_range(0.0, 1.0, 0.005) = 0.8;

uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform vec2 direction = vec2(2.0, 0.0);
uniform vec2 direction2 = vec2(0.0, 1.0);

uniform float time_scale: hint_range(0.0, 1.0, 0.005) = 0.025;
uniform float noise_scale: hint_range(0.0, 1.0, 0.005) = 0.025;
uniform float height_scale: hint_range(0.0, 1.0, 0.005) = 0.025;

//Varying variables
varying float height;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_position.xz / noise_scale + TIME * time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	//Time calculations for wave/texture/normal map movement
	vec2 time = (TIME * direction) * time_scale;
	vec2 time2 = (TIME * direction2) * time_scale;
	
	//One texture(normal map)
	vec3 normal = texture(texture_normal, UV).rgb;
	//Blends two textures(normal maps) into one
	vec3 normal_blend = mix(texture(texture_normal, UV).rgb, texture(texture_normal2, UV).rgb, 0.5);
	//Add time to UV to animate the normal map
	vec3 normal_blend_animated = mix(texture(texture_normal, UV + time).rgb, texture(texture_normal2, UV + time).rgb, 0.5);
	//Swap UV of the normal maps as vector positions to simulate waves
	vec3 normal_blend_wave = mix(texture(texture_normal, world_position.xz + time).rgb, texture(texture_normal2, world_position.xz + time).rgb, 0.5);
	
	ALPHA = alpha;
	ALBEDO = albedo;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend_wave;
	//EMISSION = albedo;
}
