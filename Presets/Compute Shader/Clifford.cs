/*{
    "DESCRIPTION": "Generates polynomial strange attractors with parallel compute",
    "CREDIT": "Based on Paul Bourke's algorithm",
    "ISFVSN": "2.0",
    "MODE": "COMPUTE_SHADER",
    "CATEGORIES": ["GENERATOR", "CHAOS", "ATTRACTOR"],
    "RESOURCES": [
      {
        "NAME": "AttractorImage",
        "TYPE": "image",
        "ACCESS": "read_write",
        "FORMAT": "R32F",
        "WIDTH": 1024,
        "HEIGHT": 1024
      },
      {
        "NAME": "seed",
        "TYPE": "float",
        "LABEL": "Seed (for polynomial)",
        "DEFAULT": 1.0,
        "MIN": 0.0,
        "MAX": 10000.0
      },
      {
        "NAME": "pointsPerThread",
        "TYPE": "float",
        "LABEL": "Points Per Thread",
        "DEFAULT": 50.0,
        "MIN": 10.0,
        "MAX": 500.0
      },
      {
        "NAME": "brightness",
        "TYPE": "float",
        "LABEL": "Brightness",
        "DEFAULT": 0.02,
        "MIN": 0.00001,
        "MAX": 0.5
      },
      {
        "NAME": "fadeRate",
        "TYPE": "float",
        "LABEL": "Fade Rate",
        "DEFAULT": 0.995,
        "MIN": 0.0,
        "MAX": 1.0
      },
      {
        "NAME": "a",
        "TYPE": "float",
        "LABEL": "A",
        "DEFAULT": -1.4,
        "MIN": -3.0,
        "MAX": 3.0
      },
      {
        "NAME": "b",
        "TYPE": "float",
        "LABEL": "B",
        "DEFAULT": 1.6,
        "MIN": -3.0,
        "MAX": 3.0
      },
      {
        "NAME": "c",
        "TYPE": "float",
        "LABEL": "C",
        "DEFAULT": 1.0,
        "MIN": -3.0,
        "MAX": 3.0
      },
      {
        "NAME": "d",
        "TYPE": "float",
        "LABEL": "D",
        "DEFAULT": 0.7,
        "MIN": -3.0,
        "MAX": 3.0
      }
    ], 
    "PASSES": [{
      "LOCAL_SIZE": [16, 16, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "AttractorImage" }
    },{
      "LOCAL_SIZE": [16, 16, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "AttractorImage" }
    },{
      "LOCAL_SIZE": [16, 16, 1],
      "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "AttractorImage" }
    }
    ]
}*/

float hash(float p)
{
  p = fract(p * 0.1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

float hash2(vec2 p)
{
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main()
{
  ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
  ivec2 size = imageSize(AttractorImage);

  if (coord.x >= size.x || coord.y >= size.y)
    return;


  if (PASSINDEX == 0)
  {
    // Each thread fades its own pixel
    vec4 col = imageLoad(AttractorImage, coord);
    col *= fadeRate;
    imageStore(AttractorImage, coord, col);
  }
  else if (PASSINDEX == 1)
  {
    // Generate unique seed for this thread
    vec2 threadId = vec2(coord);
    float threadSeed = hash2(threadId + seed);

    // Each thread traces its own particle
    {
      // CLIFFORD ATTRACTOR
      // Initialize particle position uniquely per thread
      float x = (hash2(threadId + vec2(0.1, 0.2)) - 0.5) * 4.0;
      float y = (hash2(threadId + vec2(0.3, 0.4)) - 0.5) * 4.0;

      // Skip transient
      for (int i = 0; i < 20; i++)
      {
        float xnew = sin(a * y) + c * cos(a * x);
        float ynew = sin(b * x) + d * cos(b * y);
        x = xnew;
        y = ynew;
      }

      // Draw points
      int numPoints = int(pointsPerThread);
      for (int i = 0; i < numPoints; i++)
      {
        float xnew = sin(a * y) + c * cos(a * x);
        float ynew = sin(b * x) + d * cos(b * y);

        x = xnew;
        y = ynew;

        // Map to screen
        float nx = (x + 3.0) / 6.0;
        float ny = (y + 3.0) / 6.0;

        int ix = int(nx * float(size.x));
        int iy = int(ny * float(size.y));

        if (ix >= 0 && ix < size.x && iy >= 0 && iy < size.y)
        {
          vec4 pixelCol = imageLoad(AttractorImage, ivec2(ix, iy));
          pixelCol.rgb += vec3(brightness);
          imageStore(AttractorImage, ivec2(ix, iy), pixelCol);
        }
      }
    }
  }
  else if (PASSINDEX == 2)
  {
    // Final normalization for this pixel
    vec4 finalCol = imageLoad(AttractorImage, coord);
    finalCol.rgb = clamp(finalCol.rgb, 0.0, 1.0);
    finalCol.a = 1.0;
    imageStore(AttractorImage, coord, finalCol);
  }
}
