/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Cubist / Voronoi shatter. Partitions the screen into Voronoi cells sized inversely with depth — near stuff breaks into big abstract tiles, far stuff into tiny shards. Each cell samples colour from a perturbed UV, producing a stained-glass / Picasso effect.",
    "CATEGORIES": ["Post-process", "Warp"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "cellScaleNear", "TYPE": "float", "LABEL": "Cell count near",
          "DEFAULT": 20.0, "MIN": 2.0, "MAX": 200.0 },
        { "NAME": "cellScaleFar", "TYPE": "float", "LABEL": "Cell count far",
          "DEFAULT": 80.0, "MIN": 2.0, "MAX": 400.0 },
        { "NAME": "jitter", "TYPE": "float", "LABEL": "Cell jitter amount",
          "DEFAULT": 0.7, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "mixAmount", "TYPE": "float", "LABEL": "Mix (0 = scene, 1 = full shatter)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

// Return the cell-site UV so the caller can sample scene colour there.
void voronoiCellSite(vec2 p, float jitterAmt, out vec2 siteUV, out float dist)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    float best = 1e6;
    vec2 bestAbs = vec2(0.0);
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            vec2 g = vec2(float(x), float(y));
            vec2 o = dh_hash22(i + g) * jitterAmt;
            vec2 pt = g + o;
            float d = dot(pt - f, pt - f);
            if (d < best) { best = d; bestAbs = i + g + o; }
        }
    }
    siteUV = bestAbs;
    dist   = sqrt(best);
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float t     = clamp(eye / depthScale, 0.0, 1.0);

    float cells = mix(cellScaleNear, cellScaleFar, t);
    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    vec2 scaled = vec2(uv.x * aspect, uv.y) * cells;

    vec2 siteUV; float dist;
    voronoiCellSite(scaled, jitter, siteUV, dist);
    vec2 sampleUV = vec2(siteUV.x / aspect, siteUV.y) / cells;

    // The shard takes its site's colour AND opacity (a shard sampled from an
    // object may land over the transparent sky, and the reverse).
    vec4 cell = IMG_NORM_PIXEL(inputImage, sampleUV);
    vec3  pm = mix(color.rgb * color.a, cell.rgb * cell.a, mixAmount);
    float a  = mix(color.a, cell.a, mixAmount);
    isf_FragColor = vec4(pm / max(a, DH_EPSILON), a);
    gl_FragDepth = rawD;
}
