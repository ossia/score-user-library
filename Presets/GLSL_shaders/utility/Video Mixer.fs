/*{
    "CATEGORIES": [
        "General"
    ],
    "CREDIT": "Jamie Owen, Jean-Michaël Celerier, Optimized by AI Assistant (Gemini)",
    "DESCRIPTION": "8-channel video mixer (Optimized)",
    "INPUTS": [
        { "NAME": "t1", "LABEL" : "Texture 1", "TYPE": "image" },
        { "NAME": "t2", "LABEL" : "Texture 2", "TYPE": "image" },
        { "NAME": "t3", "LABEL" : "Texture 3", "TYPE": "image" },
        { "NAME": "t4", "LABEL" : "Texture 4", "TYPE": "image" },
        { "NAME": "t5", "LABEL" : "Texture 5", "TYPE": "image" },
        { "NAME": "t6", "LABEL" : "Texture 6", "TYPE": "image" },
        { "NAME": "t7", "LABEL" : "Texture 7", "TYPE": "image" },
        { "NAME": "t8", "LABEL" : "Texture 8", "TYPE": "image" },
        { "NAME": "alpha1", "LABEL" : "Alpha 1", "DEFAULT": 1, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha2", "LABEL" : "Alpha 2", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha3", "LABEL" : "Alpha 3", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha4", "LABEL" : "Alpha 4", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha5", "LABEL" : "Alpha 5", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha6", "LABEL" : "Alpha 6", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha7", "LABEL" : "Alpha 7", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "NAME": "alpha8", "LABEL" : "Alpha 8", "DEFAULT": 0, "MAX": 1, "MIN": 0, "TYPE": "float" },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 1",
           "TYPE" : "long",
           "NAME" : "mode1"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 2",
           "TYPE" : "long",
           "NAME" : "mode2"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 3",
           "TYPE" : "long",
           "NAME" : "mode3"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 4",
           "TYPE" : "long",
           "NAME" : "mode4"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 5",
           "TYPE" : "long",
           "NAME" : "mode5"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 6",
           "TYPE" : "long",
           "NAME" : "mode6"
        },
        { "VALUES" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
           "LABELS" : [ "Add", "Average", "Color Burn", "Color Dodge", "Darken", "Difference", 
                        "Exclusion", "Glow", "Hard Light", "Hard Mix", "Lighten", "Linear Burn", 
                        "Linear Dodge", "Linear Light", "Multiply", "Negation", "Normal", "Overlay", 
                        "Phoenix", "Pin Light", "Reflect", "Screen", "Soft Light", "Subtract", "Vivid Light"],
           "IDENTITY" : 1,
           "DEFAULT" : 17,
           "LABEL" : "Mode 7",
           "TYPE" : "long",
           "NAME" : "mode7"
        }
    ],
    "ISFVSN": "2"
}
*/

/* Blend mode implementations courtesy of Jamie Owen:
   https://github.com/jamieowen/glsl-blend
*/

