/*{
  "DESCRIPTION": "Free-camera isosurface raycaster for a 3D volume inside a unit cube. Each ray is clipped to the cube (slab test), marched at a fixed step until the chosen density channel crosses Iso, the hit is refined by linear interpolation between the two bracketing samples plus two bisection steps (Hadwiger et al. 2005), and shaded with a Lambert key light plus a hemispherical fill, using the normalised central-difference gradient of the field as the normal (Levoy 1988). Surface colour is Tint, the volume's own RGB at the hit, or the RGB of an optional second Colour volume at the hit (so a surface taken from one field can be painted by another, e.g. 09-11 axis ramp or 08-14 chromatic split of the same source). Invert makes the solid the region below Iso (for distance-like fields such as Worley F1), Clip X cuts the volume open to show nested structure. Show box draws the cube's silhouette edges for orientation. The 3D counterpart of 18-05, which only looks down +Z. Volumes store premultiplied colour, so Volume RGB and Colour volume RGB are unpremultiplied (divided by the alpha at the hit) to give the surface its straight colour; a volume with alpha 1 is used as is.",
  "CREDIT": "ossia 3D catalog. M. Levoy, Display of Surfaces from Volume Data, IEEE CG&A 8(3), 1988; M. Hadwiger, C. Sigg, H. Scharsach, K. Buehler, M. Gross, Real-Time Ray-Casting and Advanced Shading of Discrete Isosurfaces, Eurographics 2005; T. Kay, J. Kajiya, Ray Tracing Complex Scenes (slab test), SIGGRAPH 1986.",
  "ISFVSN": "2.0",
  "CATEGORIES": [ "3D-VIEWER" ],
  "INPUTS": [
    { "NAME": "volume", "TYPE": "image", "DIMENSIONS": 3, "LABEL": "Volume" },
    { "NAME": "colorVolume", "TYPE": "image", "DIMENSIONS": 3, "LABEL": "Colour volume (optional)" },
    { "NAME": "iso", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0, "LABEL": "Iso value" },
    { "NAME": "densityFrom", "TYPE": "long", "DEFAULT": 2, "VALUES": [0, 1, 2, 3, 4], "LABELS": ["Alpha", "Luminance", "Red", "Green", "Blue"], "LABEL": "Density from" },
    { "NAME": "invert", "TYPE": "bool", "DEFAULT": false, "LABEL": "Invert (solid below Iso)" },
    { "NAME": "clipX", "TYPE": "float", "DEFAULT": 0.5, "MIN": -0.5, "MAX": 0.5, "LABEL": "Clip X (cut away x > this)" },
    { "NAME": "yaw", "TYPE": "float", "DEFAULT": 0.6, "MIN": -3.14, "MAX": 3.14, "LABEL": "Yaw" },
    { "NAME": "pitch", "TYPE": "float", "DEFAULT": 0.35, "MIN": -1.5, "MAX": 1.5, "LABEL": "Pitch" },
    { "NAME": "zoom", "TYPE": "float", "DEFAULT": 1.8, "MIN": 0.9, "MAX": 6.0, "LABEL": "Distance" },
    { "NAME": "spin", "TYPE": "float", "DEFAULT": 0.0, "MIN": -2.0, "MAX": 2.0, "LABEL": "Spin (rad/s)" },
    { "NAME": "steps", "TYPE": "long", "DEFAULT": 192, "MIN": 32, "MAX": 512, "LABEL": "Steps" },
    { "NAME": "lightDir", "TYPE": "point3D", "DEFAULT": [0.5, 0.8, 0.3], "LABEL": "Light direction (world)" },
    { "NAME": "colorFrom", "TYPE": "long", "DEFAULT": 0, "VALUES": [0, 1, 2], "LABELS": ["Tint", "Volume RGB", "Colour volume RGB"], "LABEL": "Surface colour" },
    { "NAME": "tint", "TYPE": "color", "DEFAULT": [0.95, 0.78, 0.5, 1.0], "LABEL": "Tint" },
    { "NAME": "background", "TYPE": "color", "DEFAULT": [0.02, 0.025, 0.035, 1.0], "LABEL": "Background" },
    { "NAME": "showBox", "TYPE": "bool", "DEFAULT": true, "LABEL": "Show box" }
  ]
}*/

vec3 straightColor(vec4 s) { return s.a > 0.0 ? s.rgb / s.a : s.rgb; }

// Slab test against the unit cube centred at the origin.
vec2 rayBox(vec3 ro, vec3 rd)
{
    vec3 inv = 1.0 / rd;
    vec3 t1 = (-vec3(0.5) - ro) * inv;
    vec3 t2 = ( vec3(0.5) - ro) * inv;
    vec3 tn = min(t1, t2);
    vec3 tf = max(t1, t2);
    return vec2(max(max(tn.x, tn.y), tn.z), min(min(tf.x, tf.y), tf.z));
}

