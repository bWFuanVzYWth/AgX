// In practice, there is still debate and confusion around whether sRGB data
// should be displayed with pure 2.2 gamma as defined in the standard,
// or with the inverse of the OETF.
// https://en.wikipedia.org/wiki/SRGB
#define BT709_OETF

#if defined(PURE_GAMMA)
vec3 to_linear(vec3 sRGB) {
    return pow(sRGB, vec3(2.2));
}

vec3 from_linear(vec3 linearRGB) {
    return pow(linearRGB, vec3(1.0 / 2.2));
}

#elif defined(BT709_OETF)
vec3 to_linear(vec3 sRGB) {
    bvec3 cutoff = lessThan(sRGB, vec3(0.04045));
    vec3 higher = pow((sRGB + vec3(0.055)) / vec3(1.055), vec3(2.4));
    vec3 lower = sRGB / vec3(12.92);

    return mix(higher, lower, cutoff);
}

vec3 from_linear(vec3 linearRGB) {
    bvec3 cutoff = lessThan(linearRGB, vec3(0.0031308));
    vec3 higher = vec3(1.055) * pow(linearRGB, vec3(1.0 / 2.4)) - vec3(0.055);
    vec3 lower = linearRGB * vec3(12.92);

    return mix(higher, lower, cutoff);
}

#endif

vec3 saturate(vec3 v) {
    return clamp(v, 0.0, 1.0);
}

vec3 agx_curve3(vec3 v) {
    const float threshold = 0.6060606060606061;
    const float a_up = 69.86278913545539;
    const float a_down = 59.507875;
    const float b_up = 13.0 / 4.0;
    const float b_down = 3.0 / 1.0;
    const float c_up = -4.0 / 13.0;
    const float c_down = -1.0 / 3.0;

    vec3 mask = step(v, vec3(threshold));
    vec3 a = a_up + (a_down - a_up) * mask;
    vec3 b = b_up + (b_down - b_up) * mask;
    vec3 c = c_up + (c_down - c_up) * mask;
    return 0.5 + (((-2.0 * threshold)) + 2.0 * v) * pow(1.0 + a * pow(abs(v - threshold), b), c);
}

vec3 agx_tonemapping(vec3 /*Linear BT.709*/ci) {
    const float min_ev = -12.473931188332413;
    const float max_ev = 4.026068811667588;
    const float dynamic_range = max_ev - min_ev;

    const mat3 agx_mat = mat3(0.8424010709504686, 0.04240107095046854, 0.04240107095046854, 0.07843650156180276, 0.8784365015618028, 0.07843650156180276, 0.0791624274877287, 0.0791624274877287, 0.8791624274877287);
    const mat3 agx_mat_inv = mat3(1.1969986613119143, -0.053001338688085674, -0.053001338688085674, -0.09804562695225345, 1.1519543730477466, -0.09804562695225345, -0.09895303435966087, -0.09895303435966087, 1.151046965640339);

    // Input transform (inset)
    ci = agx_mat * ci;

    // Apply sigmoid function
    vec3 ct = saturate(log2(ci) * (1.0 / dynamic_range) - (min_ev / dynamic_range));
    vec3 co = agx_curve3(ct);

    // Inverse input transform (outset)
    co = agx_mat_inv * co;

    return /*BT.709 (NOT linear)*/co;
}