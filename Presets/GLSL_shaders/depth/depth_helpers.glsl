//
// depth_helpers.glsl
//
// Shared helpers for depth-aware ISF shaders in ossia score.
//
// USAGE
//   Include with:
//     #include "depth_helpers.glsl"
//
// TARGET
//   Vulkan-compatible GLSL 4.50.
//
// ---------------------------------------------------------------------------
// CONVENTIONS
// ---------------------------------------------------------------------------
//
// Reverse-Z
//   ossia score renders reverse-Z. The raw depth sample read via
//   IMG_THIS_DEPTH / IMG_DEPTH_NORM_PIXEL is in [0, 1] where 0 == far
//   (including sky / cleared background) and 1 == near. Use dh_isSky() to
//   test for cleared fragments explicitly.
//
// Camera
//   Every depth-aware shader declares a `"TYPE": "uniform"` camera input
//   whose LAYOUT matches:
//     mat4 view
//     mat4 projection
//     mat4 viewProjection
//     vec4 cameraPosition
//     vec4 renderSize
//     vec4 params
//   The host (SceneFlattener et al.) populates this. The helpers in this
//   file take the relevant pieces — typically `camera.projection` — as
//   arguments. They do NOT reference a global `camera` uniform; they're
//   pure-ish functions of the values passed in. This keeps them usable
//   from any shader that names the uniform block differently.
//
// Linear depth
//   "View-space depth" (aka eye depth) is the positive distance from the
//   camera along its forward axis, in world units. Small == close,
//   large == far. Computed directly from the projection matrix — no
//   separate near/far scalars needed because the projection already
//   encodes them. Sky fragments (raw depth == 0) produce a very large
//   eye depth that clamps well in practice; callers needing a bounded
//   "normalised" value should use dh_normalizedEyeDepth() which takes
//   an explicit far-cutoff.
//
// NDC Z and clipSpaceCorrMatrix
//   ossia applies `clipSpaceCorrMatrix` in the vertex stage to harmonise
//   Y-axis and depth-range conventions across GL/Vulkan/Metal/D3D. By the
//   time fragments reach our code, NDC Z is in [-1, +1] (GL-style), and
//   the depth texture value maps to NDC Z via `ndcZ = raw * 2 - 1`. The
//   linearisation helpers here use this mapping.
//
// ARCHITECTURE NOTE (depth samplers)
//   ISF's colour sampling macros (IMG_NORM_PIXEL etc.) accept any
//   sampler2D argument, including function parameters. The depth macros
//   (IMG_DEPTH_NORM_PIXEL etc.) do NOT — they use the C preprocessor's
//   token-paste operator to expand `IMG_DEPTH_NORM_PIXEL(scene, uv)` to
//   `texture(scene_depth, uv).r`, so the first argument must be a bare
//   identifier that has a matching `<name>_depth` sampler uniform. In
//   practice this means depth gathering happens in the shader body;
//   the helpers here only operate on pre-sampled depth *values* (floats).
//   This is a clean split: shaders handle I/O, helpers handle maths.
//
//   The macros expand with a trailing `.r`, so they already return a
//   `float`. Do NOT write an extra `.r` at the call site — it's
//   redundant (and technically a scalar swizzle on a float, which GLSL
//   accepts but is confusing to read).
//
// NAMING
//   All public functions are prefixed `dh_`.
//

#ifndef DEPTH_HELPERS_GLSL
#define DEPTH_HELPERS_GLSL

// ---------------------------------------------------------------------------
// Explicit-LOD reads, for use INSIDE LOOPS whose trip count is a uniform
// (sample counts, step counts). The ISF macros expand to texture(), whose
// implicit derivatives make fxc (Direct3D, ps_5_0) try to unroll such a loop;
// it fails with X3570 + X3511 and the pass is never created. The colour input
// and its depth companion have a single mip level, so LOD 0 reads exactly what
// texture() reads. Same Y fixup as the ISF macros.
// ---------------------------------------------------------------------------
#if defined(QSHADER_SPIRV)
#define IMG_NORM_PIXEL_LOD0(tex, coord) textureLod(tex, ISF_FIXUP_TEXCOORD(coord), 0.0)
#define IMG_DEPTH_NORM_PIXEL_LOD0(tex, coord) textureLod(tex##_depth, ISF_FIXUP_TEXCOORD(coord), 0.0).r
#else
#define IMG_NORM_PIXEL_LOD0(tex, coord) textureLod(tex, coord, 0.0)
#define IMG_DEPTH_NORM_PIXEL_LOD0(tex, coord) textureLod(tex##_depth, coord, 0.0).r
#endif

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const float DH_PI      = 3.14159265358979323846;
const float DH_TWO_PI  = 6.28318530717958647692;
const float DH_EPSILON = 1.0e-5;


