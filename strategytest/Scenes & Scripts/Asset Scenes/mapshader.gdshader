shader_type spatial;

uniform sampler2D texture_albedo;
uniform sampler2D texture_normal : hint_normal;
uniform float dune_scale : hint_range(0.1, 10.0) = 2.0;
uniform float heat_distortion_strength : hint_range(0.0, 10.0) = 1.0;
uniform float time_scale : hint_range(0.1, 10.0) = 1.0;

// Colors for gradient (low and high areas of sand)
uniform vec3 low_sand_color  = vec3(0.8, 0.8, 0.6);
uniform vec3 high_sand_color = vec3(0.8, 0.7, 0.5);

// Main function
void fragment() {
    // Get UV coordinates
    vec2 uv = UV;

    // Apply a repeating dune pattern using waves
    float dune_pattern = sin(uv.x * dune_scale) * cos(uv.y * dune_scale);

    //randomization
    dune_pattern += texture(texture_normal, uv * dune_scale * 0.5).r * 1.5;

    // Calculate height-based sand color gradient
    vec3 sand_color = mix(low_sand_color, high_sand_color, clamp(dune_pattern, 0.0, 1.0));

    // Sample base albedo texture
    vec3 albedo = vec3(0.796, 0.663, 0.4).rgb;

    // Combine with the sand color
    ALBEDO = mix(albedo, sand_color, 0.5);

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