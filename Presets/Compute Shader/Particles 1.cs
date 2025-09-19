/*{
  "DESCRIPTION": "Particle simulation with parallel compute",
  "CREDIT": "ossia score",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["SIMULATION", "PARTICLES", "PHYSICS"],
  "TYPES": [
    {
      "NAME": "Particle",
      "LAYOUT": [
        { "NAME": "position", "TYPE": "vec4" },
        { "NAME": "velocity", "TYPE": "vec4" },
        { "NAME": "color", "TYPE": "vec4" },
        { "NAME": "life", "TYPE": "float" }
      ]
    }
  ],
  "RESOURCES": [
    {
      "NAME": "inputImage",
      "TYPE": "texture"
    },
    {
      "NAME": "outputImage",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "RGBA8"
    },
    {
      "NAME": "forceStrength",
      "TYPE": "float",
      "LABEL": "Force Field Strength",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "forceType",
      "TYPE": "long",
      "VALUES": [0, 1],
      "LABELS": ["Attraction", "Repulsion"],
      "DEFAULT": 0,
      "LABEL": "Force Type"
    },
    {
      "NAME": "falloffPower",
      "TYPE": "float",
      "LABEL": "Distance Falloff Power",
      "DEFAULT": 2.0,
      "MIN": 0.5,
      "MAX": 4.0
    },
    {
      "NAME": "minDistance",
      "TYPE": "float",
      "LABEL": "Minimum Distance",
      "DEFAULT": 0.01,
      "MIN": 0.001,
      "MAX": 0.1
    },
    {
      "NAME": "deltaTime",
      "TYPE": "float",
      "LABEL": "Time Step",
      "DEFAULT": 0.016,
      "MIN": 0.001,
      "MAX": 0.1
    },
    {
      "NAME": "gravity",
      "TYPE": "point3D",
      "LABEL": "Gravity Vector",
      "DEFAULT": [0.0, -0.98, 0.0]
    },
    {
      "NAME": "windForce",
      "TYPE": "point3D",
      "LABEL": "Wind Force",
      "DEFAULT": [0.1, 0.0, 0.0]
    },
    {
      "NAME": "damping",
      "TYPE": "float",
      "LABEL": "Damping Factor",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "LABEL": "Decay Rate",
      "DEFAULT": 0.01,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "particleSize",
      "TYPE": "float",
      "LABEL": "Particle Size",
      "DEFAULT": 3.0,
      "MIN": 1.0,
      "MAX": 10.0
    },
    {
      "NAME": "showForceField",
      "TYPE": "bool",
      "LABEL": "Show Force Field",
      "DEFAULT": false
    },
    {
      "NAME": "gridSize",
      "TYPE": "long",
      "LABEL": "Force Grid Size",
      "DEFAULT": 32,
      "MIN": 8,
      "MAX": 64
    },
    {
      "NAME": "fadeWithLife",
      "TYPE": "bool",
      "LABEL": "Fade With Life",
      "DEFAULT": true
    },
    {
      "NAME": "reset",
      "TYPE": "event",
      "LABEL": "Reset Particles"
    },
    {
      "NAME": "ParticleData",
      "TYPE": "storage",
      "ACCESS": "read_write",
      "LAYOUT": [
       { "NAME": "particles", "TYPE": "Particle[]" }
      ]
    },
    {
      "NAME": "ForceFieldBuffer",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "RGBA32F"
    }
  ],
  "PASSES": [
    {
      "LOCAL_SIZE": [8, 8, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "ForceFieldBuffer" }
    },
    {
      "LOCAL_SIZE": [16, 1, 1],
      "EXECUTION_MODEL": { "TYPE": "MANUAL", "WORKGROUPS": [64, 1, 1] }
    },
    {
      "LOCAL_SIZE": [8, 8, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "outputImage" }
    }
  ]
}*/

// Simple hash function for random generation
float hash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec3 randomColor(float seed) {
  return vec3(hash(vec2(seed, 1.0)), hash(vec2(seed, 2.0)),
              hash(vec2(seed, 3.0)));
}

// Function to draw a line from point A to point B
float drawLine(vec2 pixel, vec2 a, vec2 b, float thickness) {
  vec2 pa = pixel - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  float dist = length(pa - ba * h);
  return 1.0 - smoothstep(0.0, thickness, dist);
}

