/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Example geometry effect",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Utility" ],
  "INPUTS": [
    {
      "NAME": "intensity",
      "TYPE": "float",
      "DEFAULT": 1.,
      "MIN": 0.,
      "MAX": 0.1
    }
  ]
}*/

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    position.xyz += this_filter.intensity * 10. * sin(TIME * 0.001 * gl_VertexIndex);
}
