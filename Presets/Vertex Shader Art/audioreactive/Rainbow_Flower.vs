/*{
  "DESCRIPTION": "Rainbow Flower - Pretty Cool, Right?",
  "CREDIT": "lambmeow (ported from https://www.vertexshaderart.com/art/5gKRQuwx63MAdRePc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2439,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 225,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1494699060169
    }
  }
}*/

/* Lambmeow */

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId,across);
  float y = floor(vertexId/across);

  float u = x/(across-1.);
  float v = y/(across- 1.);

  float xoff = sin(time + y *.2);
  float yoff = sin(time +x *.2);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * texture(sound,vec2(u,v)).r;

  gl_Position = vec4(xy,0,1);

  float snd = texture(sound, vec2(u,v/4.)).r;

  float soff = sin(time +x * y ) * .5 ;

  gl_PointSize = 15. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x/ 600.;
  float h = (u +cos(time * -v))* sin(time * .3) + snd;
  float s = 1.;
  float val = v+.8;
  v_color = vec4(hsv2rgb(vec3(h,s,val)),1);
}