// Function to draw an arrow
float drawArrow(vec2 pixel, vec2 start, vec2 end, float thickness) {
  float line = drawLine(pixel, start, end, thickness);

  // Draw arrowhead
  vec2 dir = normalize(end - start);
  vec2 arrowTip = end;
  vec2 arrowLeft = end - dir * 5.0 + vec2(-dir.y, dir.x) * 3.0;
  vec2 arrowRight = end - dir * 5.0 + vec2(dir.y, -dir.x) * 3.0;

  float arrowHead = max(drawLine(pixel, arrowTip, arrowLeft, thickness),
                        drawLine(pixel, arrowTip, arrowRight, thickness));

  return max(line, arrowHead);
}

void main_pass0() {
  ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
  ivec2 forceFieldSize = imageSize(ForceFieldBuffer);

  if (coord.x >= forceFieldSize.x || coord.y >= forceFieldSize.y)
    return;

  vec2 position = (vec2(coord) + 0.5) / vec2(forceFieldSize) * 2.0 - 1.0;
  vec3 totalForce = vec3(0.0);
  float totalWeight = 0.0;

  // Sample at multiple mip levels for hierarchical force calculation
  int maxMipLevel = textureQueryLevels(inputImage) - 1;

  // Start from coarse mip levels for distant forces
  for (int mip = maxMipLevel; mip >= max(0, maxMipLevel - 5); mip--) {
    ivec2 mipSize = textureSize(inputImage, mip);
    int stepSize = max(1, min(mipSize.x, mipSize.y) / 16);

    for (int x = 0; x < mipSize.x; x += stepSize) {
      for (int y = 0; y < mipSize.y; y += stepSize) {
        vec2 sampleCoord = (vec2(x, y) + 0.5) / vec2(mipSize);
        vec4 texelSample = textureLod(inputImage, sampleCoord, float(mip));

        float brightness = dot(texelSample.rgb, vec3(0.299, 0.587, 0.114));

        if (brightness > 0.01) {
          vec2 sourcePos = sampleCoord * 2.0 - 1.0;
          sourcePos.y = -sourcePos.y;

          vec2 toSource = sourcePos - position;
          float dist = max(length(toSource), minDistance);

          vec2 forceDir = normalize(toSource);
          float forceMagnitude = brightness / pow(dist, falloffPower);

          if (forceType == 0) {
            totalForce.xy += forceDir * forceMagnitude;
          } else {
            totalForce.xy -= forceDir * forceMagnitude;
          }

          totalWeight += forceMagnitude;
        }
      }
    }
  }

  if (totalWeight > 0.0) {
    totalForce.xy = (totalForce.xy / totalWeight) * forceStrength;
  }

  imageStore(ForceFieldBuffer, coord,
             vec4(totalForce.xy, length(totalForce.xy), 0.0));
}

