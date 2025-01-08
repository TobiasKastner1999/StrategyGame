shader_type spatial;

uniform sampler2D mask_texture;
uniform vec4 albedo_a = vec4(1.0f);
uniform sampler2D texture_a;
uniform vec4 albedo_b = vec4(1.0f);
uniform sampler2D texture_b;

uniform float dune_scale : hint_range(0.1, 10.0) = 2.0;
uniform float heat_distortion_strength : hint_range(0.0, 10.0) = 1.0;
uniform float time_scale : hint_range(0.1, 10.0) = 1.0;
// Colors for gradient (low and high areas of sand)
uniform vec3 low_sand_color  = vec3(0.8, 0.8, 0.6);
uniform vec3 high_sand_color = vec3(0.8, 0.7, 0.5);




void fragment() {
	vec3 mask = texture(mask_texture, UV).rgb;
	vec3 a = albedo_a.rgb * texture(texture_a, UV).rgb;
	vec3 b = albedo_b.rgb * texture(texture_b, UV).rgb;
	vec3 color = mix(a, b, mask);
	ALBEDO = color;



    // Get UV coordinates
    vec2 uv = UV;

    // Apply a repeating dune pattern using waves
    float dune_pattern = sin(uv.x * dune_scale) * cos(uv.y * dune_scale);

    //randomization
    dune_pattern += texture(texture_b, uv * dune_scale * 0.5).r * 1.5;

    // Calculate height-based sand color gradient
    vec3 sand_color = mix(low_sand_color, high_sand_color, clamp(dune_pattern, 0.0, 1.0));

    

    // Apply normal map for detailed lighting
    //vec3 normal_map = texture(texture_normal, uv).rgb;
    //NORMAL = normalize(TANGENT * (normal_map * 2.0 - 1.0));

    // Add heat distortion (using time-based offset)
    float distortion = sin(TIME * time_scale + uv.y * 5.0) * heat_distortion_strength;
    uv += vec2(distortion, distortion * 0.5);

    // Finish up
    ROUGHNESS = 5.0; // Sand is rough
    METALLIC = 1.3; // Sand is not metallic
}