float field(vec3 wp)
{
    // Everything past the clip plane is empty, whichever side Invert selects.
    if(wp.x > clipX) return invert ? 1e3 : -1e3;
    vec4 s = textureLod(volume, wp + 0.5, 0.0);
    float f = (densityFrom == 0) ? s.a
            : (densityFrom == 1) ? dot(s.rgb, vec3(0.2126, 0.7152, 0.0722))
            : (densityFrom == 2) ? s.r
            : (densityFrom == 3) ? s.g
            : s.b;
    return f;
}

// Signed so that > 0 is inside the solid.
float inside(vec3 wp) { return invert ? iso - field(wp) : field(wp) - iso; }

void main()
{
    vec2 uv = isf_FragNormCoord * 2.0 - 1.0;
    uv.x *= RENDERSIZE.x / RENDERSIZE.y;

    float yw = yaw + spin * TIME;
    vec3 ro = zoom * vec3(cos(pitch) * cos(yw), sin(pitch), cos(pitch) * sin(yw));
    vec3 fwd = -normalize(ro);
    // right = fwd x up: with up x fwd the screen basis is left-handed and
    // the picture comes out mirrored left-right.
    vec3 right = normalize(cross(fwd, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, fwd);
    vec3 rd = normalize(uv.x * right + uv.y * up + 1.5 * fwd);

    vec3 col = background.rgb;
    vec2 tnf = rayBox(ro, rd);
    tnf.x = max(tnf.x, 0.0);
    if(tnf.x < tnf.y)
    {
        int N = int(steps);
        float dt = (tnf.y - tnf.x) / float(N);
        float t0 = tnf.x;
        float f0 = inside(ro + rd * t0);
        bool hit = false;
        float th = 0.0;
        // A ray that starts inside the solid shows the cube face as a cut.
        if(f0 > 0.0) { hit = true; th = t0; }
        for(int i = 1; i <= N && !hit; i++)
        {
            float t1 = tnf.x + float(i) * dt;
            float f1 = inside(ro + rd * t1);
            if(f1 > 0.0)
            {
                // Linear estimate, then two bisection refinements.
                float a = t0, b = t1, fa = f0;
                for(int k = 0; k < 2; k++)
                {
                    float m = 0.5 * (a + b);
                    float fm = inside(ro + rd * m);
                    if(fm > 0.0) b = m; else { a = m; fa = fm; }
                }
                float fb = inside(ro + rd * b);
                th = mix(a, b, clamp(-fa / max(fb - fa, 1e-6), 0.0, 1.0));
                hit = true;
            }
            t0 = t1; f0 = f1;
        }
        if(hit)
        {
            vec3 p = ro + rd * th;
            vec3 e = 1.0 / vec3(textureSize(volume, 0));
            vec3 g = vec3(inside(p + vec3(e.x, 0, 0)) - inside(p - vec3(e.x, 0, 0)),
                          inside(p + vec3(0, e.y, 0)) - inside(p - vec3(0, e.y, 0)),
                          inside(p + vec3(0, 0, e.z)) - inside(p - vec3(0, 0, e.z)));
            // inside() rises into the solid, so the outward normal is -grad.
            vec3 n = -g / max(length(g), 1e-6);
            // On a cut face the field gradient is meaningless: use the face normal.
            if(abs(p.x - clipX) < 1.5 * e.x) n = vec3(1.0, 0.0, 0.0);
            else if(length(g) < 1e-4 || th <= tnf.x + 1e-5)
            {
                vec3 q = abs(p);
                n = (q.x > q.y && q.x > q.z) ? vec3(sign(p.x), 0, 0)
                  : (q.y > q.z) ? vec3(0, sign(p.y), 0) : vec3(0, 0, sign(p.z));
            }
            if(dot(n, rd) > 0.0) n = -n;
            vec3 L = normalize(lightDir + 1e-6);
            float diff = max(dot(n, L), 0.0);
            float hemi = 0.5 + 0.5 * n.y;
            vec3 base = (colorFrom == 1) ? straightColor(textureLod(volume, p + 0.5, 0.0))
                      : (colorFrom == 2) ? straightColor(textureLod(colorVolume, p + 0.5, 0.0))
                      : tint.rgb;
            col = base * (0.15 + 0.2 * hemi + 0.75 * diff);
        }
    }

    if(showBox)
    {
        // Cube silhouette: pixels whose ray grazes a cube edge.
        vec2 tb = rayBox(ro, rd);
        if(tb.x < tb.y)
        {
            vec3 pe = ro + rd * tb.x;
            vec3 q = abs(pe);
            float a = max(max(min(q.x, q.y), min(q.y, q.z)), min(q.x, q.z));
            float w = 0.004 * length(pe - ro);
            col = mix(col, vec3(0.45, 0.5, 0.6), smoothstep(0.5 - w, 0.5, a) * 0.6);
        }
    }
    isf_FragColor = vec4(col, 1.0);
}
