/*{
  "DESCRIPTION": "Making a Grid_sunwoo.lee",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/Qi72eGRatu7XNwXS3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 108,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1652633455368
    }
  }
}*/

// // Name: sunwoo.lee
// // Assignment name: Making a Grid
// // Course name: CS250
// // Term: 2022 Spring

void main()
{
  float down = floor(sqrt(vertexCount));

  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 25.0;//*abs(sin(time));
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 1900.0;

  float gradiant_sin= sin(time*0.5)+1.0*0.5;
  float gradiant_cos= cos(time*0.5)+1.0*0.5;

  v_color = vec4(mix(vec3(gradiant_cos,0.,gradiant_sin),vec3(gradiant_sin,0.,gradiant_cos),vec3(smoothstep( -1.0, 1.0, ux))),1.0);
}