// ---------------------------------------------------------------------------
// Depth linearisation
//
// These helpers take the camera projection matrix rather than scalar
// near/far. The projection matrix encodes both; the formulas are
// backend-neutral (work for both standard and reverse-Z projections).
// ---------------------------------------------------------------------------

// Convert a raw depth sample in [0, 1] to view-space eye depth (positive,
// world units). Uses only P[2][2] and P[3][2] of the projection matrix,
// so it handles reverse-Z and standard projections transparently.
//
// Derivation (camera looks down -Z, GL-style clip after clipSpaceCorrMatrix):
//   clip.z = a*vz + b,  clip.w = -vz         (a = P[2][2], b = P[3][2])
//   ndcZ   = clip.z / clip.w = -(a + b/vz)
//   => vz  = -b / (ndcZ + a)
//   => eyeDepth = -vz = b / (ndcZ + a)
// Works for standard GL (a, b both negative) and reverse-Z infinite (a=1,
// b=2n) alike; in both cases the ratio collapses to a positive depth.
float dh_linearizeDepth(float rawDepth, mat4 projection)
{
    float ndcZ = rawDepth * 2.0 - 1.0;
    float a    = projection[2].z;   // column-major: P[2][2]
    float b    = projection[3].z;   //               P[3][2]
    return b / (ndcZ + a);
}

// Eye depth normalised against an explicit far-cutoff, clamped to [0, 1].
// Useful for VJ controls where a user wants to reason in 0..1 rather than
// absolute world units. `farCutoff` in the same units as the camera.
// Sky fragments (very large eye depth) will clamp to 1.
float dh_normalizedEyeDepth(float rawDepth, mat4 projection, float farCutoff)
{
    float eye = dh_linearizeDepth(rawDepth, projection);
    return clamp(eye / max(farCutoff, DH_EPSILON), 0.0, 1.0);
}

// Exact inverse of dh_linearizeDepth: take a positive eye-depth (world
// units) and encode it back into the raw depth in [0, 1] that the runtime
// expects for reverse-Z gl_FragDepth writes. Use this in Rewrite-category
// shaders that compute in linear space and need to emit a raw depth value.
//
//   eyeDepth = b / (ndcZ + a)     (from dh_linearizeDepth)
//   => ndcZ  = b / eyeDepth - a
//   => raw   = (ndcZ + 1) / 2
// Sanity check for reverse-Z (a=1, b=2n): eye=n → ndcZ=1 → raw=1 (near);
// eye=+∞ → ndcZ=-1 → raw=0 (far). ✓
float dh_encodeReverseZ(float eyeDepth, mat4 projection)
{
    float a = projection[2].z;
    float b = projection[3].z;
    float safe = max(eyeDepth, DH_EPSILON);
    float ndcZ = b / safe - a;
    return clamp(ndcZ * 0.5 + 0.5, 0.0, 1.0);
}

// True if the fragment has no geometry behind it (reverse-Z cleared == 0).
bool dh_isSky(float rawDepth)
{
    return rawDepth < DH_EPSILON;
}


// ---------------------------------------------------------------------------
// View / world space reconstruction
// ---------------------------------------------------------------------------

// Reconstruct view-space position from UV + raw depth + inverse projection.
// UV is in [0, 1]; raw depth in [0, 1].
vec3 dh_viewPosFromDepth(vec2 uv, float rawDepth, mat4 invProjection)
{
    vec4 ndc  = vec4(uv * 2.0 - 1.0, rawDepth * 2.0 - 1.0, 1.0);
    vec4 view = invProjection * ndc;
    return view.xyz / view.w;
}

// Reconstruct world-space position. Requires inverse view-projection.
vec3 dh_worldPosFromDepth(vec2 uv, float rawDepth, mat4 invViewProjection)
{
    vec4 ndc   = vec4(uv * 2.0 - 1.0, rawDepth * 2.0 - 1.0, 1.0);
    vec4 world = invViewProjection * ndc;
    return world.xyz / world.w;
}


// ---------------------------------------------------------------------------
// Normal reconstruction from depth
//
// The caller samples depth at the centre and its neighbours via the ISF
// depth macros and passes the raw values in. Call site looks like:
//
//     vec2 texel = 1.0 / RENDERSIZE;
//     vec2 uv    = isf_FragNormCoord;
//     float d0 = IMG_THIS_DEPTH(inputImage);
//     float dR = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(texel.x, 0.0));
//     float dU = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, texel.y));
//     vec3  N  = dh_reconstructViewNormal(uv, texel, d0, dR, dU,
//                                         camera.projection);
// ---------------------------------------------------------------------------

