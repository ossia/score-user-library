/*{
  "DESCRIPTION": "Volume switcher: forwards one of eight 3D volumes, chosen by Index. The 3D counterpart of the Video Switcher 8 utility (which switches 2D images and can only output a 2D image), so a whole volume chain can be swapped live before one viewer. The output takes the largest size among the connected inputs (an unconnected input is a 1x1x1 placeholder), fixed when the node is built; each input is sampled at normalised coordinates, so a smaller volume is resampled trilinearly to that grid, as a smaller image is stretched by the 2D switcher. Selecting an unconnected slot gives an empty volume (all zero: no colour, no density). The output is rgba16f, so signed and HDR inputs pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COMPOSITE"
  ],
  "INPUTS": [
    { "NAME": "t0", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 0" },
    { "NAME": "t1", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 1" },
    { "NAME": "t2", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 2" },
    { "NAME": "t3", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 3" },
    { "NAME": "t4", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 4" },
    { "NAME": "t5", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 5" },
    { "NAME": "t6", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 6" },
    { "NAME": "t7", "TYPE": "texture", "DIMENSIONS": 3, "LABEL": "Volume 7" },
    {
      "NAME": "index",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [0, 1, 2, 3, 4, 5, 6, 7],
      "LABELS": ["0", "1", "2", "3", "4", "5", "6", "7"],
      "LABEL": "Index"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "max($WIDTH_t0, $WIDTH_t1, $WIDTH_t2, $WIDTH_t3, $WIDTH_t4, $WIDTH_t5, $WIDTH_t6, $WIDTH_t7)",
      "HEIGHT": "max($HEIGHT_t0, $HEIGHT_t1, $HEIGHT_t2, $HEIGHT_t3, $HEIGHT_t4, $HEIGHT_t5, $HEIGHT_t6, $HEIGHT_t7)",
      "DEPTH": "max($DEPTH_t0, $DEPTH_t1, $DEPTH_t2, $DEPTH_t3, $DEPTH_t4, $DEPTH_t5, $DEPTH_t6, $DEPTH_t7)"
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
        "TARGET": "volOut"
      }
    }
  ]
}*/

// An unconnected slot is bound to the engine's 1x1x1 placeholder, whose
// content is undefined: read it as empty.
vec4 pick(sampler3D t, vec3 p)
{
    return all(equal(textureSize(t, 0), ivec3(1))) ? vec4(0.0) : texture(t, p);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p = (vec3(pos) + 0.5) / vec3(size);
    vec4 o;
    switch(int(index))
    {
        case 0: o = pick(t0, p); break;
        case 1: o = pick(t1, p); break;
        case 2: o = pick(t2, p); break;
        case 3: o = pick(t3, p); break;
        case 4: o = pick(t4, p); break;
        case 5: o = pick(t5, p); break;
        case 6: o = pick(t6, p); break;
        case 7: o = pick(t7, p); break;
        default: o = vec4(0.0);
    }
    imageStore(volOut, pos, o);
}
