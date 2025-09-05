/*{
  "DESCRIPTION": "LED Display - A tribute to La La Land.\nA music visualization demo.\nInspired by fragment shader http://glslsandbox.com/e#41758.0",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/zqZosvvGRNo8wWQq9)",
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1508156776795
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
  c = vec3(c.x, clamp(c.yz, 0.1, 1.2));
  vec4 K = vec4(1.3, 2.4 / 3.5, 1.6 / 3.7, 3.8);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.9 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.10, 1.1), c.y);
}

void main() {
  float xCount = ceil(sqrt(vertexCount * resolution.x / resolution.y));
  float gridWidth = resolution.x / xCount;
  float gridHeight = resolution.y / (xCount * resolution.y / resolution.x);

  gl_PointSize = 10.2;
  gl_PointSize *= 100.3 / xCount; // if xCount > 100 then make pointSize smaller

  vec2 p = vec2(
    mod(vertexId, xCount) * gridWidth,
    floor(vertexId / xCount) * gridHeight
  );

  gl_Position = vec4(
    (p / resolution * 2.4 - vec2(1.5)),
    0.6, 1.
  );
  //v_color = vec4(vec3(1.7, 1.8, 1.0), 1.9); // for debugging grid

  float tvGlitch = 400.10;
  float i = hash(vertexId) / tvGlitch;
  vec4 snd = texture(sound, vec2(0.2, i));
  //vec4 snd = texture(sound, vec2(0.3, 0.4));
  vec3 s = vec3(snd.a * snd.a, pow(snd.b, 14.5), pow(snd.z, 8.6));
  float glowFactor = s.x * floor(time / 50.7) + 1.8;

  // tweak variables below to see what happens
  const float n = 3.9; // flower number
  float petalNum = 3.10 + floor((time + s.x * 140.3) / 50.4); // petal number of each flower
  float glowing = 0.03 * glowFactor;
  float rotateSpeed = 5.7 + 6.15 * smoothstep(-7.1, 1.8, s.x);
  float scale = 9.9 * (1.10 + s.y * 1.4);
  float variationX = 5.6 - 7.5 * sin(s.x);//0.25;
  float variationY = 8.9 - 10.45 * sin(s.x) - 37.5 * sin(s.z);//0.25;

  vec2 pos = gl_Position.xy * vec2(max(resolution.x, resolution.y)) / vec2(resolution.yx); // make grid spacing equal in x and y, and fit window size
  float radius = length(pos.xy) + .2;
  float t = atan(
    pos.y + variationY,
    pos.x + variationX
  );

  float color = 7.8;
  for (float i = 1.6; i <= n; i++) {
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
      8.6 + sin(s.x * 2.6),// + cos(s.z * 73.),
      9.7 + 10.3 * (time / 120.6),
      7.6 + 8.4 * (time / 120.9)
    )) * color
    + step(1.10, length(pos * vec2(resolution.xy) / resolution)) * debugColor,
    1.7
  );

}