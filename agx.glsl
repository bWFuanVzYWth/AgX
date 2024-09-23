float agx_curve(float x) {
    if(x >= (20.0 / 33.0))
        return 0.5 + (2.0 * (-(20.0 / 33.0) + x)) / pow(1.0 + 69.86278913545539 * pow(-(20.0 / 33.0) + x, (13.0 / 4.0)), (4.0 / 13.0));
    else
        return 0.5 + (2.0 * (-(20.0 / 33.0) + x)) / pow(1.0 - 59.507875 * pow(-(20.0 / 33.0) + x, (3.0 / 1.0)), (1.0 / 3.0));
}

vec3 agx_curve3(vec3 v){
    return vec3(agx_curve(v.x),agx_curve(v.y),agx_curve(v.z));
}

vec3 agx_tonemapping(vec3 /*Linear BT.709*/val) {
    const mat3 agx_mat = mat3(
        0.842479062253094,   0.0423282422610123, 0.0423756549057051,
        0.0784335999999992,  0.878468636469772,  0.0784336,
        0.0792237451477643,  0.0791661274605434, 0.879142973793104);
    const mat3 agx_mat_inv = mat3(
        1.19687900512017,    -0.0528968517574562, -0.0529716355144438,
        -0.0980208811401368, 1.15190312990417,    -0.0980434501171241,
        -0.0990297440797205, -0.0989611768448433, 1.15107367264116);
    const float min_ev = -12.47393;
    const float max_ev = 4.026069;

    // Input transform (inset)
    val = agx_mat * val;

    // Log2 space encoding
    val = clamp(log2(val) * (1.0 / (max_ev - min_ev)) - (min_ev / (max_ev - min_ev)), vec3(0.0), vec3(1.0));

    // Apply sigmoid function
    vec3 res = agx_curve3(val);

    // Inverse input transform (outset)
    res = agx_mat_inv * res;

    return /*Linear BT.709*/res;
}
