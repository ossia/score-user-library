/*{
  "DESCRIPTION": "Cube",
  "CREDIT": "salvatore (ported from https://www.vertexshaderart.com/art/MLdXbo7E4ENYKNQqj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry"
  ],
  "POINT_COUNT": 1,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1714205641861
    }
  }
}*/


// Must be called with idx > 0 and idx < 8
vec4 GetCubeVertex(int idx)
{
  // Half the cube side
  float h_size = 0.5;

  // idx 1,3,5,7 have negative x
  float x = h_size + mod(float(idx), 2.) * -2. * h_size;
  // idx 3,4,6,7 have negative y
  float y = h_size + mod(float(idx / 2), 2.) * -2. * h_size;
  // idx 4,5,6,7 have negative z
  float z = h_size + mod(float(idx / 4), 2.) * -2. * h_size;

  return vec4(x, y, z, 1.);
}

void main()
{
  vec4 v = GetCubeVertex(int(vertexId));
  gl_Position = v;
  gl_PointSize = 10.;
  v_color = vec4(0,0,0, 1);
}