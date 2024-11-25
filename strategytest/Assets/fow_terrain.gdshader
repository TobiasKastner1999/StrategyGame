shader_type spatial;

uniform sampler2D mask_texture;
uniform vec4 albedo_a = vec4(1.0f);
uniform sampler2D texture_a;
uniform vec4 albedo_b = vec4(1.0f);
uniform sampler2D texture_b;

void fragment() {
	vec3 mask = texture(mask_texture, UV).rgb;
	vec3 a = albedo_a.rgb * texture(texture_a, UV).rgb;
	vec3 b = albedo_b.rgb * texture(texture_b, UV).rgb;
	vec3 color = mix(a, b, mask);
	ALBEDO = color;
}