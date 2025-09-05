/*{
  "DESCRIPTION": "sound cone",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/FqSZrJ7rAfB3savC5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 200,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 26,
    "ORIGINAL_DATE": {
      "$date": 1661900006833
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
        oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float vert_i = mod(vertexId, 3.0);
  float tri_i = floor(vertexId / 3.0);

  vec4 snd = texture(sound, vec2(mod((vert_i + tri_i) / vertexCount, .5), 1));

  float phi = acos(0.0) / 10.0;
  float l = pow((snd.x + .6), 3.0);
  float r = l * cos(phi);
  float offset = -0.2;
  float z = l * sin(phi) + offset;
  float theta = (vert_i + tri_i) / 10.0;
  float x = r * cos(theta);
  float y = r * sin(theta);

  if(vert_i == 0.0) {
    x = 0.0;
    y = 0.0;
    z = offset;
  }

  vec2 circle = vec2(x, y) * 100.0 + 100.0;// * 100.0;
  circle /= resolution;
  //circlepos.x += 200.0;
  vec3 cone = vec3(circle, z) * rotationMatrix(normalize(vec3(1,1,0)), time);

  gl_Position = vec4(cone, 1);

  float hue = vertexId / vertexCount;
  float sat = 1.0;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}