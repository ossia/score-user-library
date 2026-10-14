/*{
  "DESCRIPTION": "Cubemap-style projection from a single 2D image laid out as a horizontal cross (4 x 3 tiles): middle row -X, +Z, +X, -Z from left to right, +Y above +Z and -Y below it. Each voxel picks the face of its dominant axis and samples that tile, so the cube's shell shows the six faces and its inside repeats them inwards. Handy without a real cubemap input. The volume stores the image premultiplied (colour times alpha), like every volume in this catalogue.",
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
      "LABEL": "2D cross (4x3 tiles)"
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

    vec3 a = abs(pc);
    vec2 uv;
    vec2 tileOrigin;
    if(a.x >= a.y && a.x >= a.z){
        // +/- X face
        uv = (pc.x > 0.0) ? vec2(-pc.z, pc.y) : vec2(pc.z, pc.y);
        uv = uv / a.x * 0.5 + 0.5;
        tileOrigin = (pc.x > 0.0) ? vec2(2.0/4.0, 1.0/3.0) : vec2(0.0, 1.0/3.0);
    } else if(a.y >= a.x && a.y >= a.z){
        uv = (pc.y > 0.0) ? vec2(pc.x, -pc.z) : vec2(pc.x, pc.z);
        uv = uv / a.y * 0.5 + 0.5;
        tileOrigin = (pc.y > 0.0) ? vec2(1.0/4.0, 2.0/3.0) : vec2(1.0/4.0, 0.0);
    } else {
        uv = (pc.z > 0.0) ? vec2(pc.x, pc.y) : vec2(-pc.x, pc.y);
        uv = uv / a.z * 0.5 + 0.5;
        tileOrigin = (pc.z > 0.0) ? vec2(1.0/4.0, 1.0/3.0) : vec2(3.0/4.0, 1.0/3.0);
    }
    vec2 tile = uv / vec2(4.0, 3.0) + tileOrigin;
    imageStore(volume, pos, img2D(tile));

}
