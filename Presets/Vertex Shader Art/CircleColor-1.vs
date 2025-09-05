/*{
  "DESCRIPTION": "CircleColor - Pretty Cool, Right?",
  "CREDIT": "lambmeow (ported from https://www.vertexshaderart.com/art/tnmTYzZQNchp9ECC2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 74675,
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
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1494708779147
    }
  }
}*/

/* Lambmeow */

#define PI radians(180.)

vec2 GetCirclePoint(float id, float NumCircleSegments) {

   float ux= floor(id/6.) + mod(id,2.);
  float vy = mod(floor(id/2.)+ floor(id/3.), 2.);

  float angle =ux/NumCircleSegments * PI * 2. ;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy +1.;

  float x = c * radius ;
  float y = s * radius;

  return vec2(x,y);

}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(){
  float numCircleSeg = 20.;
  vec2 cir = GetCirclePoint(vertexId,numCircleSeg);
  float numPointsPerCircle = numCircleSeg * 6.;
  float circleId = floor(vertexId/numPointsPerCircle);
  float numCircles = floor(vertexCount/numPointsPerCircle);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles/down);

  float x = mod(circleId,across);
  float y = floor(circleId/across);

  float u = x/(across-1.);
  float v = y/(across- 1.);

  float xoff = sin(time + y *.2);
  float yoff = sin(time +x *.2);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float aspect = resolution.x/resolution.y;
   float snd = texture(sound, vec2(u,v/4.)).r;
  float scale = pow(snd +.2,.5);
  float soff = sin(time +x * y ) * .5 ;

  vec2 xy = cir * .3* vec2(ux,vy) * texture(sound,vec2(u,v)).r;

  gl_Position = vec4(xy,0,1) * vec4(1,aspect,1,1);

  gl_PointSize = 15. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x/ 600.;
  float h = (u +cos(time * -v))* sin(time * .3) + snd;
  float s = 1.;
  float val = v+.8;
  v_color = vec4(hsv2rgb(vec3(h,s,val)),1);
}