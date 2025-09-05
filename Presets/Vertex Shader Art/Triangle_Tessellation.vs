/*{
  "DESCRIPTION": "Triangle Tessellation",
  "CREDIT": "przemyslawzaworski (ported from https://www.vertexshaderart.com/art/kmHZWuJ5wjmz7RQzS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3072,
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
    "ORIGINAL_VIEWS": 311,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1629553546616
    }
  }
}*/

// In absence of bitwise operators in WebGL 1.0:
// https://gist.github.com/EliCDavis/f35a9e4afb8e1c9ae94cce8f3c2c9b9a
int AND(int n1, int n2)
{
 float v1 = float(n1);
 float v2 = float(n2);
 int byteVal = 1;
 int result = 0;
 for(int i = 0; i < 32; i++)
 {
  bool keepGoing = v1 > 0.0 || v2 > 0.0;
  if(keepGoing)
  {
   bool addOn = mod(v1, 2.0) > 0.0 && mod(v2, 2.0) > 0.0;
   if(addOn) result += byteVal;
   v1 = floor(v1 / 2.0);
   v2 = floor(v2 / 2.0);
   byteVal *= 2;
  }
  else
  {
   return result;
  }
 }
 return result;
}

vec3 hash(vec2 p)
{
 vec2 a0 = fract(p*3.14159265359*(1./1024.))*1024.;
 vec2 a1 = fract(a0*a0*(1./1739.))*1739.;
 vec2 a2 = a1.yx + fract(a1*a1*(1./1739.))*1739.;
 vec2 a3 = a2.yx + fract(a2*a2*(1./1739.))*1739.;
 return fract((a2.xyx + a3.xxy + a1.xyy)*(1./1739.));
}

// GPU PRO 3, Advanced Rendering Techniques, A K Peters/CRC Press 2012
// Chapter 1 - Vertex shader tessellation, Holger Gruen
void main()
{

 int id = int(vertexId);
 int tessellationFactor = int(max(floor((sin(time*0.5)*0.5+0.5)*32.),2.0));
 if (id > (tessellationFactor * tessellationFactor * 3)) return;
 vec3 p1 = vec3( 0.00, 0.75, 0.00);
 vec3 p2 = vec3( 0.75, -0.75, 0.00);
 vec3 p3 = vec3(-0.75, -0.75, 0.00);
 int subtriangles = (tessellationFactor * tessellationFactor);
 float triangleID = mod(float( id / 3 ), float(subtriangles));
 float row = floor (sqrt( triangleID ));
 int column = int(triangleID - ( row * row ));
 float incuv = 1.0 / float(tessellationFactor);
 float u = (1.0 + row) / float(tessellationFactor);
 float v = incuv * floor (float(column) * 0.5);
 u -= v;
 float w = 1.0 - u - v;
 int vID = int(float(id / 3 / subtriangles) * 3. + mod(float(id), 3.));
 int remainder = int(mod(float(vID), 3.0));
 if (remainder == 0)
 {
  if (AND(column, 1) != 0)
  {
   v += incuv, u -= incuv;
  }
 }
 else if (remainder == 1)
 {
  if (AND(column, 1) == 0)
  {
   v += incuv, u -= incuv;
  }
  else
  {
   v += incuv, u -= incuv;
   w += incuv, u -= incuv;
  }
 }
 else if (remainder == 2)
 {
  if (AND(column, 1) == 0)
  {
   u -= incuv, w += incuv;
  }
  else
  {
   w += incuv, u -= incuv;
  }
 }
 gl_Position = vec4(u * p1 + v * p2 + w * p3, 1.0);
 v_color = vec4(hash(vec2(triangleID , triangleID + 19999.)), 1);
}