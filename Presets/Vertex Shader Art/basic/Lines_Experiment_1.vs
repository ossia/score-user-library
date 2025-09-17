/*{
  "DESCRIPTION": "Lines Experiment 1",
  "CREDIT": "aiekick (ported from https://www.vertexshaderart.com/art/uGJhdfKrAj8tkovpA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 157,
    "ORIGINAL_DATE": {
      "$date": 1450381248386
    }
  }
}*/

// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void main()
{
 float astep = 3.14159 * 2.0 / 70.;

 float t = time * .3;

 float a = astep * float(vertexId) * t;

 vec2 d = a * vec2(cos(a), sin(a));

 d /= 100.;

   d.x *= resolution.y/resolution.x;

 gl_Position=vec4(d,0,1);

 v_color=vec4(1,1,1,1);
}