/*{
  "DESCRIPTION": "Height field from a 2D image: the image lies on the floor of the volume (the XZ plane, its top edge towards -Z) and each column is filled from the bottom up to its luminance x Height scale, like a relief map or bar landscape. Voxels take the premultiplied colour and the alpha of the image pixel below them (the luminance is that of the pixel over black, so a transparent pixel has no column).",
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
      "LABEL": "Height image"
    },
    {
      "NAME": "height",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.1,
      "MAX": 1.5,
      "LABEL": "Height scale"
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

    // The image lies on the floor (XZ, its top edge at the back, -Z) and
    // its luminance is the height along Y, the viewers' up axis.
    vec4 s = img2D(vec2(p.x, 1.0 - p.z));
    float L = dot(s.rgb, vec3(0.2126, 0.7152, 0.0722)) * height;
    float mask = step(p.y, L);
    imageStore(volume, pos, s * mask);

}