// Forward-differences view-space normal from three depth samples.
// Cheap; shows artefacts along sharp depth discontinuities.
//
// The three samples are unprojected to real VIEW-SPACE positions (metres,
// camera at the origin looking down -Z) before the cross product. An earlier
// version crossed vec3(uv, eyeDepth) vectors, which mixes UV units (a texel
// is ~1e-3) with metres: every surface came out nearly edge-on and the result
// was mostly depth-precision noise. The returned normal points towards the
// viewer (N.z > 0 on camera-facing surfaces).
vec3 dh_reconstructViewNormal(vec2  uv,
                              vec2  texel,
                              float rawD0,
                              float rawDRight,
                              float rawDUp,
                              mat4  projection)
{
    mat4 invP = inverse(projection);
    vec3 p0 = dh_viewPosFromDepth(uv,                      rawD0,     invP);
    vec3 pR = dh_viewPosFromDepth(uv + vec2(texel.x, 0.0), rawDRight, invP);
    vec3 pU = dh_viewPosFromDepth(uv + vec2(0.0, texel.y), rawDUp,    invP);
    return normalize(cross(pR - p0, pU - p0));
}

// Improved reconstruction: centre + four cardinal neighbours, and per axis
// the neighbour whose depth is closer to the centre's, so a tap across a
// depth discontinuity is not used. This is the 5-tap method described by
// J. Turanszki, "Improved normal reconstruction from depth" (Wicked Engine
// blog, 2019), itself after Y. Wu's accurate-normal notes; positions are
// unprojected view-space points as above.
vec3 dh_reconstructViewNormalImproved(vec2  uv,
                                      vec2  texel,
                                      float rawD0,
                                      float rawDRight,
                                      float rawDLeft,
                                      float rawDUp,
                                      float rawDDown,
                                      mat4  projection)
{
    mat4 invP = inverse(projection);
    vec3 p0 = dh_viewPosFromDepth(uv,                       rawD0,     invP);
    vec3 pR = dh_viewPosFromDepth(uv + vec2( texel.x, 0.0), rawDRight, invP);
    vec3 pL = dh_viewPosFromDepth(uv + vec2(-texel.x, 0.0), rawDLeft,  invP);
    vec3 pU = dh_viewPosFromDepth(uv + vec2(0.0,  texel.y), rawDUp,    invP);
    vec3 pD = dh_viewPosFromDepth(uv + vec2(0.0, -texel.y), rawDDown,  invP);

    vec3 dx = (abs(pR.z - p0.z) < abs(p0.z - pL.z)) ? (pR - p0) : (p0 - pL);
    vec3 dy = (abs(pU.z - p0.z) < abs(p0.z - pD.z)) ? (pU - p0) : (p0 - pD);
    return normalize(cross(dx, dy));
}


// ---------------------------------------------------------------------------
// Edge detection on depth
//
// The gradient is taken on linearised eye depth and then DIVIDED by the local
// eye depth, so the result is a relative depth jump (0.1 = a 10% step,
// Sobel-weighted) rather than metres. An absolute threshold cannot work on a
// real scene: a floor seen at a grazing angle has a per-pixel depth step that
// grows with the square of its distance, so every metre-based threshold that
// keeps near silhouettes turns the far floor solid "edge". Scaling the
// threshold by depth is the usual remedy (e.g. E. Roystan, "Outline shader",
// 2019, which multiplies the depth threshold by the centre depth).
// ---------------------------------------------------------------------------

// Roberts-cross gradient magnitude on linearised depth.
// Sample layout: 2x2 window starting at `uv`.
//   rawDaa = uv                           (top-left)
//   rawDbb = uv + texel                   (bottom-right, diagonal)
//   rawDba = uv + vec2(texel.x, 0)        (top-right)
//   rawDab = uv + vec2(0, texel.y)        (bottom-left)
float dh_depthEdgeRoberts(float rawDaa,
                          float rawDbb,
                          float rawDba,
                          float rawDab,
                          mat4  projection)
{
    float a = dh_linearizeDepth(rawDaa, projection);
    float b = dh_linearizeDepth(rawDbb, projection);
    float c = dh_linearizeDepth(rawDba, projection);
    float d = dh_linearizeDepth(rawDab, projection);
    // Relative to the local depth (see "Edge detection on depth" above).
    return length(vec2(a - b, c - d)) / max(min(min(a, b), min(c, d)), DH_EPSILON);
}

