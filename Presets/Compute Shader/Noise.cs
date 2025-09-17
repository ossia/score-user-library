/*{
    "DESCRIPTION": "Generates random RGB noise in a read-write image",
    "CREDIT": "ossia score",
    "ISFVSN": "2.0",
    "MODE": "COMPUTE_SHADER",
    "CATEGORIES": ["GENERATOR", "NOISE"],
    "RESOURCES": [
      {
        "NAME": "NoiseImage",
        "TYPE": "image",
        "ACCESS": "read_write",
        "FORMAT": "RGBA8",
        "WIDTH": 100,
        "HEIGHT": 100
      },
      {
        "NAME": "seed",
        "TYPE": "float",
        "LABEL": "Random Seed",
        "DEFAULT": 0.0,
        "MIN": 0.0,
        "MAX": 1000.0
      },
      {
        "NAME": "brightness",
        "TYPE": "float",
        "LABEL": "Brightness",
        "DEFAULT": 1.0,
        "MIN": 0.0,
        "MAX": 2.0
      }
    ], 
    "PASSES": [{
      "LOCAL_SIZE": [16, 16, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "NoiseImage" }
    }]
}*/

// Simple hash function for pseudo-random generation
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031 + seed);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 randomRGB(vec2 coord, float seed) {
    return vec3(
        hash(coord, seed),
        hash(coord + vec2(17.0, 53.0), seed),
        hash(coord + vec2(241.0, 97.0), seed)
    );
}

void main() 
{
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(NoiseImage);
    if (coord.x >= size.x || coord.y >= size.y)
        return;
    
    // Generate random RGB values based on position and seed
    vec2 uv = vec2(coord) / vec2(size);
    float animatedSeed = seed + 0.000001 * TIME ;
    vec3 color = randomRGB(uv * 100.0, animatedSeed);
    
    // Apply brightness
    color *= brightness;
    
    // Write to the read-write image
    // FIXME LOAD first
    imageStore(NoiseImage, coord, vec4(color, 1.0));
}
