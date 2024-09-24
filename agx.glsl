vec3 agx_curve3(vec3 v){
    vec3 mask = step(v, vec3(0.0));
    vec3 a = (0.013247155) + (0.007716549 - 0.013247155) * mask;
    vec3 b = (3.0 / 1.0) + (13.0 / 4.0 - 3.0 / 1.0) * mask;
    vec3 c = (-1.0 / 3.0) + (-4.0 / 13.0 + 1.0 / 3.0) * mask;
    return 0.5 + 0.12121212 * v * pow(1.0 + a * pow(abs(v), b), c);
}

vec3 agx_tonemapping(vec3 /*Linear BT.709*/ci) {
    const mat3 agx_mat = mat3(0.84247905, 0.04232824, 0.04237565, 0.07843360, 0.87846863, 0.07843360, 0.07922374, 0.07916613, 0.87914300);
    const mat3 agx_mat_inv = mat3(1.19687903, -0.05289685, -0.05297164, -0.09802088, 1.15190315, -0.09804345, -0.09902974, -0.09896117, 1.15107369);

    // Input transform (inset)
    ci = agx_mat * ci;

    // Apply sigmoid function
    vec3 co = agx_curve3(log2(ci));

    // Inverse input transform (outset)
    co = agx_mat_inv * co;

    return /*Linear BT.709*/co;
}