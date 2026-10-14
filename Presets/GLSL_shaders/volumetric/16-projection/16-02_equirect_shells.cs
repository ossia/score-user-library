/*{
  "DESCRIPTION": "Equirectangular projection \u2192 nested spherical shells: each spherical shell samples a 2D image as a panorama. Great with 360\u00b0 VJ footage. Colour is stored premultiplied: the image's colour and alpha, both times the shell mask.",
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
      "LABEL": "Equirect panorama"
    },
    {
      "NAME": "shells",
      "TYPE": "long",
      "DEFAULT": 6,
      "MIN": 1,
      "MAX": 12,
      "LABEL": "Shells"
    },
    {
      "NAME": "shellThickness",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.01,
      "MAX": 0.5,
      "LABEL": "Shell thickness"
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

    float r = length(pc);
    float sh = r * float(shells);
    float shellMask = 1.0 - smoothstep(0.5 - shellThickness, 0.5 + shellThickness, abs(fract(sh) - 0.5));
    // Equirect lookup
    float phi = atan(pc.z, pc.x);
    float theta = acos(clamp(pc.y / max(r, 1e-5), -1.0, 1.0));
    vec2 uv = vec2(phi/(2.0*3.14159265) + 0.5, theta/3.14159265);
    vec4 c = img2D(uv);
    imageStore(volume, pos, c * shellMask);

}