// Sobel 3x3 gradient magnitude on a generic scalar field already sampled
// in the neighbourhood. Same layout as dh_depthEdgeSobel (row-major,
// centre at index 4, centre unused in the kernel). Use this for
// luminance, chroma, or any other scalar you want to run Sobel on.
float dh_sobelMag(float f[9])
{
    float gx = -f[0] - 2.0 * f[3] - f[6] + f[2] + 2.0 * f[5] + f[8];
    float gy = -f[0] - 2.0 * f[1] - f[2] + f[6] + 2.0 * f[7] + f[8];
    return length(vec2(gx, gy));
}

// Sobel 3x3 gradient magnitude on linearised depth. `rawD` is row-major
// top-left to bottom-right; index 4 is the centre (unused by the kernel
// but kept in the array so call sites can share one 9-sample gather loop
// with other neighbourhood helpers).
float dh_depthEdgeSobel(float rawD[9], mat4 projection)
{
    float l00 = dh_linearizeDepth(rawD[0], projection);
    float l10 = dh_linearizeDepth(rawD[1], projection);
    float l20 = dh_linearizeDepth(rawD[2], projection);
    float l01 = dh_linearizeDepth(rawD[3], projection);
    float l21 = dh_linearizeDepth(rawD[5], projection);
    float l02 = dh_linearizeDepth(rawD[6], projection);
    float l12 = dh_linearizeDepth(rawD[7], projection);
    float l22 = dh_linearizeDepth(rawD[8], projection);

    float gx = -l00 - 2.0 * l01 - l02 + l20 + 2.0 * l21 + l22;
    float gy = -l00 - 2.0 * l10 - l20 + l02 + 2.0 * l12 + l22;
    // Relative to the NEAREST depth in the window (see "Edge detection on
    // depth" above), so the edge lands on the near side of a silhouette.
    float lmin = min(min(min(l00, l10), min(l20, l01)),
                     min(min(l21, l02), min(l12, l22)));
    lmin = min(lmin, dh_linearizeDepth(rawD[4], projection));
    return length(vec2(gx, gy)) / max(lmin, DH_EPSILON);
}

// Convenience overload: neighbours as a mat3, row-major.
float dh_depthEdgeSobelMat(mat3 rawD, mat4 projection)
{
    float samples[9];
    samples[0] = rawD[0][0]; samples[1] = rawD[0][1]; samples[2] = rawD[0][2];
    samples[3] = rawD[1][0]; samples[4] = rawD[1][1]; samples[5] = rawD[1][2];
    samples[6] = rawD[2][0]; samples[7] = rawD[2][1]; samples[8] = rawD[2][2];
    return dh_depthEdgeSobel(samples, projection);
}


// ---------------------------------------------------------------------------
// Slab masks
// ---------------------------------------------------------------------------

// Soft-edged slab mask on normalised eye depth (from dh_normalizedEyeDepth).
// 1.0 inside [zmin, zmax], 0.0 outside, `softness`-wide transition at each
// edge.
float dh_slabMask(float depth01, float zmin, float zmax, float softness)
{
    float lo = smoothstep(zmin - softness, zmin + softness, depth01);
    float hi = 1.0 - smoothstep(zmax - softness, zmax + softness, depth01);
    return lo * hi;
}


// ---------------------------------------------------------------------------
// Fog factors
// ---------------------------------------------------------------------------

// Linear fog in normalised depth space. 0 == clear, 1 == fully fogged.
// `start < end`.
float dh_fogFactor(float depth01, float start, float end)
{
    return smoothstep(start, end, depth01);
}

// Exponential fog. `density > 0`; higher is foggier.
float dh_fogFactorExp(float depth01, float density)
{
    return 1.0 - exp(-density * depth01);
}

// Squared-exponential fog (Unity-style). Softer rolloff near camera.
float dh_fogFactorExp2(float depth01, float density)
{
    float d = density * depth01;
    return 1.0 - exp(-d * d);
}


// ---------------------------------------------------------------------------
// Painting a layer over the input
//
// Fog, outlines, wipes and paper tints paint a colour over the scene with a
// coverage in [0, 1]. `c` is the straight colour IMG_NORM_PIXEL returned; the
// result is straight colour for the shader's (default, straight) output. It is
// the premultiplied `over` of the paint onto the input, so where the input is
// transparent (the cleared sky) the painted layer shows at its own coverage.
// mix(c.rgb, paint, k) with alpha mix(c.a, 1, k) is the same on opaque pixels
// but stores the paint at k * k where the input is transparent.
// The vec3 overload takes one coverage per channel (alpha follows the largest).
// ---------------------------------------------------------------------------

