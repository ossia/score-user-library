/*{
  "DESCRIPTION": "Approximate distance transform by iterative relaxation: voxels of the seed volume above Threshold are 0, every other voxel takes the minimum of its six face neighbours plus one step, so the front advances one voxel per frame (about N frames to cover an N^3 volume) and the result is the 6-connected (city-block) distance to the nearest seed. Seeds are re-read every frame, so the field follows a moving input. Output (all channels) is the distance as a fraction of the volume edge, capped at 4; use it for colouring by distance or as an SDF-like field.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "MORPHOLOGY"
  ],
  "RESOURCES": [
    {
      "NAME": "seedVol",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Seed (binary)"
    },
    {
      "NAME": "threshold",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Seed threshold"
    },
    {
      "NAME": "stepSize",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 4.0,
      "LABEL": "Step size"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "r16f",
      "WIDTH": "$WIDTH_seedVol",
      "HEIGHT": "$HEIGHT_seedVol",
      "DEPTH": "$DEPTH_seedVol",
      "PERSISTENT": true
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

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 sz = imageSize(volOut);
    if(any(greaterThanEqual(pos, sz))) return;
    vec3 p = (vec3(pos) + 0.5) / vec3(sz);
    // Distances are stored as a fraction of the volume edge (one voxel =
    // stepSize / size.x), so a viewer can use them directly; FAR stays well
    // inside half-float range (the old 1e6 overflowed r16f to +inf).
    const float FAR = 4.0;
    float vox = stepSize / float(sz.x);
    // Seeds are re-read every frame, so a moving input keeps its field up to
    // date. Seed on the first dispatch too: score currently starts FRAMEINDEX
    // at 1, not at 0 as the ISF spec says (see showcase/volume/_engine).
    bool isSeed = texture(seedVol, p).r > threshold;
    if(FRAMEINDEX <= 1 || isSeed){
        imageStore(volOut, pos, vec4(isSeed ? 0.0 : FAR));
        return;
    }
    // Relax from the 6 face neighbours (a chamfer / city-block metric).
    float best = min(imageLoad(volOut_prev, pos).r, FAR);
    for(int a = 0; a < 3; a++){
        ivec3 off = ivec3(0);
        off[a] = 1;
        ivec3 pp = clamp(pos + off, ivec3(0), sz-1);
        ivec3 pm = clamp(pos - off, ivec3(0), sz-1);
        best = min(best, imageLoad(volOut_prev, pp).r + vox);
        best = min(best, imageLoad(volOut_prev, pm).r + vox);
    }
    imageStore(volOut, pos, vec4(best));
}
