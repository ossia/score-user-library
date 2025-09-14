/*{
  "DESCRIPTION": "Rain_old",
  "CREDIT": "martinpalko (ported from https://www.vertexshaderart.com/art/BtpY4aK6a7rEquy7n)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 4677,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1509121941112
    }
  }
}*/

// Defines to compile the HLSL code with GLSL
#define float4 vec4
#define float3 vec3
#define float2 vec2
#define float4x4 mat4
#define float3x3 mat3
#define mul(x, y) y * x
#define lerp mix
#define static
#define saturate(x) clamp(x, 0.0, 1.0)

float Rand(float2 seed)
{
    return fract(sin(dot(seed.xy ,float2(12.9898,78.233))) * 43758.5453);
}

struct RainParams
{
    float minSpeed;
 float maxSpeed;
    float groundHeight;
    float fallDistance;
    float2 minBounds;
    float2 maxBounds;
    float2 windDirectionAndStrength;
};

struct Raindrop
{
    float size;
    float3 position;
    float3 velocity;
};

float Wrap(float value, float minimum, float maximum, out float offset)
{
    float maxMinusMin = maximum - minimum;
    float valueMinusMin = value - minimum;
    offset = floor(valueMinusMin / maxMinusMin);
    return minimum + mod(valueMinusMin, maxMinusMin);
}

float Wrap(float value, float minimum, float maximum)
{
    float dummy;
    return Wrap(value, minimum, maximum, dummy);
}

Raindrop GenerateRaindrop(RainParams params, float time, float seed)
{
   float3 boundsSize;
   boundsSize.xy = params.maxBounds - params.minBounds;
   boundsSize.z = params.fallDistance;

   float seed2 = 0.0;

    float3 initialOffset = boundsSize * float3(Rand(float2(seed, seed2++)), Rand(float2(seed, seed2++)), Rand(float2(seed, seed2++)));

    float3 velocity = float3(0.0, 0, -1.0) * lerp(params.minSpeed, params.maxSpeed, Rand(float2(seed, seed2++)));

    velocity.xy += params.windDirectionAndStrength;

    Raindrop drop;
    drop.size = 0.002;
    drop.position = initialOffset + (velocity * time);

    float wrapOffset;
    drop.position.z = Wrap(drop.position.z, params.groundHeight, params.groundHeight + params.fallDistance, wrapOffset);

 drop.position.x += Rand(float2(wrapOffset, 0.0)) * (params.maxBounds.x - params.minBounds.x);
    drop.position.x = Wrap(drop.position.x, params.minBounds.x, params.maxBounds.x);
    drop.position.y += Rand(float2(wrapOffset, 1.0)) * (params.maxBounds.y - params.minBounds.y);
    drop.position.y = Wrap(drop.position.y, params.minBounds.y, params.maxBounds.y);

    drop.velocity = velocity;

    return drop;
}

#define TRIANGLES_PER_DROP 2.0
void RenderRaindrop(Raindrop drop, RainParams params, float triangle, float triVert, out float4 outPos, out float4 outColor)
{
  // Super brute-force. Lets do something nicer later.
  outPos.yz = float2(0.0, 0.0);

  float alpha = 0.4;

  if (triangle == 0.0)
  {
    if (triVert == 0.0)
    {
      outPos.xy = float2(-1.0, 0.0);
    }
    else if (triVert == 1.0)
    {
      outPos.xy = float2(1.0, 0.0);
    }
    else
    {
       outPos.xy = float2(0.0, -1.0);
    }
  }
  else // triange == 1
  {
    if (triVert == 0.0)
    {
      outPos.xy = float2(-1.0, 0.0);
    }
    else if (triVert == 1.0)
    {
      outPos.xy = float2(1.0, 0.0);
    }
    else
    {
      alpha = 0.;
      outPos.xy = float2(0.0, 150.0);
    }
  }

  outPos.xyz *= drop.size;

  outColor = float4(0.8, 0.9, 1.0, alpha);
  outColor.rgb *= alpha;

  // Drop is currently in local space. Translate to world space
  outPos.xyz *= drop.position.y;

  outPos.xyz += drop.position.xzy * drop.position.y;
}

float GetThunderBrightness(float2 uv)
{
  float2 lookupCoord = float2(0.0005, 0.0 + uv.x);
  float sample_ = texture(sound, lookupCoord).r;
  return pow(saturate((sample_ - 0.5) * 2.0), 6.0) * 5.0;

}

#define BACKGROUND_QUADS_X 20.0
#define BACKGROUND_QUADS_Y 20.0
#define TRIANGLES_FOR_BACKGROUND BACKGROUND_QUADS_X * BACKGROUND_QUADS_X * 2.0
void RenderBackground(float triangle, float triVert, out float4 outPos, out float4 outColor)
{
  float quad = floor(triangle / 2.0);
  float2 quadCoord = float2(
    (mod(quad, BACKGROUND_QUADS_X) + 1.0) / BACKGROUND_QUADS_X,
    (floor(quad / BACKGROUND_QUADS_X) + 1.0) / BACKGROUND_QUADS_Y
  );

  float2 quadSize = float2(1.0 / BACKGROUND_QUADS_X, 1.0 / BACKGROUND_QUADS_Y);

  outPos.zw = float2(0.0, 1.0);

  if (floor(mod(triangle, 2.0)) == 0.0)
  {
    if (triVert == 0.0)
      outPos.xy = float2(0.0, 0.0);
    else if (triVert == 1.0)
      outPos.xy = float2(1.0, 0.0);
    else
      outPos.xy = float2(1.0, 1.0);
  }
  else
  {
    if (triVert == 0.0)
      outPos.xy = float2(0.0, 0.0);
    else if (triVert == 1.0)
      outPos.xy = float2(0.0, 1.0);
    else
      outPos.xy = float2(1.0, 1.0);
  }

  float2 uv = outPos.xy * quadSize - quadCoord;
  outPos.xy = uv * 2.0 + 1.0;

  outColor.a = 0.0;
  float thunder = GetThunderBrightness(uv);
  outColor.rgb = float3(thunder, thunder, thunder);

}

void main()
{
  float triangleId = floor(vertexId / 3.0);
  float vertIndex = floor(mod(vertexId, 3.0));

  float backgroundTriangleStart = vertexCount / 3.0 - TRIANGLES_FOR_BACKGROUND;

  if (triangleId >= backgroundTriangleStart)
  {
    RenderBackground(triangleId - backgroundTriangleStart, vertIndex, gl_Position, v_color);
  }
  else
  {
    float dropId = floor(triangleId / TRIANGLES_PER_DROP);

    RainParams params;
    params.minSpeed = 8.1;
    params.maxSpeed = 10.1;
    params.groundHeight = -2.0;
    params.fallDistance = 4.0;
    params.minBounds = float2(-2.0, 0.3);
    params.maxBounds = float2(2.0, 1.0);
    params.windDirectionAndStrength = float2(0.0, 0.0);

    Raindrop drop = GenerateRaindrop(params, time, dropId);

    gl_Position = float4(0.0, 0.0, 0.0, 1.0);
    v_color = float4(1.0, 1.0, 1.0, 1.0);

    RenderRaindrop(drop, params, triangleId, vertIndex, gl_Position, v_color);
  }
}
