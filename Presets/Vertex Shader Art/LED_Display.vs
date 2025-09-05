/*{
  "DESCRIPTION": "LED Display - A tribute to La La Land.\nA music visualization demo.\nInspired by fragment shader http://glslsandbox.com/e#41758.0",
  "CREDIT": "ray7551 (ported from https://www.vertexshaderart.com/art/T3o69kd5wMtWNCj5k)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Effects"
  ],
  "POINT_COUNT": 61000,
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
    "ORIGINAL_VIEWS": 1290,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1501501541819
    }
  }
}*/

/**
 * LED Music Visualizer
 * A tribute to La La Land
 * Try these sound:
 * https://soundcloud.com/matthew-deep-density/another-day-of-sun-justin-hurwitz-deep-density-version
 * https://soundcloud.com/thave-lex/another-day-of-sun-la-la-land-thave-lex-remix
 */
float hash(float n) {
  return fract(sin(n) * 777.1397);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float xCount = ceil(sqrt(vertexCount * resolution.x / resolution.y));
  float gridWidth = resolution.x / xCount;
  float gridHeight = resolution.y / (xCount * resolution.y / resolution.x);

  gl_PointSize = 10.;
  gl_PointSize *= 100. / xCount; // if xCount > 100 then make pointSize smaller

  vec2 p = vec2(
    mod(vertexId, xCount) * gridWidth,
    floor(vertexId / xCount) * gridHeight
  );

  gl_Position = vec4(
    (p / resolution * 2. - vec2(1.)),
    0., 1.
  );
  //v_color = vec4(vec3(1., 1., 1.0), 1.); // for debugging grid

  float tvGlitch = 400.;
  float i = hash(vertexId) / tvGlitch;
  vec4 snd = texture(sound, vec2(0., i));
  //vec4 snd = texture(sound, vec2(0., 0.));
  vec3 s = vec3(snd.a * snd.a, pow(snd.b, 14.), pow(snd.z, 8.));
  float glowFactor = s.x * floor(time / 50.) + 1.;

  // tweak variables below to see what happens
  const float n = 3.0; // flower number
  float petalNum = 3.0 + floor((time + s.x * 140.) / 50.); // petal number of each flower
  float glowing = 0.03 * glowFactor;
  float rotateSpeed = 0.07 + 0.015 * smoothstep(-0.1, 1.0, s.x);
  float scale = 0.9 * (1. + s.y * 1.);
  float variationX = 0.0 - 0.5 * sin(s.x);//0.25;
  float variationY = 0.0 - 0.45 * sin(s.x) - 37. * sin(s.z);//0.25;

  vec2 pos = gl_Position.xy * vec2(max(resolution.x, resolution.y)) / vec2(resolution.yx); // make grid spacing equal in x and y, and fit window size
  float radius = length(pos.xy) + 0.2;
  float t = atan(
    pos.y + variationY,
    pos.x + variationX
  );

  float color = 0.0;
  for (float i = 1.; i <= n; i++) {
    color += glowing / abs(
      color + i / n * scale * sin(
        petalNum * (t + i * time * rotateSpeed)
      )
      - radius
    );
  }

  vec3 debugColor = vec3(smoothstep(-0.1, 1.0, s.x));
  v_color = vec4(
    hsv2rgb(vec3(
      0.6 + sin(s.x * 2.6),// + cos(s.z * 73.),
      0.7 + 0.3 * (time / 120.),
      0.6 + 0.4 * (time / 120.)
    )) * color
    + step(1., length(pos * vec2(resolution.xy) / resolution)) * debugColor,
    1.
  );

}