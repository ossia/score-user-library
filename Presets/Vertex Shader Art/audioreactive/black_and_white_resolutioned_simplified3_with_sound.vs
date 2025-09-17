/*{
  "DESCRIPTION": "black and white resolutioned simplified3 with sound",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/PjY2sWZMomTjpuym6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 25,
    "ORIGINAL_DATE": {
      "$date": 1516021399177
    }
  }
}*/



void main ()
{
   float finalDesiredPointSize = 3.;
   float maxFinalSquareSideSize = floor(sqrt(vertexCount));
   float finalMaxVertexCount = maxFinalSquareSideSize*maxFinalSquareSideSize;

  //first the number of elements in a line
  float across = floor(maxFinalSquareSideSize *resolution.x/resolution.y);
  finalDesiredPointSize = resolution.x/across;
  //we want to keep the resolution >> across/down must be the same as resolution.x/resolution.y
  //across = across*resolution.x/resolution.y;

  //then the number of possible lines with the given vertexCount
  float down = floor(finalMaxVertexCount / across);

  //we can now calculate the final number of elements
  float finalVertexCount = across*down;

  //and the consequent finalVertexId
  float finalVertexId = mod(vertexId,finalVertexCount);

  //Now we calculate the position of the elements based on their finalVertexId
  float x = mod(finalVertexId, across);
  float y = floor(finalVertexId / across);

  float u = (x /across);
  float v = (y /down);

  float u0 = (u * (across*finalDesiredPointSize/resolution.x));
  float v0 = (v * (across*finalDesiredPointSize/resolution.x ));

  float ux = u0 - 0.5*(across*finalDesiredPointSize/resolution.x);
  float vy = v0- 0.5*(across*finalDesiredPointSize/resolution.x);;

  float udnd = u;
  if(u>0.5)
    udnd = 1.-u;

  float snd = texture(sound, vec2(0., udnd)).r;

    //apply fragment logic

 vec2 position = vec2(u,v);

 position.x = abs(position.x - 0.5);

    if(v>0.5)
      position.y = (1. -position.y);

 float j = 1.0;
 j += position.y + position.x/position.y;
 //j *= 1.;
 j = mod(j + time, 1.0);

 float i = mod( position.x * 1. + 1.*cos(time/12.), sin(time/12.0) + 2.0);

    i = mod( sin(position.y * (7.+snd*40.))*sin(position.x * 7.) * j, i / j);

 i *= 5.;

 //i = mod(i - time/2.0 - j, colorCount);

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = finalDesiredPointSize;

  v_color = vec4( vec3(mod(floor(i),2.)), 1.0 );

}