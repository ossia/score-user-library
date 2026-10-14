/*{
  "DESCRIPTION": "Triplanar projection: take a 2D image and stamp it onto the three cardinal planes by projecting along X, Y, Z. Combine with axis-aligned weights derived from |pc|. The volume stores the image premultiplied (colour times alpha), like every volume in this catalogue, so the three projections blend without dark fringes and transparent pixels stay empty.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "PROJECTION"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "texture",
      "LABEL": "2D source"
    },
    {
      "NAME": "sharpness",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Blend sharpness"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volume",
      "TYPE": "image",
      "ACCESS": "write_only",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64"
    }
  ],
  "PASSES": [
    {
      "LOCAL_SIZE": [
        4,
        4,
        4
      ],
      "EXECUTION_MODEL": {
        "TYPE": "3D_IMAGE",
        "TARGET": "volume"
      }
    }
  ]
}*/

// The 2D input, addressed with a bottom-left origin like isf_FragNormCoord.
// In a compute shader IMG_NORM_PIXEL is top-down on every backend (row 0 is
// the top of the picture), and the viewers draw volume y upwards, so flip v
// to keep the image upright in the volume. The texel is read premultiplied,
// the convention of every volume in this catalogue.
vec4 img2D(vec2 uv) { return IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, vec2(uv.x, 1.0 - uv.y)); }


void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    // Triplanar weights from normalized position (proxy for a normal)
    vec3 n = normalize(abs(pc) + 1e-5);
    vec3 w = pow(n, vec3(sharpness));
    w /= (w.x + w.y + w.z);
    vec4 sx = img2D(p.yz);
    vec4 sy = img2D(p.zx);
    vec4 sz = img2D(p.xy);
    vec4 c = sx*w.x + sy*w.y + sz*w.z;
    imageStore(volume, pos, c);

}
