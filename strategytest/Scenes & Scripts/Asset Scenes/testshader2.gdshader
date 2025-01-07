shader_type spatial;

// Konstanten für Testzwecke
const vec3 lightDirection = vec3(0.5, -1.0, 0.5); // Licht von schräg oben
const vec3 sandColor = vec3(0.6, 0.9, 0.4);    // Heller Sand
const vec3 rockColor = vec3(0.6, 0.7, 0.8);       // Dunklere Steine
const float time = 1.0;                           // Statische Zeit für Test

// Helferfunktionen
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 uv) {
    float value = 0.0;
    float scale = 1.0;
    float amplitude = 0.5;

    for (int i = 0; i < 5; i++) {
        value += noise(uv * scale) * amplitude;
        scale *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

void main() {
    // Simulierte Eingaben
    vec2 fragTexCoord = vec2(0.5, 0.5);              // Zentrierte Texturkoordinaten
    vec3 fragNormal = normalize(vec3(0.0, 1.0, 0.0)); // Vertikale Normale
    vec3 fragPosition = vec3(1.0, 0.0, 0.0);         // Eine Position im Raum
	vec4 gl_FragColor;

    // Skalierte Texturkoordinaten
    vec2 uv = fragTexCoord * 10.0; // Größere Muster
    float height = fbm(uv);

    // Basisfarbe je nach Höhe
    vec3 baseColor = mix(sandColor, rockColor, smoothstep(0.5, 0.8, height));

    // Dynamische Ripple-Effekte
    float ripple = sin((fragPosition.x + time) * 2.0) * 0.02;
    height += ripple;

    // Beleuchtung berechnen
    vec3 normal = normalize(fragNormal + vec3(0.0, 0.0, ripple));
    float light = max(dot(normal, -lightDirection), 0.0);

    // Finaler Farbwert
    vec3 finalColor = baseColor * (0.5 + 0.5 * light);

    // Setze die Ausgabe
    gl_FragColor = vec4(finalColor, 1.0);
}