/*{
  "DESCRIPTION": "Revolve a 2D image around the Y axis: density at (x,y,z) = sample at (r, y) where r = length(xz). 2D image becomes a lathed solid. The volume stores the image premultiplied (colour times alpha, alpha = the image's alpha), like every volume in this catalogue, so transparent pixels become empty voxels; the left edge of the image is the axis.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SDF"
  ],
  "RESOURCES": [
    {
      "NAME": "inputImage",
      "TYPE": "texture",
      "LABEL": "2D profile (r axis = image X)"
    },
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

    float r = length(vec2(p.x-0.5, p.z-0.5)) * 2.0;
    if(r > 1.0){ imageStore(volume, pos, vec4(0.0)); return; }
    vec4 c = img2D(vec2(r, p.y));
    imageStore(volume, pos, c);

}