void main_pass1() {
  // PASS 2: Particle Physics Update
  uint particleId = gl_GlobalInvocationID.x;

  // Handle case where we have more particles than compute threads
  uint particlesPerThread =
      (uint(particles.length()) + gl_NumWorkGroups.x * gl_WorkGroupSize.x - 1u) /
      (gl_NumWorkGroups.x * gl_WorkGroupSize.x);

  for (uint p = 0u; p < particlesPerThread; p++) {
    uint actualParticleId =
        particleId + p * gl_NumWorkGroups.x * gl_WorkGroupSize.x;

    if (actualParticleId >= uint(particles.length()))
      break;

    Particle particle = particles[actualParticleId];

    // Reset particles if reset event is triggered
    if (reset) {
      float seed = float(actualParticleId) * 0.1337;

      particle.position.x = hash(vec2(seed, 17.0)) * 2.0 - 1.0;
      particle.position.y = hash(vec2(seed, 37.0)) * 2.0 - 1.0;
      particle.position.z = 0.0;
      particle.position.w = 1.0;

      particle.velocity.x = (hash(vec2(seed, 53.0)) - 0.5) * 0.2;
      particle.velocity.y = (hash(vec2(seed, 71.0)) - 0.5) * 0.2;
      particle.velocity.z = 0.0;
      particle.velocity.w = 0.0;

      particle.color.rgb = randomColor(seed + 100.0);
      particle.color.a = 1.0;
      particle.life = 1.0;
    } else if (particle.life > 0.0) {
      // Sample precomputed force field at particle position
      vec2 forceTexCoord =
          particle.position.xy * 0.5 + 0.5; // Convert [-1,1] to [0,1]
      ivec2 forceFieldSize = imageSize(ForceFieldBuffer);
      ivec2 forceCoord = ivec2(forceTexCoord * vec2(forceFieldSize));
      forceCoord = clamp(forceCoord, ivec2(0), forceFieldSize - 1);

      // Use imageLoad since ForceFieldBuffer is an image2D, not sampler2D
      vec4 forceSample = imageLoad(ForceFieldBuffer, forceCoord);
      vec3 fieldForce = forceSample.xyz;

      vec3 totalForce = fieldForce + gravity + windForce;

      // Update velocity and position
      particle.velocity.xyz += totalForce * deltaTime;
      particle.velocity.xyz *= (1.0 - damping * deltaTime);
      particle.position.xyz += particle.velocity.xyz * deltaTime;

      // Update life
      particle.life = max(0.0, particle.life - deltaTime * decay);

      // Bounce off edges with energy loss
      if (abs(particle.position.x) > 1.0) {
        particle.position.x = sign(particle.position.x) * 1.0;
        particle.velocity.x *= -0.6;
      }
      if (abs(particle.position.y) > 1.0) {
        particle.position.y = sign(particle.position.y) * 1.0;
        particle.velocity.y *= -0.6;
      }

      // Respawn dead particles
      if (particle.life <= 0.0) {
        float seed = float(actualParticleId) * 0.1337 + TIME;

        particle.position.x = hash(vec2(seed, 117.0)) * 2.0 - 1.0;
        particle.position.y = 1.0; // Spawn at top
        particle.position.z = 0.0;
        particle.position.w = 1.0;

        particle.velocity.x = (hash(vec2(seed, 153.0)) - 0.5) * 0.2;
        particle.velocity.y = -0.1;
        particle.velocity.z = 0.0;
        particle.velocity.w = 0.0;

        particle.color.rgb = randomColor(seed + 200.0);
        particle.color.a = 1.0;
        particle.life = 1.0;
      }
    }

    // Write updated particle back to storage
    particles[actualParticleId] = particle;
  }
}

void main_pass2() {
  // PASS 3: Rendering (8x8 threads per workgroup)
  ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
  ivec2 texSize = imageSize(outputImage);

  if (coord.x >= texSize.x || coord.y >= texSize.y)
    return;

  vec4 pixelColor = vec4(0.0, 0.0, 0.0, 1.0);

  // Early exit optimization: track how many particles affect this pixel
  int particlesDrawn = 0;
  const int maxParticlesPerPixel = 20; // Limit overdraw for performance

  // Pre-calculate pixel position for distance checks
  vec2 pixelPos = vec2(coord);

  // Render particles with early exit optimization
  // TODO: put the particles in a grid so that we only iterate through the visible ones for 
  // each quadrant, e.g. have a basic octree
  for (uint i = 0u; i < uint(particles.length()); i++) {
    // Early exit if we've drawn enough particles for this pixel
    if (particlesDrawn >= maxParticlesPerPixel)
      break;

    Particle p = particles[i];

    // Skip dead particles
    if (p.life <= 0.0)
      continue;

    // Convert particle position to screen space
    vec2 screenPos = (p.position.xy + 1.0) * 0.5;
    vec2 particlePixel = screenPos * vec2(texSize);

    // Early rejection: quick distance check
    vec2 diff = pixelPos - particlePixel;
    float distSq = dot(diff, diff); // Use squared distance first to avoid sqrt

    // Compare squared distances to avoid sqrt when possible
    float particleSizeSq = particleSize * particleSize;
    if (distSq > particleSizeSq)
      continue;

    // Now calculate actual distance only for particles that might contribute
    float dist = sqrt(distSq);

    float intensity = 1.0 - (dist / particleSize);
    intensity = smoothstep(0.0, 1.0, intensity);

    // Skip if intensity is too low to be visible
    if (intensity < 0.01)
      continue;

    float alpha = fadeWithLife ? p.life : 1.0;
    vec3 particleColor = p.color.rgb * intensity * alpha;

    // Additive blending
    pixelColor.rgb += particleColor;
    particlesDrawn++;

    // Early exit if pixel is already saturated
    if (pixelColor.r >= 1.0 && pixelColor.g >= 1.0 && pixelColor.b >= 1.0)
      break;
  }

  // Clamp final color
  pixelColor.rgb = min(pixelColor.rgb, vec3(1.0));
  imageStore(outputImage, coord, pixelColor);
}

void main() {
  if (PASSINDEX == 0) 
    main_pass0();
  else if (PASSINDEX == 1)
    main_pass1();
  else if (PASSINDEX == 2)
    main_pass2();
}
