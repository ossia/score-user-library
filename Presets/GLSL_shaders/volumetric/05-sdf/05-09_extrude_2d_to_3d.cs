/*{
  "DESCRIPTION": "Extrude a 2D image along Z: every slice within Extrusion height of the middle (z = 0.5) is a copy of the image, optionally scaled towards the centre with |z| (Taper > 0 shrinks, < 0 grows). The volume stores the image premultiplied (colour times alpha, alpha = the image's alpha), like every volume in this catalogue, so a transparent pixel becomes an empty voxel; view it with density from alpha or luminance.",
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
      "LABEL": "2D input"
    },
    {
      "NAME": "height",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Extrusion height"
    },
    {
      "NAME": "taper",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -1.0,
      "MAX": 1.0,
      "LABEL": "Taper (\u00b11)"
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

    // Half-height band centered at z=0.5
    float zd = abs(p.z - 0.5) * 2.0;
    float mask = step(zd, height);
    // Taper: scale xy toward the center proportional to |z|
    float s = 1.0 / (1.0 + taper*zd);
    vec2 uv = (p.xy - 0.5) * s + 0.5;
    vec4 c = img2D(uv);
    imageStore(volume, pos, c * mask);

}
