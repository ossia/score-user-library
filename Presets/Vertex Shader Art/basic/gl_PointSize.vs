/*{
  "DESCRIPTION": "gl_PointSize",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Qdhn9CoweLkKbkKLT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 15,
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
    "ORIGINAL_VIEWS": 21,
    "ORIGINAL_DATE": {
      "$date": 1548924251448
    }
  }
}*/

// vertexId is provided by this site.
// it goes from 0 to vertexCount - 1
//
// vertexCount is provided vby this site and is set above with the silder
// it is also the value passed to `gl.drawArrays(primitive, offset, vertexCount);
//
// v_color is provided by this site. It is the output color the fragment shader will
// use to set the color

void main() {
 float u = vertexId / (vertexCount - 1.0); // get a value that goes from 0 ot 1
 float x = u * 2.0 - 1.0; // convert to a value that goes from -1 to 1
 gl_Position = vec4(x, 0, 0, 1);
 gl_PointSize = vertexId * 5.;
 v_color = vec4(1);
}