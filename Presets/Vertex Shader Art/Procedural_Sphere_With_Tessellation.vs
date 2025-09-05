/*{
  "DESCRIPTION": "Procedural Sphere With Tessellation",
  "CREDIT": "przemyslawzaworski (ported from https://www.vertexshaderart.com/art/Pzbk6qLsSg2d38JRq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 24576,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 203,
    "ORIGINAL_DATE": {
      "$date": 1648065752246
    }
  }
}*/

const mat4 ModelViewProjection = mat4(
 0.974278, 0.000000, 0.000000, 0.000000,
 0.000000, 1.705737, -0.173752, -0.173648,
 0.000000, 0.300767, 0.985398, 0.984807,
 0.000000, 1.301937, 9.427560, 10.021725
);

vec3 Hash(float p)
{
 vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
 p3 += dot(p3, p3.yzx+33.33);
 return fract((p3.xxy+p3.yzz)*p3.zyx);
}

void main()
{
 int tessellationFactor = 64; // vertex count = _TessellationFactor * _TessellationFactor * 6
 int instance = int(floor(vertexId / 6.0));
 float x = sign(mod(20.0, mod(float(vertexId), 6.0) + 2.0));
 float y = sign(mod(18.0, mod(float(vertexId), 6.0) + 2.0));
 float u = (float(instance / tessellationFactor) + x) / float(tessellationFactor);
 float v = (mod(float(instance), float(tessellationFactor)) + y) / float(tessellationFactor);
 float pi = 3.14159265359;
 float radius = 4.0;
 float a = sin(pi * u) * cos(2.0 * pi * v);
 float b = cos(pi * u);
 float c = sin(pi * u) * sin(2.0 * pi * v);
 vec3 position = vec3(a, b, c) * radius;
 gl_Position = ModelViewProjection * vec4(position, 1.0);
 vec3 normalDir = normalize(position);
 vec3 lightDir = normalize(vec3(0, 0, -10));
 float diffusion = max(dot(lightDir, normalDir), 0.0);
 v_color = vec4(Hash(float(instance + 123)), 1.0) * vec4(vec3(diffusion), 1.0);
}