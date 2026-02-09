VARYING vec2 texcoord;

void MAIN()
{
    vec4 tex = texture(srcTex, texcoord);

    float alpha = 1.0;

    if (blendLeft > 0.001)
        alpha *= smoothstep(0.0, blendLeft, texcoord.x);
    if (blendRight > 0.001)
        alpha *= smoothstep(0.0, blendRight, 1.0 - texcoord.x);
    if (blendTop > 0.001)
        alpha *= smoothstep(0.0, blendTop, 1.0 - texcoord.y);
    if (blendBottom > 0.001)
        alpha *= smoothstep(0.0, blendBottom, texcoord.y);

    alpha = pow(alpha, blendGamma);

    FRAGCOLOR = vec4(tex.rgb * alpha, alpha);
}