vec4 dh_paintOver(vec4 c, vec3 paint, float coverage)
{
    float a  = mix(c.a, 1.0, coverage);
    vec3  pm = c.rgb * c.a * (1.0 - coverage) + paint * coverage;
    return vec4(pm / max(a, DH_EPSILON), a);
}

vec4 dh_paintOver(vec4 c, vec3 paint, vec3 coverage)
{
    float a  = mix(c.a, 1.0, max(coverage.r, max(coverage.g, coverage.b)));
    vec3  pm = c.rgb * c.a * (1.0 - coverage) + paint * coverage;
    return vec4(pm / max(a, DH_EPSILON), a);
}


// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

// Quantise to `steps` discrete bands. `steps > 0`.
float dh_quantize(float x, float steps)
{
    return floor(x * steps) / steps;
}

// Rec. 709 luminance.
float dh_luma(vec3 rgb)
{
    return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

// Hash helpers (not cryptographic).
float dh_hash11(float x)
{
    return fract(sin(x * 12.9898) * 43758.5453);
}

float dh_hash21(vec2 p)
{
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 dh_hash22(vec2 p)
{
    vec2 q = vec2(dot(p, vec2(127.1, 311.7)),
                  dot(p, vec2(269.5, 183.3)));
    return fract(sin(q) * 43758.5453);
}

// Interleaved-gradient noise (Jimenez 2014). Good pseudo-random
// per-fragment rotation source; pairs well with depth-sampling loops.
float dh_ign(vec2 fragCoord)
{
    return fract(52.9829189 * fract(dot(fragCoord, vec2(0.06711056, 0.00583715))));
}

// Value noise in [0, 1] from a 2D point.
float dh_valueNoise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dh_hash21(i);
    float b = dh_hash21(i + vec2(1.0, 0.0));
    float c = dh_hash21(i + vec2(0.0, 1.0));
    float d = dh_hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Safe smoothstep — guarantees well-defined behaviour when e0 == e1.
float dh_smoothstep(float e0, float e1, float x)
{
    float d = max(e1 - e0, DH_EPSILON);
    return clamp((x - e0) / d, 0.0, 1.0);
}


// ---------------------------------------------------------------------------
// Neighbourhood gather macros
//
// The ISF depth-sampling macros expand via token paste (`tex##_depth`), so
// their first argument must be a bare identifier, not a function parameter.
// That forces the gather to happen in the shader body. These macros do that
// gather in one line so shaders stay readable.
//
// Layout: row-major, top-left to bottom-right, centre at index 4.
//   out[0] out[1] out[2]       (uv + (-1,-1)) (uv + (0,-1)) (uv + (+1,-1)) * texel
//   out[3] out[4] out[5]       ...
//   out[6] out[7] out[8]
//
// Usage:
//   vec2 texel = 1.0 / RENDERSIZE;
//   float nD[9];
//   DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
//   float edge = dh_depthEdgeSobel(nD, camera.projection);
//
// For offset gathers (e.g. sampling a 3x3 around some point away from the
// current fragment), pass the offset-added UV directly:
//   DH_GATHER_DEPTH_3X3(inputImage, uv + offset, texel, nD);
// ---------------------------------------------------------------------------

#define DH_GATHER_DEPTH_3X3(imgName, centerUV, texel, outArr) do {           \
    outArr[0] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x, -(texel).y)); \
    outArr[1] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2(0.0,        -(texel).y)); \
    outArr[2] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x, -(texel).y)); \
    outArr[3] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x,  0.0));       \
    outArr[4] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV));                                \
    outArr[5] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x,  0.0));       \
    outArr[6] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x,  (texel).y)); \
    outArr[7] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2(0.0,         (texel).y)); \
    outArr[8] = IMG_DEPTH_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x,  (texel).y)); \
} while(false)

// Same layout, but for luminance of the colour input. Useful for edge
// shaders that mix depth and colour gradients.
#define DH_GATHER_LUMA_3X3(imgName, centerUV, texel, outArr) do {            \
    outArr[0] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x, -(texel).y)).rgb); \
    outArr[1] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2(0.0,        -(texel).y)).rgb); \
    outArr[2] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x, -(texel).y)).rgb); \
    outArr[3] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x,  0.0)).rgb);       \
    outArr[4] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV)).rgb);                                \
    outArr[5] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x,  0.0)).rgb);       \
    outArr[6] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2(-(texel).x,  (texel).y)).rgb); \
    outArr[7] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2(0.0,         (texel).y)).rgb); \
    outArr[8] = dh_luma(IMG_NORM_PIXEL(imgName, (centerUV) + vec2( (texel).x,  (texel).y)).rgb); \
} while(false)


#endif // DEPTH_HELPERS_GLSL