vec3 blendPhoenix(vec3 base, vec3 blend) {
  return min(base, blend) - max(base, blend) + vec3(1.0);
}
float blendOverlay(float base, float blend) {
  return base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend));
}
vec3 blendOverlay(vec3 base, vec3 blend) {
  return vec3(blendOverlay(base.r, blend.r), blendOverlay(base.g, blend.g), blendOverlay(base.b, blend.b));
}
vec3 blendNormal(vec3 base, vec3 blend) { return blend; }
vec3 blendNegation(vec3 base, vec3 blend) {
  return vec3(1.0) - abs(vec3(1.0) - base - blend);
}
vec3 blendMultiply(vec3 base, vec3 blend) { return base * blend; }
float blendReflect(float base, float blend) {
  return (blend == 1.0) ? blend : min(base * base / (1.0 - blend), 1.0);
}
vec3 blendReflect(vec3 base, vec3 blend) {
  return vec3(blendReflect(base.r, blend.r), blendReflect(base.g, blend.g), blendReflect(base.b, blend.b));
}
vec3 blendAverage(vec3 base, vec3 blend) { return (base + blend) / 2.0; }
float blendLinearBurn(float base, float blend) {
  return max(base + blend - 1.0, 0.0);
}
vec3 blendLinearBurn(vec3 base, vec3 blend) {
  return max(base + blend - vec3(1.0), vec3(0.0));
}
float blendLighten(float base, float blend) { return max(blend, base); }
vec3 blendLighten(vec3 base, vec3 blend) {
  return vec3(blendLighten(base.r, blend.r), blendLighten(base.g, blend.g), blendLighten(base.b, blend.b));
}
float blendScreen(float base, float blend) {
  return 1.0 - ((1.0 - base) * (1.0 - blend));
}
vec3 blendScreen(vec3 base, vec3 blend) {
  return vec3(blendScreen(base.r, blend.r), blendScreen(base.g, blend.g), blendScreen(base.b, blend.b));
}
float blendSoftLight(float base, float blend) {
  return (blend < 0.5)
             ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend))
             : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend));
}
vec3 blendSoftLight(vec3 base, vec3 blend) {
  return vec3(blendSoftLight(base.r, blend.r), blendSoftLight(base.g, blend.g), blendSoftLight(base.b, blend.b));
}
float blendSubtract(float base, float blend) {
  return max(base + blend - 1.0, 0.0);
}
vec3 blendSubtract(vec3 base, vec3 blend) {
  return max(base + blend - vec3(1.0), vec3(0.0));
}
vec3 blendExclusion(vec3 base, vec3 blend) {
  return base + blend - 2.0 * base * blend;
}
vec3 blendDifference(vec3 base, vec3 blend) { return abs(base - blend); }
float blendDarken(float base, float blend) { return min(blend, base); }
vec3 blendDarken(vec3 base, vec3 blend) {
  return vec3(blendDarken(base.r, blend.r), blendDarken(base.g, blend.g), blendDarken(base.b, blend.b));
}
float blendColorDodge(float base, float blend) {
  return (blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0);
}
vec3 blendColorDodge(vec3 base, vec3 blend) {
  return vec3(blendColorDodge(base.r, blend.r), blendColorDodge(base.g, blend.g), blendColorDodge(base.b, blend.b));
}
float blendColorBurn(float base, float blend) {
  return (blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0);
}
vec3 blendColorBurn(vec3 base, vec3 blend) {
  return vec3(blendColorBurn(base.r, blend.r), blendColorBurn(base.g, blend.g), blendColorBurn(base.b, blend.b));
}
float blendAdd(float base, float blend) { return min(base + blend, 1.0); }
vec3 blendAdd(vec3 base, vec3 blend) { return min(base + blend, vec3(1.0)); }
float blendLinearDodge(float base, float blend) {
  return min(base + blend, 1.0);
}
vec3 blendLinearDodge(vec3 base, vec3 blend) {
  return min(base + blend, vec3(1.0));
}
vec3 blendHardLight(vec3 base, vec3 blend) { return blendOverlay(blend, base); }
vec3 blendGlow(vec3 base, vec3 blend) { return blendReflect(blend, base); }
float blendVividLight(float base, float blend) {
  return (blend < 0.5) ? blendColorBurn(base, (2.0 * blend)) : blendColorDodge(base, (2.0 * (blend - 0.5)));
}
vec3 blendVividLight(vec3 base, vec3 blend) {
  return vec3(blendVividLight(base.r, blend.r), blendVividLight(base.g, blend.g), blendVividLight(base.b, blend.b));
}
float blendHardMix(float base, float blend) {
  return (blendVividLight(base, blend) < 0.5) ? 0.0 : 1.0;
}
vec3 blendHardMix(vec3 base, vec3 blend) {
  return vec3(blendHardMix(base.r, blend.r), blendHardMix(base.g, blend.g), blendHardMix(base.b, blend.b));
}
float blendLinearLight(float base, float blend) {
  return blend < 0.5 ? blendLinearBurn(base, (2.0 * blend)) : blendLinearDodge(base, (2.0 * (blend - 0.5)));
}
vec3 blendLinearLight(vec3 base, vec3 blend) {
  return vec3(blendLinearLight(base.r, blend.r), blendLinearLight(base.g, blend.g), blendLinearLight(base.b, blend.b));
}
float blendPinLight(float base, float blend) {
  return (blend < 0.5) ? blendDarken(base, (2.0 * blend)) : blendLighten(base, (2.0 * (blend - 0.5)));
}
vec3 blendPinLight(vec3 base, vec3 blend) {
  return vec3(blendPinLight(base.r, blend.r), blendPinLight(base.g, blend.g), blendPinLight(base.b, blend.b));
}

