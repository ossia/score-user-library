/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/RkS9eZ4fjYjak9w78)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 112,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1563439871331
    }
  }
}*/


    #define PI radians(180.)
    #define TAU 6.283185307179586

    float lerp(float a, float b, float amt)
    {
      return a + (b-a)*amt;
    }

    float func(float t)
    {
      return t/pow(t,t);
    }

    void main()
    {
      float ph = vertexId/vertexCount;
      float angle = ph *TAU*20.;
      float w = lerp(.2, 3.0, vertexId/ vertexCount);
      vec2 pos = vec2(
        cos(angle+ ph*5.)* w,
        sin(angle +sin(PI/2.+time*0.1)*5.) *w
      );

      vec2 aspect = vec2(1., resolution.x/resolution.y);
      pos *= pow((mouse.x+1.)/2.,0.2);
      //pos *= (mouse.y+1.)/2.;
      gl_Position = vec4(pos * aspect * 1., 0.,1.);

      vec3 col = vec3(
        0.5,
        sin(ph*PI +time * 0.13),
        sin(ph*PI +time * 0.17)
      );
      col = abs(col);

      float ps = func(ph*6.);
      gl_PointSize = pow(ps,0.4) * 10.;
      v_color = vec4(col, 1.);
    }