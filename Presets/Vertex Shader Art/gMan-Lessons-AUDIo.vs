/*{
  "DESCRIPTION": "gMan-Lessons-AUDIo - Just following the lessons\nfrom Youtube.",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/TAT9Ad57HDZwRxXnf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1388,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.10980392156862745,
    0.10980392156862745,
    0.10980392156862745,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1619537509121
    }
  }
}*/

// Lesson at
// https://www.youtube.com/watch?v=4hlKjlIUtIc&list=PLC80qbPkXBmw3IR6JVvh7jyKogIo5Bi-d&index=4

// Every shader needs a main
// number of vertices fixed up there

// Check the help to know which variables are available around

// some code to convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1., 2.0/ 3.0, 1.0/3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

# define PI radians(180.0)

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  // Get x, y coordinates on a grid
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float xoff = 0.;//sin(time + y * 0.2) * .1;
  float yoff = 0.;//sin(time + x * 0.3) * .1;

  // scale to get a fix number across the width
  float u = x / (across - 1.);
  float v = y / (across - 1.);
  // scale it back to [-1, 1]
  float ux = u*2. - 1. + xoff;
  float vy = v*2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  //float snd = texture(sound, vec2(u * .05, v * .25)).r; // normal one history scrolling
  //float snd = texture(sound, vec2(su * .15, sv * .25)).r; // symmetrical
  float snd = texture(sound, vec2(au * .05, av * .25)).r; // circular

  gl_Position = vec4(xy, 0, 1); // x, y, z, (w) (each one from -1 to 1

  // Adjust size of points by time too
  float soff = 0.; //sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd +0.02, 5.) * 25.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float punp = step(0.8, snd);
  float hue = u * .1 + snd* 0.2 + time * .1; //sin(time + v * 20.) * 0.05;
  float sat = mix(0., 1., punp);//-av; // ,ix is like map in processing
  float val = pow(snd + .1, 5.);//sin(time+ v * u * 20.) * .5 + .5; // check replace the "+" by a "*" in the sin

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1); // v_color is specific to vertexshader.com (it's the gl_FragColor) equivalent

}