// 3-argument version of blendMode
vec3 blendMode(int mode, vec3 base, vec3 blend) {
  if (mode == 1) return blendAdd(base, blend);
  else if (mode == 2) return blendAverage(base, blend);
  else if (mode == 3) return blendColorBurn(base, blend);
  else if (mode == 4) return blendColorDodge(base, blend);
  else if (mode == 5) return blendDarken(base, blend);
  else if (mode == 6) return blendDifference(base, blend);
  else if (mode == 7) return blendExclusion(base, blend);
  else if (mode == 8) return blendGlow(base, blend);
  else if (mode == 9) return blendHardLight(base, blend);
  else if (mode == 10) return blendHardMix(base, blend);
  else if (mode == 11) return blendLighten(base, blend);
  else if (mode == 12) return blendLinearBurn(base, blend);
  else if (mode == 13) return blendLinearDodge(base, blend);
  else if (mode == 14) return blendLinearLight(base, blend);
  else if (mode == 15) return blendMultiply(base, blend);
  else if (mode == 16) return blendNegation(base, blend);
  else if (mode == 17) return blendNormal(base, blend);
  else if (mode == 18) return blendOverlay(base, blend);
  else if (mode == 19) return blendPhoenix(base, blend);
  else if (mode == 20) return blendPinLight(base, blend);
  else if (mode == 21) return blendReflect(base, blend);
  else if (mode == 22) return blendScreen(base, blend);
  else if (mode == 23) return blendSoftLight(base, blend);
  else if (mode == 24) return blendSubtract(base, blend);
  else if (mode == 25) return blendVividLight(base, blend);
  else return vec3(0.,0.,0.);
}

// 4-argument version (handles the opacity mapping beautifully with mix!)
vec3 blendMode(int mode, vec3 base, vec3 blend, float opacity) {
    return mix(base, blendMode(mode, base, blend), opacity);
}

void main() {
  // Base Layer (t1)
  vec4 s1 = vec4(0.0);
  if (alpha1 > 0.0) {
      s1 = IMG_THIS_PIXEL(t1);
  }
  float a = s1.a * alpha1;
  vec3 rgb = s1.rgb * a;
  
  // Layer 2
  if (alpha2 > 0.0) {
      vec4 s2 = IMG_THIS_PIXEL(t2);
      float ea = s2.a * alpha2;
      if (ea > 0.0) {
          rgb = blendMode(mode1, rgb, s2.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 3
  if (alpha3 > 0.0) {
      vec4 s3 = IMG_THIS_PIXEL(t3);
      float ea = s3.a * alpha3;
      if (ea > 0.0) {
          rgb = blendMode(mode2, rgb, s3.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 4
  if (alpha4 > 0.0) {
      vec4 s4 = IMG_THIS_PIXEL(t4);
      float ea = s4.a * alpha4;
      if (ea > 0.0) {
          rgb = blendMode(mode3, rgb, s4.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 5
  if (alpha5 > 0.0) {
      vec4 s5 = IMG_THIS_PIXEL(t5);
      float ea = s5.a * alpha5;
      if (ea > 0.0) {
          rgb = blendMode(mode4, rgb, s5.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 6
  if (alpha6 > 0.0) {
      vec4 s6 = IMG_THIS_PIXEL(t6);
      float ea = s6.a * alpha6;
      if (ea > 0.0) {
          rgb = blendMode(mode5, rgb, s6.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 7
  if (alpha7 > 0.0) {
      vec4 s7 = IMG_THIS_PIXEL(t7);
      float ea = s7.a * alpha7;
      if (ea > 0.0) {
          rgb = blendMode(mode6, rgb, s7.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  // Layer 8
  if (alpha8 > 0.0) {
      vec4 s8 = IMG_THIS_PIXEL(t8);
      float ea = s8.a * alpha8;
      if (ea > 0.0) {
          rgb = blendMode(mode7, rgb, s8.rgb, ea);
          a = a + ea * (1.0 - a);
      }
  }

  gl_FragColor = vec4(rgb, a);
}