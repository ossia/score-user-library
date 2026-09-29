/*{
  "DESCRIPTION": "Lens undistortion (Brown-Conrady radial model). Removes barrel/pincushion distortion given normalised intrinsics (fx, fy, cx, cy in [0,1] of the image) and radial coefficients k1, k2. For each output pixel it back-projects to normalised camera coordinates using the intrinsics, applies the FORWARD distortion model to find where that ideal ray actually landed in the distorted input, and samples there. With k1 = k2 = 0 the distortion factor is exactly 1, so the source uv equals the destination uv and the shader is a passthrough. Defaults (fx=fy=1, cx=cy=0.5, k=0) are identity. cv.jit.undistort equivalent.",
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "CATEGORIES": ["Computer Vision", "Image Processing"],
  "INPUTS": [
    { "NAME": "inputImage", "TYPE": "image" },
    { "NAME": "fx", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.1, "MAX": 4.0 },
    { "NAME": "fy", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.1, "MAX": 4.0 },
    { "NAME": "cx", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "cy", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
    { "NAME": "k1", "TYPE": "float", "DEFAULT": 0.0, "MIN": -1.0, "MAX": 1.0 },
    { "NAME": "k2", "TYPE": "float", "DEFAULT": 0.0, "MIN": -1.0, "MAX": 1.0 }
  ]
}*/

void main()
{
  vec2 uv = isf_FragNormCoord;

  // Back-project the (undistorted) output pixel to normalised camera coordinates.
  // Guard fx/fy away from zero.
  float ifx = 1.0 / max(fx, 1.0e-4);
  float ify = 1.0 / max(fy, 1.0e-4);
  vec2 xn = vec2((uv.x - cx) * ifx, (uv.y - cy) * ify);

  // Forward Brown-Conrady radial distortion: where did this ideal ray actually
  // land on the distorted sensor? With k1 = k2 = 0, radial == 1.0 -> xd == xn.
  float r2 = dot(xn, xn);
  float radial = 1.0 + k1 * r2 + k2 * r2 * r2;
  vec2 xd = xn * radial;

  // Re-project to normalised image coordinates with the same intrinsics.
  vec2 src = vec2(xd.x * fx + cx, xd.y * fy + cy);

  // (Passthrough check: k1 = k2 = 0 => radial = 1 => xd = xn => src = uv exactly.)

  if(src.x < 0.0 || src.x > 1.0 || src.y < 0.0 || src.y > 1.0)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  gl_FragColor = IMG_NORM_PIXEL(inputImage, src);
}
