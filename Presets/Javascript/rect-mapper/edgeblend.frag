VARYING vec2 texcoord;

void MAIN()
{
    vec2 uv = texcoord;
    if (FRAMEBUFFER_Y_UP < 0.0)
      uv.y = 1.0 - uv.y;

    if (manualUv > 0.5) {
        uv -= vec2(0.5);
        float rad = uvRotation * 3.14159265 / 180.0;
        float c = cos(rad), s = sin(rad);
        uv = vec2(c*uv.x - s*uv.y, s*uv.x + c*uv.y);
        uv /= uvScale;
        uv += vec2(0.5) - uvOffset;
    }
    vec4 tex = texture(srcTex, uv);

    float alpha = 1.0;

    if (blendLeft > 0.001)
        alpha *= smoothstep(0.0, blendLeft, texcoord.x);
    if (blendRight > 0.001)
        alpha *= smoothstep(0.0, blendRight, 1.0 - texcoord.x);
    if (blendTop > 0.001)
        alpha *= smoothstep(0.0, blendTop, 1.0 - texcoord.y);
    if (blendBottom > 0.001)
        alpha *= smoothstep(0.0, blendBottom, texcoord.y);

    // MSAA can evaluate the varying outside the mesh at partially covered
    // pixels. smoothstep makes those edge weights exactly zero; keep the
    // endpoints exact instead of passing zero through the GPU's power/log path.
    if (alpha > 0.0 && alpha < 1.0)
        alpha = pow(alpha, blendGamma);
    alpha *= shapeOpacity;

    FRAGCOLOR = vec4(tex.rgb * alpha, alpha);
}
