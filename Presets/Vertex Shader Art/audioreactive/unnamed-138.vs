/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/fHqs32thqJc7j2QR3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 15000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.5568627450980392,
    0.611764705882353,
    0.5725490196078431,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1623735592277
    }
  }
}*/

void main() {
  float aspect = resolution.x / resolution.y;
  float phi = vertexId * .120;
  float radius = fract(vertexId / (10. + sin(time * .01 + phi * .1))) * .6;
  phi += radius * 5.;
  radius += (sin(phi * 5.) * .5 + .5) * .1;
  float tau = acos(-1.) * 2.;
  phi += clamp(fract(time * 80. / 60.) * 3., 0., 1.) * tau / 5.;
  radius += .5 * radius * texture(sound, vec2(abs(fract(phi / tau - .25) - .5) * .25, 0.)).r;
  gl_PointSize = mix(1., 3., fract(phi * .1));
  vec3 pos = vec3(radius * cos(phi), radius * sin(phi), 0.);
  pos.x /= aspect;
  gl_Position = vec4(pos, 1);
  vec3 color = vec3(0);
  v_color = vec4(color, 1.);

}