/*{
  "DESCRIPTION": "Terrain Gen Testing Area - A setup for fooling around with visualizing how mixing noise creates various terrain shapes",
  "CREDIT": "dreadkyller (ported from https://www.vertexshaderart.com/art/8oJh9QtFGgJksSFFk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 23571,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 461,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1522036045755
    }
  }
}*/

// Some code originated from here: https://www.vertexshaderart.com/art/TGGLggjxQgLPEFHWx

// Calculates the size of the grid based on total number of points
float SIZE = floor(sqrt(vertexCount));

// The actual points are placed in a 16x16 area, divided by the size gets the distance
// between points
float SPACING = 16.0 / SIZE;

// How much the mouse changes the position, mouse influence
float DIST = 16.0;

// Detail scale (zoom out)
float SCALE = 1.0;

// Height scale, ranges from 0.001 to 1.001. The 0.001 additional is to ensure it stays
// Positive, so that the calculation of the colors still works.
float H_SCALE = 0.501 + sin(time / 1.0) / 2.0;

// Values used by noise to offset the terrain for interactivity
float x_offset = mouse.x * DIST;
float y_offset = mouse.y * DIST;

// How fast the camera orbits the area
float ROTATE_SPEED = 0.1;

// This value determines the fullness of the display. 1.0 is default
// Too high and the dots cause interference with each other
// Too low and it can be hard to see the shape
// The dots get smaller as they get farther from the camera
float DOT_SIZE = 1.0;

// These colors are used for the color display, and are mixed in main based on height
vec4 SNOW_COLOUR = vec4(1.0, 1.0, 1.0, 1);
vec4 STONE_COLOUR = vec4(0.4, 0.4, 0.4, 1);
vec4 DIRT_COLOUR = vec4(0.4, 0.2, 0.1, 1);
vec4 GRASS_COLOUR = vec4(0.1, 0.4, 0.1, 1);

// Rotates a point around the global Y axis
// This is used to rotate the grid
vec3 rotateY( vec3 p, float a )
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}
// Rotates a point around the global X axis
// This is used to tile the camera downwards to look at terrain from slightly above
vec3 rotateX( vec3 p, float a )
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.y = ca*p.y + sa*p.z;
    r.x = p.x;
    r.z = -sa*p.y + ca*p.z;
    return r;
}
// Hash unction returns a pseudo-random value for a given value
float hash( in float n )
{
 return fract(sin(n)*43758.5453);
}
// blends the hash of of 4 points around the given vector smoothly using
// a cubic hermite interpolation
float noise(in vec2 x)
{
 vec2 p = floor(x);
 vec2 f = fract(x);

 f = f*f*(3.0-2.0*f);
 float n = p.x + p.y*57.0;

 float res = mix(mix( hash(n+ 0.0), hash(n+ 1.0),f.x),
     mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
 return res;
}

// Scaling factor used only in the noise function
float feature_scale = 2.0;

// Fractal Brownian Motion

float fbm(in vec2 p, in float size) {
  // How much the influence of each iteration is decreased
  const float lucanarity = 2.0;
  // How much the scale of each iteration is increased
  const float detail = 2.0;

  p = p * feature_scale;
  float h = noise(p);

  float influence = 1.0;

  for (int i = 0; i < 14; i++) {
    p = p * size;
   h += noise(p) * influence;
    size *= 2.0;
    influence /= lucanarity;
  }
  return h;
}

// The code that given a position, gives a height, design the terrain here
float heightAt(in vec2 po) {
  po.x = (po.x + x_offset) * SCALE;
  po.y = (po.y + y_offset) * SCALE;
  return (fbm(po, 3.0) * 3.0) * pow(fbm(po, 0.2),3.0) * (0.03 * H_SCALE);
}

// returns a value 0.0 to 1.0 representing how far between min and max the value is
float factor(float min, float max, float value) {
  float val = (value - min) / (max - min);
  if (val > 1.0) return 1.0;
  if (val < 0.0) return 0.0;
  return val;
}

// Takes a point ID and converts it into coordinates
vec3 pointOf(float id) {
  float x = mod(id, SIZE);
  float y = floor(id / SIZE);

  return vec3((-SIZE/2.0 + x) * SPACING, heightAt( vec2( x, y ) / SIZE * 4.0), (-SIZE/2.0 + y) * SPACING );
}

// Entry point of shader
void main() {
  // Get the point position, x, y and z, with y being the height
  vec3 p = pointOf(vertexId);

  // Based on the height (before rotation) determine colors
  vec4 ground_colour = mix(DIRT_COLOUR , GRASS_COLOUR, factor(0.2, 0.0, p.y / H_SCALE));

  vec4 top_colour = mix(STONE_COLOUR, SNOW_COLOUR , factor(1.2, 2.0, p.y / H_SCALE));

  vec4 colour = mix(ground_colour, top_colour , factor(0.2, 0.3, p.y / H_SCALE));

  // Rotate the point around the global Y axis
  p = rotateY(p, time * ROTATE_SPEED);
  // Move the point down
  p.z += 16.0;
  // rotate the point up on the global X axis to simulare the camera looking downwards
  p = rotateX(p, 0.8);

  // Set point size based on spacing and the distance (p.z) from the camera
  gl_PointSize = SPACING * (2048.0 * DOT_SIZE) / (pow(p.z,2.0));

  // Set the position of the point
  gl_Position = vec4(p.x, p.y - 9.0, 1.0/p.z, p.z);

  // Set the color of the point
  v_color = colour;
}