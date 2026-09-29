/*{
  "DESCRIPTION": "Warp the image by a 3x3 homography (perspective transform). The matrix is given as three rows (row0, row1, row2); the default is the identity transform. For each output pixel the inverse mapping src = H * dest is applied in homogeneous coordinates, then the input is sampled bilinearly. cv.jit.perspective equivalent.",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "row0", "TYPE": "point3D", "DEFAULT": [1.0, 0.0, 0.0] },
    { "NAME": "row1", "TYPE": "point3D", "DEFAULT": [0.0, 1.0, 0.0] },
    { "NAME": "row2", "TYPE": "point3D", "DEFAULT": [0.0, 0.0, 1.0] }
  ]
}*/

void main()
{
  vec2 uv = isf_FragNormCoord;

  // Homography rows -> 3x3 matrix (row-major).
  // Inverse mapping: homogeneous source = H * [u, v, 1].
  vec3 dst = vec3(uv, 1.0);
  vec3 srcH = vec3(
    dot(row0, dst),
    dot(row1, dst),
    dot(row2, dst));

  // Perspective divide; guard against w == 0.
  if(abs(srcH.z) < 1.0e-8)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec2 src = srcH.xy / srcH.z;

  // Outside the source image -> black.
  if(src.x < 0.0 || src.x > 1.0 || src.y < 0.0 || src.y > 1.0)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  gl_FragColor = IMG_NORM_PIXEL(inputImage, src);
}
