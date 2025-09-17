/*{
  "DESCRIPTION": "First Shader",
  "CREDIT": "salvatore (ported from https://www.vertexshaderart.com/art/P5mpP2Tb9XkwhuTK7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 961,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1714149284457
    }
  }
}*/


void main()
{

   // Use the floor to get an integer. Due vertexId is integer, the vertices x coord will be aligned.
 float RowLen = floor(sqrt(vertexCount));

    // [x, y] position
   float x = mod(vertexId, RowLen);
   float y = floor(vertexId / RowLen);

    // Eg. if RowLen is 10., x goes to 0 to 9, due the mod operation
    // and y too due to the division and floor, this cause the last x and y points to be drawn before the screen border
    // and the grid seems not uniform.
    // So scale the coordinate dividing them by 9, (RowLen-1), instead of dividing by 10,
    // to optain the starting and the end points on the screen border.

    // [u,v] = [0,1]x[0,1]
    float u = x / (RowLen - 1.);
    float v = y / (RowLen - 1.);

    // Add animation
   float xoff = 0.;//sin(time + y * 0.2) * 0.1;
   float yoff = 0.;//sin(time + x * 0.2) * 0.2;

    // [U,V] = [-1,1]x[-1,1]
   float U = 2. * u - 1. + xoff;
   float V = 2. * v - 1. + yoff;

    // Scale coordinates
    vec2 UV = vec2(U,V) * 0.6;

 gl_Position = vec4(UV, 0, 1);

   float PointSizeScale = sin(time + x * y * 0.02) * 5.;

   // More point on screen -> smaller point size
   gl_PointSize = 15. + PointSizeScale;
   gl_PointSize *= 5. / RowLen;
   gl_PointSize *= resolution.x / 600.;

    // Change color
   v_color = vec4(1,0,0, 1);

}