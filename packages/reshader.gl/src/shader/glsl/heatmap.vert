#define SHADER_NAME HEATMAP

float unpack_mix_vec2(const vec2 packedValue, const float t) {
    return mix(packedValue[0], packedValue[1], t);
}
uniform mat4 projViewModelMatrix;
uniform float extrudeScale;
uniform float heatmapIntensity;
uniform vec2 textureOutputSize;
attribute vec3 aPosition;
varying vec2 vExtrude;
#ifdef HAS_HEAT_WEIGHT
    uniform lowp float heatmapWeightT;
    attribute highp vec2 aWeight;
    varying highp float weight;
#else
    uniform highp float heatmapWeight;
#endif
uniform mediump float heatmapRadius;

const highp float ZERO = 1.0 / 255.0 / 16.0;
#define GAUSS_COEF 0.3989422804014327
void main(void) {
    #ifdef HAS_HEAT_WEIGHT
        weight = unpack_mix_vec2(aWeight, heatmapWeightT);
    #else
        highp float weight = heatmapWeight;
    #endif

    mediump float radius = heatmapRadius;

    vec2 unscaledExtrude = vec2(mod(aPosition.xy, 2.0) * 2.0 - 1.0);
    float S = sqrt(-2.0 * log(ZERO / weight / heatmapIntensity / GAUSS_COEF)) / 3.0;
    vExtrude = S * unscaledExtrude;
    vec2 extrude = vExtrude * radius * extrudeScale;
    vec4 pos = vec4(floor(aPosition.xy * 0.5) + extrude, aPosition.z, 1);
    gl_Position = projViewModelMatrix * pos;
}