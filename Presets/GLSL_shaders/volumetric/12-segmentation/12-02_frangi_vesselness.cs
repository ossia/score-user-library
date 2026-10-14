/*{
  "DESCRIPTION": "Frangi vesselness (Frangi et al. 1998) for bright tubes on a dark background: the full Hessian of the red channel is taken by central differences at a spacing of Scale voxels (a cheap stand-in for Gaussian pre-smoothing at that scale), its eigenvalues are sorted by magnitude |l1| <= |l2| <= |l3|, and V = (1 - exp(-Ra^2 / 2a^2)) exp(-Rb^2 / 2b^2) (1 - exp(-S^2 / 2c^2)) with Ra = |l2|/|l3| (plate vs line), Rb = |l1|/sqrt|l2 l3| (blob vs line), S = Hessian norm (structure vs noise), a = b = 0.5. V is 0 unless l2 and l3 are both negative. Sensitivity divides c, so higher values pick up fainter tubes. Single scale; run it at several Scale values and take the max for the multiscale filter. The input is read at full precision (signed or HDR fields work); the response is clamped to [0, 1] and stored rgba16f like the other volume filters.",
  "CREDIT": "ossia 3D catalog. A. F. Frangi, W. J. Niessen, K. L. Vincken, M. A. Viergever, Multiscale vessel enhancement filtering, MICCAI 1998, LNCS 1496; eigenvalues: O. K. Smith, CACM 4(4), 1961.",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "SEGMENTATION"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "sensitivity",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Sensitivity"
    },
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.5,
      "MAX": 4.0,
      "LABEL": "Scale (voxels)"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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

// Red channel of the input, sampled with trilinear filtering.
float fieldR(vec3 p){ return texture(volIn, p).r; }

// Central-difference Hessian of the field at p, with a sample spacing of
// `h` (in texture coordinates) along each axis. Off-diagonal terms use the
// four-point mixed difference, so this is the full symmetric Hessian.
mat3 hessianAt(vec3 p, vec3 h){
    vec3 X = vec3(h.x, 0, 0), Y = vec3(0, h.y, 0), Z = vec3(0, 0, h.z);
    float c = fieldR(p);
    float xx = fieldR(p + X) - 2.0*c + fieldR(p - X);
    float yy = fieldR(p + Y) - 2.0*c + fieldR(p - Y);
    float zz = fieldR(p + Z) - 2.0*c + fieldR(p - Z);
    float xy = 0.25 * (fieldR(p + X + Y) - fieldR(p + X - Y) - fieldR(p - X + Y) + fieldR(p - X - Y));
    float xz = 0.25 * (fieldR(p + X + Z) - fieldR(p + X - Z) - fieldR(p - X + Z) + fieldR(p - X - Z));
    float yz = 0.25 * (fieldR(p + Y + Z) - fieldR(p + Y - Z) - fieldR(p - Y + Z) + fieldR(p - Y - Z));
    return mat3(xx, xy, xz,
                xy, yy, yz,
                xz, yz, zz);
}

// Eigenvalues of a real symmetric 3x3 matrix in ascending order, closed form
// (O. K. Smith, Eigenvalues of a symmetric 3x3 matrix, CACM 4(4), 1961).
vec3 symEigAscending(mat3 A){
    float p1 = A[0][1]*A[0][1] + A[0][2]*A[0][2] + A[1][2]*A[1][2];
    if(p1 < 1e-12){
        vec3 d = vec3(A[0][0], A[1][1], A[2][2]);
        float lo = min(d.x, min(d.y, d.z)), hi = max(d.x, max(d.y, d.z));
        return vec3(lo, d.x + d.y + d.z - lo - hi, hi);
    }
    float q = (A[0][0] + A[1][1] + A[2][2]) / 3.0;
    float p2 = (A[0][0]-q)*(A[0][0]-q) + (A[1][1]-q)*(A[1][1]-q) + (A[2][2]-q)*(A[2][2]-q) + 2.0*p1;
    float p = sqrt(p2 / 6.0);
    mat3 B = (A - q * mat3(1.0)) / p;
    float r = clamp(determinant(B) * 0.5, -1.0, 1.0);
    float phi = acos(r) / 3.0;
    float eMax = q + 2.0*p*cos(phi);
    float eMin = q + 2.0*p*cos(phi + 2.0943951);   // + 2*pi/3
    return vec3(eMin, 3.0*q - eMax - eMin, eMax);
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p = (vec3(pos) + 0.5) / vec3(size);

    vec3 l = symEigAscending(hessianAt(p, scale / vec3(size)));
    // Sort by magnitude: |a1| <= |a2| <= |a3|.
    vec3 a = l;
    if(abs(a.x) > abs(a.y)) a.xy = a.yx;
    if(abs(a.y) > abs(a.z)) a.yz = a.zy;
    if(abs(a.x) > abs(a.y)) a.xy = a.yx;

    float v = 0.0;
    if(a.y < 0.0 && a.z < 0.0)
    {
        const float alpha = 0.5, beta = 0.5;
        float c  = 0.5 / sensitivity;
        float Ra = abs(a.y) / abs(a.z);
        float Rb = abs(a.x) / sqrt(abs(a.y * a.z));
        float S  = length(a);
        v = (1.0 - exp(-Ra*Ra / (2.0*alpha*alpha)))
          * exp(-Rb*Rb / (2.0*beta*beta))
          * (1.0 - exp(-S*S / (2.0*c*c)));
    }
    imageStore(volOut, pos, vec4(vec3(clamp(v, 0.0, 1.0)), 1.0));
}
