/*{
  "DESCRIPTION": "poo-brain <3 dub",
  "CREDIT": "richel (ported from https://www.vertexshaderart.com/art/MpkYwsT75rAGCYNQb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3894,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0196078431372549,
    0,
    0.058823529411764705,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 24,
    "ORIGINAL_DATE": {
      "$date": 1460402353722
    }
  }
}*/

float map(float s, float a1, float a2, float b1, float b2)
{
    return b1 + (s-a1)*(b2-b1)/(a2-a1);
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
  vec2 coords;
   coords.x = mod(vertexId, 30.0);
   coords.y = floor(vertexId / 30.0);

  //flag
  if(vertexId < 600.0)
  {
    float u = 1.0 / 30.0 * coords.x;
   float v = 1.0 / 20.0 * coords.y;

   float historyX = abs(map(u, 0.0, 1.0, -.5, 1.0) * .7);
   float historyV = (v *coords.y + 0.5) / IMG_SIZE(sound).y;

   float snd = pow(texture(sound, vec2(historyX, historyV)).r, 1.6);

  float sinDingX = sin(time + coords.x * 0.2) * 0.01;
    float posX = -0.35 + ((0.7 / 30.0) * coords.x);
   posX += sinDingX;

   float sinDingY = sin(time + coords.x * 0.2) * 0.1;
   float posY = -0.35 + (.7 / 20.0) * coords.y * (1.0 + sinDingY * 1.4);
   posY += sinDingY;

   float posZ = 0.8;

   gl_Position = vec4(posX, posY, posZ, 1);

   if(coords.x > 8. && coords.x < 12. ||
     coords.y > 8. && coords.y < 12. )
   {
     v_color = vec4(1.0, 1.0, 1.0, 1);
   }
   else
   {
     v_color = vec4(1.0, 0.0, 0.0, 1);
   }

   v_color.rgb *= map(sinDingX, -0.01, 0.01, 0.3, 1.0);

   gl_PointSize = snd * 20.0;
  }
  // starfield
  else if(vertexId < 800.0)
  {
    float speed = 0.5;

    vec2 startPos = vec2(rand(vec2(vertexId + 12345., vertexId + 4312.)), rand(vec2(vertexId, vertexId)));

    float posX = -1.0 + startPos.x * 2.;
    posX *= 0.1;
    if(posX > 0.)
    {
       posX += startPos.x * time * speed;
       posX = mod(posX, 1.0);
    }
    else
    {
      posX -= startPos.x * time;
      posX = mod(posX, -1.0);
    }

    float posY = -1.0 + startPos.y * 2.;
    posY *= 0.1;
    if(posY > 0.)
    {
       posY += startPos.y * time * speed;
       posY = mod(posY, 1.0);
    }
    else
    {
      posY -= startPos.y * time;
      posY = mod(posY, -1.0);
    }

    float posZ = .8;

    gl_Position = vec4(posX, posY, posZ, 1.0);

    float d = sqrt( gl_Position.x * gl_Position.x + gl_Position.y * gl_Position.y);

    d = map(d, 0.0, 1.0, 0.0, 2.0);
    if(d < 1.0)
    {
      posZ = 1.0;
    }
    else
    {
      posZ = 0.8;
    }

    gl_Position = vec4(posX, posY, posZ, 1.0);
    gl_PointSize = pow(d, 2.0);

    v_color = vec4(1.0, 1.0, 1.0, 1.0);
  }
}