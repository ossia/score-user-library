/*{
  "DESCRIPTION": "0",
  "CREDIT": "\u5c71\u3093 (ported from https://www.vertexshaderart.com/art/AnFAYAbcbpuErBvBW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2416,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1669379722946
    }
  }
}*/

#define ZOOM (1.1)
#define SCALE (1.0/(vertexCount))
#define SIDE (sqrt(vertexCount))
#define TAU (6.283185307179586476925286766559)
#define SPEED (10.)
#define AMP (sqrt(SIDE)*0.002)
void main()
{
  float x = -1.1 + ZOOM * 2. * floor(fract(vertexId/SIDE) * SIDE + 0.5) / SIDE;
  float y = -1.1 + ZOOM * 2. * floor(vertexId / SIDE) / SIDE;

  x += AMP * sin(SPEED * time + x * TAU);
  y -= AMP * cos(SPEED * time + y * TAU);

  gl_PointSize = 2.0;
  gl_Position = vec4(x,y,0.0,1.0);
  v_color = vec4(1.0,1.0,1.0,1.0);
}

/*
vertexId : float : number of the vertex 0, 1, 2
vertexCount : float : total number of vertices
resolution : vec2 : resolution of the art
mouse : vec2 : mouse position normalized (-1 to 1)
touch : sampler2D : touch history 32x240 (4sec @60fps)
        : : x = x, y = y, z = pressure, w = time
        : : column 0 is mouse or first finger.
        : : column 1 is second finger ...
time : float : time in seconds
volume : sampler2D : volume for music 1x240 alpha only
sound : sampler2D : data from the music Nx240, alpha only
        : : 240 rows of history (4secs @60fps)
floatSound : sampler2D : data from the music Nx240, alpha only
        : : 240 rows of history (4secs @60fps)
        : : see spec for difference between
        : : getFloatFrequencyData and
        : : getByteFrenquencyData.
IMG_SIZE(sound) : vec2 : resolution of sound
background : vec4 : background color

gl_Position : vec4 : standard GLSL vertex shader output
v_color : vec4 : color to output from fragment shader
*/