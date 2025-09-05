/*{
  "DESCRIPTION": "rotating sphere",
  "CREDIT": "ian (ported from https://www.vertexshaderart.com/art/HXy6XHHyptoZ9ENeS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3600,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.1803921568627451,
    0.1803921568627451,
    0.1803921568627451,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1552127750070
    }
  }
}*/

#define POINTS_PER_HALF_CIRCLE 60.0
#define DELTA_ALPHA 20.0
#define DELTA_GAMMA 20.0

#define ALPHA_ZERO 45.0
#define BETA_ZERO 0.0
#define GAMMA_ZERO -10.0

void main() {
  float theta = radians(floor(vertexId/ POINTS_PER_HALF_CIRCLE)*(360.0/POINTS_PER_HALF_CIRCLE) ) ;
  float phi = radians(mod(vertexId, POINTS_PER_HALF_CIRCLE)*(180.0/POINTS_PER_HALF_CIRCLE));

  vec3 xyz = vec3(
    sin(phi)*sin(theta),
    cos(phi),
    sin(phi)*cos(theta)
  )*0.25;

  float alpha = radians(sin(time)*DELTA_ALPHA) + ALPHA_ZERO;
  float beta = BETA_ZERO;
  float gamma = radians(cos(time)*DELTA_ALPHA) + GAMMA_ZERO;

  mat3 rotationX = mat3(
   vec3(1.0, 0.0, 0.0),
    vec3(0.0, cos(alpha), sin(alpha)),
    vec3(0.0, -sin(alpha), cos(alpha))
  );
  mat3 rotationY = mat3(
   vec3(cos(beta), 0.0, -sin(beta)),
    vec3(0.0, 1.0, 0.0),
    vec3(sin(beta), 0.0, cos(beta))
  );
  mat3 rotationZ = mat3(
   vec3(cos(gamma), sin(gamma), 0.0),
    vec3(-sin(gamma), cos(gamma), 0.0),
    vec3(0.0, 0.0, 1.0)
  );

  gl_Position = vec4(rotationX*rotationY*rotationZ*xyz, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}