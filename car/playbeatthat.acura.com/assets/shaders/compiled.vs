{@}PBRTest.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tCarBody;

#!VARYINGS
varying vec4 vMVPosition;

#!SHADER: Vertex

#require(pbr.vs)

void main() {
    setupPBR(position);

    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    vMVPosition = mvPosition;
    gl_Position = projectionMatrix * mvPosition;
}

#!SHADER: Fragment

#require(pbr.fs)
#require(carcommon.fs)

void main() {
    vec3 normal = unpackNormal(vMVPosition.xyz, vNormal, tNormal, 1.0, 1.0, vUv);

    vec4 carBody = texture2D(tCarBody, vUv);
    float reflective = carBody.g;
    float paint = carBody.r;

    vec3 baseColor = texture2D(tBaseColor, vUv).rgb;
    vec3 reflection = getReflection(normal, reflective);
    vec3 lightmap = getLightmap(normal);
    baseColor = mix(baseColor, blendOverlay(baseColor, reflection), 0.5 * reflective);
    baseColor = mix(baseColor, blendOverlay(baseColor, reflection), 0.5 * reflective);

    PBRConfig config;
    config.reflection = 1.0;
    config.darken = 1.0;
    config.clearcoat = paint;
    config.color = vec3(1.0);

    gl_FragColor = getPBR(baseColor, config);
}{@}carpbr.fs{@}uniform sampler2D tBaseColor;
uniform vec2 uEnv;

uniform sampler2D tMRO;
uniform vec3 uMRO;

uniform sampler2D tNormal;
uniform vec2 uNormalScale;

uniform sampler2D tLUT;
uniform sampler2D tEnvDiffuse;
uniform sampler2D tEnvSpecular;
uniform float uHDR;

uniform vec4 uLight;

const float PI = 3.14159265359;
const float PI2 = 6.28318530718;
const float RECIPROCAL_PI = 0.31830988618;
const float RECIPROCAL_PI2 = 0.15915494;
const float LOG2 = 1.442695;
const float EPSILON = 1e-6;
const float LN2 = 0.6931472;

const float ENV_LODS = 7.0;

struct PBRConfig {
    float reflection;
    float darken;
    float clearcoat;
    float shininess;
    vec3 color;
};

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vMPos;

vec4 SRGBtoLinear(vec4 srgb) {
    vec3 linOut = pow(srgb.xyz, vec3(2.2));
    return vec4(linOut, srgb.w);
}

vec4 RGBEToLinear(vec4 value) {
    return vec4(value.rgb * exp2(value.a * 255.0 - 128.0), 1.0);
}

vec4 RGBMToLinear(vec4 value) {
    float maxRange = 6.0;
    return vec4(value.xyz * value.w * maxRange, 1.0);
}

vec4 RGBDToLinear(vec4 value, float maxRange) {
    return vec4(value.rgb * ((maxRange / 255.0) / value.a), 1.0);
}

vec3 linearToSRGB(vec3 color) {
    return pow(color, vec3(1.0 / 2.2));
}

vec3 getNormal(vec2 uNormalScale, sampler2D tNormal /*, sampler tNormalSampler*/, vec2 vUv, vec3 vNormal, vec3 vMPos) {
    vec3 pos_dx = vec3(dFdx(vMPos.x), dFdx(vMPos.y), dFdx(vMPos.z));
    vec3 pos_dy = vec3(dFdy(vMPos.x), dFdy(vMPos.y), dFdy(vMPos.z));
    vec3 tex_dx = vec3(dFdx(vUv.x), dFdx(vUv.y), dFdx(0.0));
    vec3 tex_dy = vec3(dFdy(vUv.x), dFdy(vUv.y), dFdy(0.0));
    vec3 t = (tex_dy.y * pos_dx - tex_dx.y * pos_dy) / (tex_dx.x * tex_dy.y - tex_dy.x * tex_dx.y);

    vec3 ng = normalize(vNormal);

    t = normalize(t - ng * dot(ng, t));
    vec3 b = normalize(cross(ng, t));
    mat3 tbn = mat3(t, b, ng);

    vec3 n = texture2D(tNormal, vUv * uNormalScale.y).rgb;
    n = normalize(tbn * ((2.0 * n - 1.0) * vec3(uNormalScale.x, uNormalScale.x, 1.0)));

    return n;
}

vec3 specularReflection(vec3 specularEnvR0, vec3 specularEnvR90, float VdH) {
    return specularEnvR0 + (specularEnvR90 - specularEnvR0) * pow(clamp(1.0 - VdH, 0.0, 1.0), 5.0);
}

float geometricOcclusion(float NdL, float NdV, float roughness) {
    float r = roughness;
    float attenuationL = 2.0 * NdL / (NdL + sqrt(r * r + (1.0 - r * r) * (NdL * NdL)));
    float attenuationV = 2.0 * NdV / (NdV + sqrt(r * r + (1.0 - r * r) * (NdV * NdV)));
    return attenuationL * attenuationV;
}

float microfacetDistribution(float roughness, float NdH) {
    float roughnessSq = roughness * roughness;
    float f = (NdH * roughnessSq - NdH) * NdH + 1.0;
    return roughnessSq / (PI * f * f);
}

vec3 inverseTformDir(in vec3 dir, in mat4 matrix) {
    return normalize((vec4(dir, 0.0) * matrix).xyz);
}

float prange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

float pcrange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    return clamp(prange(oldValue, oldMin, oldMax, newMin, newMax), min(newMax, newMin), max(newMin, newMax));
}

vec2 cartesianToPolar(vec3 n, vec3 vMPos, vec3 cameraPosition, mat4 viewMatrix) {
    vec3 cameraToVertex = normalize(vMPos - cameraPosition);
    vec3 worldNormal = inverseTformDir(normalize(n), viewMatrix);
    vec3 reflectVec = normalize(reflect(cameraToVertex, worldNormal));
    vec3 reflectView = normalize((viewMatrix * vec4( reflectVec, 0.0)).xyz + vec3(0.0, 0.0, 1.0));
    return reflectView.xy * 0.5 + 0.5;
}

vec4 autoToLinear(vec4 texel, float uHDR) {
    vec4 rgbm = RGBMToLinear(texel);
    vec4 srgb = SRGBtoLinear(texel);
    return mix(srgb, rgbm, uHDR);
}

vec3 getIBLContribution(float NdV, float roughness, vec3 n, vec3 reflection, vec3 diffuseColor, vec3 specularColor, PBRConfig config, vec3 cameraPosition, mat4 viewMatrix, vec2 vUv, vec3 vMPos, vec2 uEnv, float uHDR, sampler2D tLUT, /*sampler tLUTSampler,*/ sampler2D tEnvDiffuse, /*sampler tEnvDiffuseSampler,*/ sampler2D tEnvSpecular /*, sampler tEnvSpecularSampler*/) {
    vec2 lutUV = vec2(NdV, roughness);
    vec2 diffuseUV = cartesianToPolar(n, vMPos, cameraPosition, viewMatrix);

    #test !!window.Metal
    lutUV.y = 1.0 - lutUV.y;
    diffuseUV.y = 1.0 - diffuseUV.y;
    #endtest

    vec3 brdf = SRGBtoLinear(texture2D(tLUT, lutUV)).rgb;
    vec3 diffuseLight = autoToLinear( texture2D(tEnvDiffuse, diffuseUV ), uHDR).rgb;

    // Sample 2 levels and mix between to get smoother degradation
    float blend = roughness * ENV_LODS;
    float level0 = floor(blend);
    float level1 = min(ENV_LODS, level0 + 1.0);
    blend -= level0;

    // Sample the specular env map atlas depending on the roughness value
    vec2 uvSpec = diffuseUV;
    uvSpec.y /= 2.0;

    vec2 uv0 = uvSpec;
    vec2 uv1 = uvSpec;

    uv0 /= pow(2.0, level0);
    uv0.y += 1.0 - exp(-LN2 * level0);

    uv1 /= pow(2.0, level1);
    uv1.y += 1.0 - exp(-LN2 * level1);

    #test !!window.Metal
    uv0.y = 1.0 - uv0.y;
    uv1.y = 1.0 - uv1.y;
    #endtest

    vec3 specular0 = autoToLinear(texture2D(tEnvSpecular, uv0), uHDR).rgb;
    vec3 specular1 = autoToLinear(texture2D(tEnvSpecular, uv1), uHDR).rgb;
    vec2 matcap = reflectMatcap(vMVPosition, n);
    vec3 envReflection = SRGBtoLinear(texture2D(tMatcap, matcap)).rgb * 0.1 * uEnvReflection * config.shininess;
    vec3 specularLight = mix(specular0, specular1, blend);

    vec3 diffuse = diffuseLight * diffuseColor;
    vec3 specular = specularLight * (specularColor * brdf.x + brdf.y);

    // A value to be able to push the strength and mimic HDR
    specular *= (1.0 + uEnv.y * specularLight);
    return diffuse + specular + envReflection;
}

vec3 calculatePBR(vec3 baseColor, PBRConfig config, vec3 cameraPosition, mat4 viewMatrix, vec2 vUv, vec3 vNormal, vec3 vMPos, vec2 uEnv, vec3 uMRO, vec2 uNormalScale, float uHDR, vec4 uLight, sampler2D tMRO, /*sampler tMROSampler,*/ sampler2D tNormal, /*sampler tNormalSampler,*/ sampler2D tLUT, /*sampler tLUTSampler,*/ sampler2D tEnvDiffuse, /*sampler tEnvDiffuseSampler,*/ sampler2D tEnvSpecular /*, sampler tEnvSpecularSampler*/) {
    // rgb = [metallic, roughness, occlusion] - still have a available
    vec4 mroSample = texture2D(tMRO, vUv);
    float metallic = clamp(mroSample.r * uMRO.x, 0.04, 1.0);
    float roughness = clamp(mroSample.g * uMRO.y, 0.04, 1.0);
    roughness *= (1.0 - config.clearcoat);
    metallic += config.clearcoat * 0.5;

    vec3 diffuseColor = baseColor * 0.96 * (1.0 - metallic);
    vec3 specularColor = mix(vec3(0.04), baseColor, metallic);

    float reflectance = max(max(specularColor.r, specularColor.g), specularColor.b);
    float reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);
    vec3 specularEnvR0 = specularColor.rgb;
    vec3 specularEnvR90 = vec3(reflectance90);

    vec3 N = getNormal(uNormalScale, tNormal, vUv, vNormal, vMPos);
    vec3 V = normalize(cameraPosition - vMPos);
    vec3 L = normalize(uLight.xyz);
    vec3 H = normalize(L + V);
    vec3 reflection = -normalize(reflect(V, N));

    float NdL = pcrange(clamp(dot(N, L), 0.001, 1.0), 0.0, 1.0, 0.4, 1.0);
    float NdV = pcrange(clamp(abs(dot(N, V)), 0.001, 1.0), 0.0, 1.0, 0.4, 1.0);
    float NdH = clamp(dot(N, H), 0.0, 1.0);
    //    float LdH = clamp(dot(L, H), 0.0, 1.0);
    float VdH = clamp(dot(V, H), 0.0, 1.0);

    vec3 F = specularReflection(specularEnvR0, specularEnvR90, VdH);
    float G = geometricOcclusion(NdL, NdV, roughness);
    float D = microfacetDistribution(roughness, NdH);

    vec3 diffuseContrib = (1.0 - F) * (diffuseColor / PI);
    vec3 specContrib = F * G * D / (4.0 * NdL * NdV) * uLight.w;
    vec3 color = NdL * (diffuseContrib + specContrib) * config.darken;

    color = getIBLContribution(NdV, roughness, N, reflection, diffuseColor, specularColor, config, cameraPosition, viewMatrix, vUv, vMPos, uEnv, uHDR, tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/) * config.color * uEnv.x;

    return mix(color, color * mroSample.b, uMRO.z);
}

vec4 getPBR() {
    PBRConfig config;
    config.reflection = 1.0;
    config.darken = 1.0;
    config.color = vec3(1.0);

    vec4 baseColor = SRGBtoLinear(texture2D(tBaseColor, vUv));
    vec3 color = calculatePBR(baseColor.rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), baseColor.a);
}

vec4 getPBR(PBRConfig config) {
    vec4 baseColor = SRGBtoLinear(texture2D(tBaseColor, vUv));
    vec3 color = calculatePBR(baseColor.rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), baseColor.a);
}

vec4 getPBR(vec3 inputColor) {
    PBRConfig config;
    config.reflection = 1.0;
    config.darken = 1.0;
    config.color = vec3(1.0);

    vec3 color = calculatePBR(SRGBtoLinear(vec4(inputColor, 1.0)).rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), 1.0);
}

vec4 getPBR(vec3 inputColor, PBRConfig config) {
    vec3 color = calculatePBR(SRGBtoLinear(vec4(inputColor, 1.0)).rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), 1.0);
}{@}GhostNormal.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tNormal;

#!VARYINGS
varying vec3 vNormal;
varying vec3 vMVPos;
varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * mvPosition;

    vUv = uv;
    vNormal = normalMatrix * normal;
    vMVPos = mvPosition.xyz;
}

#!SHADER: Fragment

#require(range.glsl)
#require(fresnel.glsl)
#require(normalmap.glsl)

void main() {
    vec3 normal = unpackNormal(vMVPos, vNormal, tNormal, 1.0, 1.0, vUv);
    float f = getFresnel(normal, -vMVPos, 1.0);
    gl_FragColor = vec4(f, 1.0, normal.xy);
}{@}carcommon.fs{@}uniform sampler2D tMatcap;
//uniform sampler2D tCarBody;
//uniform sampler2D tLightmap;
uniform sampler2D tLookup;
uniform vec4 uEnvRotation;
uniform vec3 uClearCoat;
uniform vec3 uColor;
uniform float uEnvReflection;

#require(blendmodes.glsl)
#require(matcap.vs)
#require(normalmap.glsl)
#require(rotation.glsl)
#require(carpbr.fs)
#require(lut.fs){@}PBRAsphalt.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    setupLight(position, normal);
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(shadows.fs)
#require(lighting.fs)

void main() {
    vec3 pbr = getPBR().rgb;
    pbr *= getShadow(vPos);
    
    LightConfig config;
    pbr *= getCombinedColor();

    gl_FragColor = vec4(pbr, 1.0);
}{@}GreyRoad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_FragColor = color;
}{@}TestingNormals.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normalize(normal);
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec3 normalColor = vNormal.xyz;
    vec4 color = vec4(normalColor, 1.0);
    gl_FragColor = color;
}{@}AntimatterCopy.fs{@}uniform sampler2D tDiffuse;

varying vec2 vUv;

void main() {
    gl_FragColor = texture2D(tDiffuse, vUv);
}{@}AntimatterCopy.vs{@}varying vec2 vUv;
void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}{@}AntimatterPass.vs{@}varying vec2 vUv;

void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}{@}AntimatterPosition.vs{@}uniform sampler2D tPos;

void main() {
    vec4 decodedPos = texture2D(tPos, position.xy);
    vec3 pos = decodedPos.xyz;

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    gl_PointSize = 0.02 * (1000.0 / length(mvPosition.xyz));
    gl_Position = projectionMatrix * mvPosition;
}{@}AntimatterBasicFrag.fs{@}void main() {
    gl_FragColor = vec4(1.0);
}{@}antimatter.glsl{@}vec3 getData(sampler2D tex, vec2 uv) {
    return texture2D(tex, uv).xyz;
}

vec4 getData4(sampler2D tex, vec2 uv) {
    return texture2D(tex, uv);
}

{@}blendmodes.glsl{@}float blendColorDodge(float base, float blend) {
    return (blend == 1.0)?blend:min(base/(1.0-blend), 1.0);
}
vec3 blendColorDodge(vec3 base, vec3 blend) {
    return vec3(blendColorDodge(base.r, blend.r), blendColorDodge(base.g, blend.g), blendColorDodge(base.b, blend.b));
}
vec3 blendColorDodge(vec3 base, vec3 blend, float opacity) {
    return (blendColorDodge(base, blend) * opacity + base * (1.0 - opacity));
}
float blendColorBurn(float base, float blend) {
    return (blend == 0.0)?blend:max((1.0-((1.0-base)/blend)), 0.0);
}
vec3 blendColorBurn(vec3 base, vec3 blend) {
    return vec3(blendColorBurn(base.r, blend.r), blendColorBurn(base.g, blend.g), blendColorBurn(base.b, blend.b));
}
vec3 blendColorBurn(vec3 base, vec3 blend, float opacity) {
    return (blendColorBurn(base, blend) * opacity + base * (1.0 - opacity));
}
float blendVividLight(float base, float blend) {
    return (blend<0.5)?blendColorBurn(base, (2.0*blend)):blendColorDodge(base, (2.0*(blend-0.5)));
}
vec3 blendVividLight(vec3 base, vec3 blend) {
    return vec3(blendVividLight(base.r, blend.r), blendVividLight(base.g, blend.g), blendVividLight(base.b, blend.b));
}
vec3 blendVividLight(vec3 base, vec3 blend, float opacity) {
    return (blendVividLight(base, blend) * opacity + base * (1.0 - opacity));
}
float blendHardMix(float base, float blend) {
    return (blendVividLight(base, blend)<0.5)?0.0:1.0;
}
vec3 blendHardMix(vec3 base, vec3 blend) {
    return vec3(blendHardMix(base.r, blend.r), blendHardMix(base.g, blend.g), blendHardMix(base.b, blend.b));
}
vec3 blendHardMix(vec3 base, vec3 blend, float opacity) {
    return (blendHardMix(base, blend) * opacity + base * (1.0 - opacity));
}
float blendLinearDodge(float base, float blend) {
    return min(base+blend, 1.0);
}
vec3 blendLinearDodge(vec3 base, vec3 blend) {
    return min(base+blend, vec3(1.0));
}
vec3 blendLinearDodge(vec3 base, vec3 blend, float opacity) {
    return (blendLinearDodge(base, blend) * opacity + base * (1.0 - opacity));
}
float blendLinearBurn(float base, float blend) {
    return max(base+blend-1.0, 0.0);
}
vec3 blendLinearBurn(vec3 base, vec3 blend) {
    return max(base+blend-vec3(1.0), vec3(0.0));
}
vec3 blendLinearBurn(vec3 base, vec3 blend, float opacity) {
    return (blendLinearBurn(base, blend) * opacity + base * (1.0 - opacity));
}
float blendLinearLight(float base, float blend) {
    return blend<0.5?blendLinearBurn(base, (2.0*blend)):blendLinearDodge(base, (2.0*(blend-0.5)));
}
vec3 blendLinearLight(vec3 base, vec3 blend) {
    return vec3(blendLinearLight(base.r, blend.r), blendLinearLight(base.g, blend.g), blendLinearLight(base.b, blend.b));
}
vec3 blendLinearLight(vec3 base, vec3 blend, float opacity) {
    return (blendLinearLight(base, blend) * opacity + base * (1.0 - opacity));
}
float blendLighten(float base, float blend) {
    return max(blend, base);
}
vec3 blendLighten(vec3 base, vec3 blend) {
    return vec3(blendLighten(base.r, blend.r), blendLighten(base.g, blend.g), blendLighten(base.b, blend.b));
}
vec3 blendLighten(vec3 base, vec3 blend, float opacity) {
    return (blendLighten(base, blend) * opacity + base * (1.0 - opacity));
}
float blendDarken(float base, float blend) {
    return min(blend, base);
}
vec3 blendDarken(vec3 base, vec3 blend) {
    return vec3(blendDarken(base.r, blend.r), blendDarken(base.g, blend.g), blendDarken(base.b, blend.b));
}
vec3 blendDarken(vec3 base, vec3 blend, float opacity) {
    return (blendDarken(base, blend) * opacity + base * (1.0 - opacity));
}
float blendPinLight(float base, float blend) {
    return (blend<0.5)?blendDarken(base, (2.0*blend)):blendLighten(base, (2.0*(blend-0.5)));
}
vec3 blendPinLight(vec3 base, vec3 blend) {
    return vec3(blendPinLight(base.r, blend.r), blendPinLight(base.g, blend.g), blendPinLight(base.b, blend.b));
}
vec3 blendPinLight(vec3 base, vec3 blend, float opacity) {
    return (blendPinLight(base, blend) * opacity + base * (1.0 - opacity));
}
float blendReflect(float base, float blend) {
    return (blend == 1.0)?blend:min(base*base/(1.0-blend), 1.0);
}
vec3 blendReflect(vec3 base, vec3 blend) {
    return vec3(blendReflect(base.r, blend.r), blendReflect(base.g, blend.g), blendReflect(base.b, blend.b));
}
vec3 blendReflect(vec3 base, vec3 blend, float opacity) {
    return (blendReflect(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendGlow(vec3 base, vec3 blend) {
    return blendReflect(blend, base);
}
vec3 blendGlow(vec3 base, vec3 blend, float opacity) {
    return (blendGlow(base, blend) * opacity + base * (1.0 - opacity));
}
float blendOverlay(float base, float blend) {
    return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}
vec3 blendOverlay(vec3 base, vec3 blend) {
    return vec3(blendOverlay(base.r, blend.r), blendOverlay(base.g, blend.g), blendOverlay(base.b, blend.b));
}
vec3 blendOverlay(vec3 base, vec3 blend, float opacity) {
    return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendHardLight(vec3 base, vec3 blend) {
    return blendOverlay(blend, base);
}
vec3 blendHardLight(vec3 base, vec3 blend, float opacity) {
    return (blendHardLight(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendPhoenix(vec3 base, vec3 blend) {
    return min(base, blend)-max(base, blend)+vec3(1.0);
}
vec3 blendPhoenix(vec3 base, vec3 blend, float opacity) {
    return (blendPhoenix(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendNormal(vec3 base, vec3 blend) {
    return blend;
}
vec3 blendNormal(vec3 base, vec3 blend, float opacity) {
    return (blendNormal(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendNegation(vec3 base, vec3 blend) {
    return vec3(1.0)-abs(vec3(1.0)-base-blend);
}
vec3 blendNegation(vec3 base, vec3 blend, float opacity) {
    return (blendNegation(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendMultiply(vec3 base, vec3 blend) {
    return base*blend;
}
vec3 blendMultiply(vec3 base, vec3 blend, float opacity) {
    return (blendMultiply(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendAverage(vec3 base, vec3 blend) {
    return (base+blend)/2.0;
}
vec3 blendAverage(vec3 base, vec3 blend, float opacity) {
    return (blendAverage(base, blend) * opacity + base * (1.0 - opacity));
}
float blendScreen(float base, float blend) {
    return 1.0-((1.0-base)*(1.0-blend));
}
vec3 blendScreen(vec3 base, vec3 blend) {
    return vec3(blendScreen(base.r, blend.r), blendScreen(base.g, blend.g), blendScreen(base.b, blend.b));
}
vec3 blendScreen(vec3 base, vec3 blend, float opacity) {
    return (blendScreen(base, blend) * opacity + base * (1.0 - opacity));
}
float blendSoftLight(float base, float blend) {
    return (blend<0.5)?(2.0*base*blend+base*base*(1.0-2.0*blend)):(sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend));
}
vec3 blendSoftLight(vec3 base, vec3 blend) {
    return vec3(blendSoftLight(base.r, blend.r), blendSoftLight(base.g, blend.g), blendSoftLight(base.b, blend.b));
}
vec3 blendSoftLight(vec3 base, vec3 blend, float opacity) {
    return (blendSoftLight(base, blend) * opacity + base * (1.0 - opacity));
}
float blendSubtract(float base, float blend) {
    return max(base+blend-1.0, 0.0);
}
vec3 blendSubtract(vec3 base, vec3 blend) {
    return max(base+blend-vec3(1.0), vec3(0.0));
}
vec3 blendSubtract(vec3 base, vec3 blend, float opacity) {
    return (blendSubtract(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendExclusion(vec3 base, vec3 blend) {
    return base+blend-2.0*base*blend;
}
vec3 blendExclusion(vec3 base, vec3 blend, float opacity) {
    return (blendExclusion(base, blend) * opacity + base * (1.0 - opacity));
}
vec3 blendDifference(vec3 base, vec3 blend) {
    return abs(base-blend);
}
vec3 blendDifference(vec3 base, vec3 blend, float opacity) {
    return (blendDifference(base, blend) * opacity + base * (1.0 - opacity));
}
float blendAdd(float base, float blend) {
    return min(base+blend, 1.0);
}
vec3 blendAdd(vec3 base, vec3 blend) {
    return min(base+blend, vec3(1.0));
}
vec3 blendAdd(vec3 base, vec3 blend, float opacity) {
    return (blendAdd(base, blend) * opacity + base * (1.0 - opacity));
}{@}conditionals.glsl{@}vec4 when_eq(vec4 x, vec4 y) {
  return 1.0 - abs(sign(x - y));
}

vec4 when_neq(vec4 x, vec4 y) {
  return abs(sign(x - y));
}

vec4 when_gt(vec4 x, vec4 y) {
  return max(sign(x - y), 0.0);
}

vec4 when_lt(vec4 x, vec4 y) {
  return max(sign(y - x), 0.0);
}

vec4 when_ge(vec4 x, vec4 y) {
  return 1.0 - when_lt(x, y);
}

vec4 when_le(vec4 x, vec4 y) {
  return 1.0 - when_gt(x, y);
}

vec3 when_eq(vec3 x, vec3 y) {
  return 1.0 - abs(sign(x - y));
}

vec3 when_neq(vec3 x, vec3 y) {
  return abs(sign(x - y));
}

vec3 when_gt(vec3 x, vec3 y) {
  return max(sign(x - y), 0.0);
}

vec3 when_lt(vec3 x, vec3 y) {
  return max(sign(y - x), 0.0);
}

vec3 when_ge(vec3 x, vec3 y) {
  return 1.0 - when_lt(x, y);
}

vec3 when_le(vec3 x, vec3 y) {
  return 1.0 - when_gt(x, y);
}

vec2 when_eq(vec2 x, vec2 y) {
  return 1.0 - abs(sign(x - y));
}

vec2 when_neq(vec2 x, vec2 y) {
  return abs(sign(x - y));
}

vec2 when_gt(vec2 x, vec2 y) {
  return max(sign(x - y), 0.0);
}

vec2 when_lt(vec2 x, vec2 y) {
  return max(sign(y - x), 0.0);
}

vec2 when_ge(vec2 x, vec2 y) {
  return 1.0 - when_lt(x, y);
}

vec2 when_le(vec2 x, vec2 y) {
  return 1.0 - when_gt(x, y);
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

float when_neq(float x, float y) {
  return abs(sign(x - y));
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

float when_ge(float x, float y) {
  return 1.0 - when_lt(x, y);
}

float when_le(float x, float y) {
  return 1.0 - when_gt(x, y);
}

vec4 and(vec4 a, vec4 b) {
  return a * b;
}

vec4 or(vec4 a, vec4 b) {
  return min(a + b, 1.0);
}

vec4 Not(vec4 a) {
  return 1.0 - a;
}

vec3 and(vec3 a, vec3 b) {
  return a * b;
}

vec3 or(vec3 a, vec3 b) {
  return min(a + b, 1.0);
}

vec3 Not(vec3 a) {
  return 1.0 - a;
}

vec2 and(vec2 a, vec2 b) {
  return a * b;
}

vec2 or(vec2 a, vec2 b) {
  return min(a + b, 1.0);
}


vec2 Not(vec2 a) {
  return 1.0 - a;
}

float and(float a, float b) {
  return a * b;
}

float or(float a, float b) {
  return min(a + b, 1.0);
}

float Not(float a) {
  return 1.0 - a;
}{@}curl.glsl{@}float CNrange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

float CNnoise(vec3 v) {
    float t = v.z * 0.3;
    v.y *= 0.8;
    float noise = 0.0;
    float s = 0.5;
    noise += CNrange(sin(v.x * 0.9 / s + t * 10.0) + sin(v.x * 2.4 / s + t * 15.0) + sin(v.x * -3.5 / s + t * 4.0) + sin(v.x * -2.5 / s + t * 7.1), -1.0, 1.0, -0.3, 0.3);
    noise += CNrange(sin(v.y * -0.3 / s + t * 18.0) + sin(v.y * 1.6 / s + t * 18.0) + sin(v.y * 2.6 / s + t * 8.0) + sin(v.y * -2.6 / s + t * 4.5), -1.0, 1.0, -0.3, 0.3);
    return noise;
}

vec3 snoiseVec3( vec3 x ){
    
    float s  = CNnoise(vec3( x ));
    float s1 = CNnoise(vec3( x.y - 19.1 , x.z + 33.4 , x.x + 47.2 ));
    float s2 = CNnoise(vec3( x.z + 74.2 , x.x - 124.5 , x.y + 99.4 ));
    vec3 c = vec3( s , s1 , s2 );
    return c;
    
}

vec3 curlNoise( vec3 p ){
    
    const float e = 1e-1;
    vec3 dx = vec3( e   , 0.0 , 0.0 );
    vec3 dy = vec3( 0.0 , e   , 0.0 );
    vec3 dz = vec3( 0.0 , 0.0 , e   );
    
    vec3 p_x0 = snoiseVec3( p - dx );
    vec3 p_x1 = snoiseVec3( p + dx );
    vec3 p_y0 = snoiseVec3( p - dy );
    vec3 p_y1 = snoiseVec3( p + dy );
    vec3 p_z0 = snoiseVec3( p - dz );
    vec3 p_z1 = snoiseVec3( p + dz );
    
    float x = p_y1.z - p_y0.z - p_z1.y + p_z0.y;
    float y = p_z1.x - p_z0.x - p_x1.z + p_x0.z;
    float z = p_x1.y - p_x0.y - p_y1.x + p_y0.x;
    
    const float divisor = 1.0 / ( 2.0 * e );
    return normalize( vec3( x , y , z ) * divisor );
}{@}depthvalue.fs{@}float getDepthValue(sampler2D tDepth, vec2 uv, float n, float f) {
    vec4 depth = texture2D(tDepth, uv);
    return (2.0 * n) / (f + n - depth.x * (f - n));
}{@}eases.glsl{@}#ifndef PI
#define PI 3.141592653589793
#endif

#ifndef HALF_PI
#define HALF_PI 1.5707963267948966
#endif

float backInOut(float t) {
  float f = t < 0.5
    ? 2.0 * t
    : 1.0 - (2.0 * t - 1.0);

  float g = pow(f, 3.0) - f * sin(f * PI);

  return t < 0.5
    ? 0.5 * g
    : 0.5 * (1.0 - g) + 0.5;
}

float backIn(float t) {
  return pow(t, 3.0) - t * sin(t * PI);
}

float backOut(float t) {
  float f = 1.0 - t;
  return 1.0 - (pow(f, 3.0) - f * sin(f * PI));
}

float bounceOut(float t) {
  const float a = 4.0 / 11.0;
  const float b = 8.0 / 11.0;
  const float c = 9.0 / 10.0;

  const float ca = 4356.0 / 361.0;
  const float cb = 35442.0 / 1805.0;
  const float cc = 16061.0 / 1805.0;

  float t2 = t * t;

  return t < a
    ? 7.5625 * t2
    : t < b
      ? 9.075 * t2 - 9.9 * t + 3.4
      : t < c
        ? ca * t2 - cb * t + cc
        : 10.8 * t * t - 20.52 * t + 10.72;
}

float bounceIn(float t) {
  return 1.0 - bounceOut(1.0 - t);
}

float bounceInOut(float t) {
  return t < 0.5
    ? 0.5 * (1.0 - bounceOut(1.0 - t * 2.0))
    : 0.5 * bounceOut(t * 2.0 - 1.0) + 0.5;
}

float circularInOut(float t) {
  return t < 0.5
    ? 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t))
    : 0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0);
}

float circularIn(float t) {
  return 1.0 - sqrt(1.0 - t * t);
}

float circularOut(float t) {
  return sqrt((2.0 - t) * t);
}

float cubicInOut(float t) {
  return t < 0.5
    ? 4.0 * t * t * t
    : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

float cubicIn(float t) {
  return t * t * t;
}

float cubicOut(float t) {
  float f = t - 1.0;
  return f * f * f + 1.0;
}

float elasticInOut(float t) {
  return t < 0.5
    ? 0.5 * sin(+13.0 * HALF_PI * 2.0 * t) * pow(2.0, 10.0 * (2.0 * t - 1.0))
    : 0.5 * sin(-13.0 * HALF_PI * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 1.0;
}

float elasticIn(float t) {
  return sin(13.0 * t * HALF_PI) * pow(2.0, 10.0 * (t - 1.0));
}

float elasticOut(float t) {
  return sin(-13.0 * (t + 1.0) * HALF_PI) * pow(2.0, -10.0 * t) + 1.0;
}

float expoInOut(float t) {
  return t == 0.0 || t == 1.0
    ? t
    : t < 0.5
      ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
      : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}

float expoIn(float t) {
  return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

float expoOut(float t) {
  return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

float linear(float t) {
  return t;
}

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float quadraticIn(float t) {
  return t * t;
}

float quadraticOut(float t) {
  return -t * (t - 2.0);
}

float quarticInOut(float t) {
  return t < 0.5
    ? +8.0 * pow(t, 4.0)
    : -8.0 * pow(t - 1.0, 4.0) + 1.0;
}

float quarticIn(float t) {
  return pow(t, 4.0);
}

float quarticOut(float t) {
  return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
}

float qinticInOut(float t) {
  return t < 0.5
    ? +16.0 * pow(t, 5.0)
    : -0.5 * pow(2.0 * t - 2.0, 5.0) + 1.0;
}

float qinticIn(float t) {
  return pow(t, 5.0);
}

float qinticOut(float t) {
  return 1.0 - (pow(t - 1.0, 5.0));
}

float sineInOut(float t) {
  return -0.5 * (cos(PI * t) - 1.0);
}

float sineIn(float t) {
  return sin((t - 1.0) * HALF_PI) + 1.0;
}

float sineOut(float t) {
  return sin(t * HALF_PI);
}
{@}ColorMaterial.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 color;

#!VARYINGS

#!SHADER: ColorMaterial.vs
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: ColorMaterial.fs
void main() {
    gl_FragColor = vec4(color, 1.0);
}{@}DebugCamera.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;

#!VARYINGS
varying vec3 vColor;

#!SHADER: DebugCamera.vs
void main() {
    vColor = mix(uColor, vec3(1.0, 0.0, 0.0), step(position.z, -0.1));
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: DebugCamera.fs
void main() {
    gl_FragColor = vec4(vColor, 1.0);
}{@}ScreenQuad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;

#!SHADER: ScreenQuad.vs
void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}

#!SHADER: ScreenQuad.fs
void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.a = 1.0;
}{@}TestMaterial.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform float alpha;

#!VARYINGS
varying vec3 vNormal;

#!SHADER: TestMaterial.vs
void main() {
    vec3 pos = position;
    vNormal = normalMatrix * normal;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: TestMaterial.fs
void main() {
    gl_FragColor = vec4(vNormal, 1.0);
}{@}TextureMaterial.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;

#!SHADER: TextureMaterial.vs
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: TextureMaterial.fs
void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.rgb /= gl_FragColor.a;
}{@}BlitPass.fs{@}void main() {
    gl_FragColor = texture2D(tDiffuse, vUv);
    gl_FragColor.a = 1.0;
}{@}NukePass.vs{@}varying vec2 vUv;

void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}{@}ShadowDepth.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: ShadowDepth.vs
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: ShadowDepth.fs
void main() {
    gl_FragColor = vec4(vec3(gl_FragCoord.z), 1.0);
}{@}instance.vs{@}vec3 transformNormal(vec3 n, vec4 orientation) {
    vec3 nn = n + 2.0 * cross(orientation.xyz, cross(orientation.xyz, n) + orientation.w * n);
    return nn;
}

vec3 transformPosition(vec3 position, vec3 offset, vec3 scale, vec4 orientation) {
    vec3 pos = position;
    pos *= scale;

    pos = pos + 2.0 * cross(orientation.xyz, cross(orientation.xyz, pos) + orientation.w * pos);
    pos += offset;
    return pos;
}

vec3 transformPosition(vec3 position, vec3 offset, vec4 orientation) {
    vec3 pos = position;

    pos = pos + 2.0 * cross(orientation.xyz, cross(orientation.xyz, pos) + orientation.w * pos);
    pos += offset;
    return pos;
}

vec3 transformPosition(vec3 position, vec3 offset, float scale, vec4 orientation) {
    return transformPosition(position, offset, vec3(scale), orientation);
}

vec3 transformPosition(vec3 position, vec3 offset) {
    return position + offset;
}

vec3 transformPosition(vec3 position, vec3 offset, float scale) {
    vec3 pos = position * scale;
    return pos + offset;
}

vec3 transformPosition(vec3 position, vec3 offset, vec3 scale) {
    vec3 pos = position * scale;
    return pos + offset;
}{@}lights.fs{@}vec3 worldLight(vec3 pos, vec3 vpos) {
    vec4 mvPos = modelViewMatrix * vec4(vpos, 1.0);
    vec4 worldPosition = viewMatrix * vec4(pos, 1.0);
    return worldPosition.xyz - mvPos.xyz;
}{@}lights.vs{@}vec3 worldLight(vec3 pos) {
    vec4 mvPos = modelViewMatrix * vec4(position, 1.0);
    vec4 worldPosition = viewMatrix * vec4(pos, 1.0);
    return worldPosition.xyz - mvPos.xyz;
}

vec3 worldLight(vec3 lightPos, vec3 localPos) {
    vec4 mvPos = modelViewMatrix * vec4(localPos, 1.0);
    vec4 worldPosition = viewMatrix * vec4(lightPos, 1.0);
    return worldPosition.xyz - mvPos.xyz;
}{@}shadows.fs{@}float shadowCompare(sampler2D map, vec2 coords, float compare) {
    return step(compare, texture2D(map, coords).r);
}

float shadowLerp(sampler2D map, vec2 coords, float compare, float size) {
    const vec2 offset = vec2(0.0, 1.0);

    vec2 texelSize = vec2(1.0) / size;
    vec2 centroidUV = floor(coords * size + 0.5) / size;

    float lb = shadowCompare(map, centroidUV + texelSize * offset.xx, compare);
    float lt = shadowCompare(map, centroidUV + texelSize * offset.xy, compare);
    float rb = shadowCompare(map, centroidUV + texelSize * offset.yx, compare);
    float rt = shadowCompare(map, centroidUV + texelSize * offset.yy, compare);

    vec2 f = fract( coords * size + 0.5 );

    float a = mix( lb, lt, f.y );
    float b = mix( rb, rt, f.y );
    float c = mix( a, b, f.x );

    return c;
}

float srange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

float shadowrandom(vec3 vin) {
    vec3 v = vin * 0.1;
    float t = v.z * 0.3;
    v.y *= 0.8;
    float noise = 0.0;
    float s = 0.5;
    noise += srange(sin(v.x * 0.9 / s + t * 10.0) + sin(v.x * 2.4 / s + t * 15.0) + sin(v.x * -3.5 / s + t * 4.0) + sin(v.x * -2.5 / s + t * 7.1), -1.0, 1.0, -0.3, 0.3);
    noise += srange(sin(v.y * -0.3 / s + t * 18.0) + sin(v.y * 1.6 / s + t * 18.0) + sin(v.y * 2.6 / s + t * 8.0) + sin(v.y * -2.6 / s + t * 4.5), -1.0, 1.0, -0.3, 0.3);
    return noise;
}

float shadowLookup(sampler2D map, vec3 coords, float size, float compare, vec3 wpos) {
    float shadow = 1.0;

    #if defined(SHADOW_MAPS)
    bvec4 inFrustumVec = bvec4 (coords.x >= 0.0, coords.x <= 1.0, coords.y >= 0.0, coords.y <= 1.0);
    bool inFrustum = all(inFrustumVec);
    bvec2 frustumTestVec = bvec2(inFrustum, coords.z <= 1.0);
    bool frustumTest = all(frustumTestVec);

    if (frustumTest) {
        vec2 texelSize = vec2(1.0) / size;

        float dx0 = -texelSize.x;
        float dy0 = -texelSize.y;
        float dx1 = +texelSize.x;
        float dy1 = +texelSize.y;

        float rnoise = shadowrandom(wpos) * 0.0015;
        dx0 += rnoise;
        dy0 -= rnoise;
        dx1 += rnoise;
        dy1 -= rnoise;

        #if defined(SHADOWS_MED)
        shadow += shadowCompare(map, coords.xy + vec2(0.0, dy0), compare);
//        shadow += shadowCompare(map, coords.xy + vec2(dx1, dy0), compare);
        shadow += shadowCompare(map, coords.xy + vec2(dx0, 0.0), compare);
        shadow += shadowCompare(map, coords.xy, compare);
        shadow += shadowCompare(map, coords.xy + vec2(dx1, 0.0), compare);
//        shadow += shadowCompare(map, coords.xy + vec2(dx0, dy1), compare);
        shadow += shadowCompare(map, coords.xy + vec2(0.0, dy1), compare);
        shadow /= 5.0;

        #elif defined(SHADOWS_HIGH)
        shadow = shadowLerp(map, coords.xy + vec2(dx0, dy0), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(0.0, dy0), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(dx1, dy0), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(dx0, 0.0), compare, size);
        shadow += shadowLerp(map, coords.xy, compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(dx1, 0.0), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(dx0, dy1), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(0.0, dy1), compare, size);
        shadow += shadowLerp(map, coords.xy + vec2(dx1, dy1), compare, size);
        shadow /= 9.0;

        #else
        shadow = shadowCompare(map, coords.xy, compare);
        #endif
    }

    #endif

    return clamp(shadow, 0.0, 1.0);
}

vec3 transformShadowLight(vec3 pos, vec3 vpos) {
    vec4 mvPos = modelViewMatrix * vec4(vpos, 1.0);
    vec4 worldPosition = viewMatrix * vec4(pos, 1.0);
    return normalize(worldPosition.xyz - mvPos.xyz);
}

float getShadow(vec3 pos, vec3 normal, float bias) {
    float shadow = 1.0;
    #if defined(SHADOW_MAPS)

    vec4 shadowMapCoords;
    vec3 coords;
    float lookup;

    #pragma unroll_loop
    for (int i = 0; i < SHADOW_COUNT; i++) {
        shadowMapCoords = shadowMatrix[i] * vec4(pos, 1.0);
        coords = (shadowMapCoords.xyz / shadowMapCoords.w) * vec3(0.5) + vec3(0.5);

        lookup = shadowLookup(shadowMap[i], coords, shadowSize[i], coords.z - bias, pos);
        lookup += mix(1.0 - step(0.002, dot(transformShadowLight(shadowLightPos[i], pos), normal)), 0.0, step(999.0, normal.x));
        shadow *= clamp(lookup, 0.0, 1.0);
    }

    #endif
    return shadow;
}

float getShadow(vec3 pos, vec3 normal) {
    return getShadow(pos, normal, 0.0);
}

float getShadow(vec3 pos, float bias) {
    return getShadow(pos, vec3(99999.0), bias);
}

float getShadow(vec3 pos) {
    return getShadow(pos, vec3(99999.0), 0.0);
}{@}envmap.glsl{@}vec3 inverseTformDir(in vec3 dir, in mat4 matrix) {
	return normalize((vec4(dir, 0.0) * matrix).xyz);
}

// For use in fragment shader alone
vec4 envmap(vec4 mPos, vec3 normal, sampler2D uEnv) {
    // Requires uniforms cameraPosition, viewMatrix
    vec3 cameraToVertex = normalize(mPos.xyz - cameraPosition);
    vec3 worldNormal = inverseTformDir(normalize(normal), viewMatrix);
    vec3 reflect = normalize(reflect(cameraToVertex, worldNormal));
    vec3 reflectView = normalize((viewMatrix * vec4( reflect, 0.0)).xyz + vec3(0.0, 0.0, 1.0));
    return texture2D(uEnv, reflectView.xy * 0.5 + 0.5);
}

//viewMatrix * mvPos{@}fresnel.glsl{@}float getFresnel(vec3 normal, vec3 viewDir, float power) {
    float d = dot(normalize(normal), normalize(viewDir));
    return 1.0 - pow(abs(d), power);
}

//viewDir = -vec3(modelViewMatrix * vec4(position, 1.0));{@}FXAA.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS
varying vec2 v_rgbNW;
varying vec2 v_rgbNE;
varying vec2 v_rgbSW;
varying vec2 v_rgbSE;
varying vec2 v_rgbM;

#!SHADER: FXAA.vs

varying vec2 vUv;

void main() {
    vUv = uv;

    vec2 fragCoord = uv * resolution;
    vec2 inverseVP = 1.0 / resolution.xy;
    v_rgbNW = (fragCoord + vec2(-1.0, -1.0)) * inverseVP;
    v_rgbNE = (fragCoord + vec2(1.0, -1.0)) * inverseVP;
    v_rgbSW = (fragCoord + vec2(-1.0, 1.0)) * inverseVP;
    v_rgbSE = (fragCoord + vec2(1.0, 1.0)) * inverseVP;
    v_rgbM = vec2(fragCoord * inverseVP);

    gl_Position = vec4(position, 1.0);
}

#!SHADER: FXAA.fs

#require(conditionals.glsl)

#ifndef FXAA_REDUCE_MIN
    #define FXAA_REDUCE_MIN   (1.0/ 128.0)
#endif
#ifndef FXAA_REDUCE_MUL
    #define FXAA_REDUCE_MUL   (1.0 / 8.0)
#endif
#ifndef FXAA_SPAN_MAX
    #define FXAA_SPAN_MAX     8.0
#endif

vec4 fxaa(sampler2D tex, vec2 fragCoord, vec2 resolution,
            vec2 v_rgbNW, vec2 v_rgbNE,
            vec2 v_rgbSW, vec2 v_rgbSE,
            vec2 v_rgbM) {
    vec4 color;
    mediump vec2 inverseVP = vec2(1.0 / resolution.x, 1.0 / resolution.y);
    vec3 rgbNW = texture2D(tex, v_rgbNW).xyz;
    vec3 rgbNE = texture2D(tex, v_rgbNE).xyz;
    vec3 rgbSW = texture2D(tex, v_rgbSW).xyz;
    vec3 rgbSE = texture2D(tex, v_rgbSE).xyz;
    vec4 texColor = texture2D(tex, v_rgbM);
    vec3 rgbM  = texColor.xyz;
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    mediump vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *
                          (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);

    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
              max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
              dir * rcpDirMin)) * inverseVP;

    vec3 rgbA = 0.5 * (
        texture2D(tex, fragCoord * inverseVP + dir * (1.0 / 3.0 - 0.5)).xyz +
        texture2D(tex, fragCoord * inverseVP + dir * (2.0 / 3.0 - 0.5)).xyz);
    vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture2D(tex, fragCoord * inverseVP + dir * -0.5).xyz +
        texture2D(tex, fragCoord * inverseVP + dir * 0.5).xyz);

    float lumaB = dot(rgbB, luma);

    color = vec4(rgbB, texColor.a);
    color = mix(color, vec4(rgbA, texColor.a), when_lt(lumaB, lumaMin));
    color = mix(color, vec4(rgbA, texColor.a), when_gt(lumaB, lumaMax));

    return color;
}

void main() {
    vec2 fragCoord = vUv * resolution;
    gl_FragColor = fxaa(tDiffuse, fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM);
    gl_FragColor.a = 1.0;
}{@}gaussianblur.fs{@}vec4 blur13(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += texture2D(image, uv) * 0.1964825501511404;
  color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;
  color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;
  return color;
}

vec4 blur5(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3333333333333333) * direction;
  color += texture2D(image, uv) * 0.29411764705882354;
  color += texture2D(image, uv + (off1 / resolution)) * 0.35294117647058826;
  color += texture2D(image, uv - (off1 / resolution)) * 0.35294117647058826;
  return color;
}

vec4 blur9(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3846153846) * direction;
  vec2 off2 = vec2(3.2307692308) * direction;
  color += texture2D(image, uv) * 0.2270270270;
  color += texture2D(image, uv + (off1 / resolution)) * 0.3162162162;
  color += texture2D(image, uv - (off1 / resolution)) * 0.3162162162;
  color += texture2D(image, uv + (off2 / resolution)) * 0.0702702703;
  color += texture2D(image, uv - (off2 / resolution)) * 0.0702702703;
  return color;
}{@}glscreenprojection.glsl{@}vec2 frag_coord(vec4 glPos) {
    return ((glPos.xyz / glPos.w) * 0.5 + 0.5).xy;
}

vec2 getProjection(vec3 pos, mat4 projMatrix) {
    vec4 mvpPos = projMatrix * vec4(pos, 1.0);
    return frag_coord(mvpPos);
}

void applyNormal(inout vec3 pos, mat4 projNormalMatrix) {
    vec3 transformed = vec3(projNormalMatrix * vec4(pos, 0.0));
    pos = transformed;
}{@}DefaultText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: DefaultText.vs

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: DefaultText.fs

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}
{@}msdf.glsl{@}float msdf(sampler2D tMap, vec2 uv) {
    vec3 tex = texture2D(tMap, uv).rgb;
    float signedDist = max(min(tex.r, tex.g), min(max(tex.r, tex.g), tex.b)) - 0.5;

    // TODO: fallback for fwidth for webgl1 (need to enable ext)
    float d = fwidth(signedDist);
    float alpha = smoothstep(-d, d, signedDist);
    if (alpha < 0.01) discard;
    return alpha;
}

float strokemsdf(sampler2D tMap, vec2 uv, float stroke, float padding) {
    vec3 tex = texture2D(tMap, uv).rgb;
    float signedDist = max(min(tex.r, tex.g), min(max(tex.r, tex.g), tex.b)) - 0.5;
    float t = stroke;
    float alpha = smoothstep(-t, -t + padding, signedDist) * smoothstep(t, t - padding, signedDist);
    return alpha;
}{@}GLUIBatch.glsl{@}#!ATTRIBUTES
attribute vec2 offset;
attribute vec2 scale;
attribute float rotation;
//attributes

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;
//varyings

#!SHADER: Vertex

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0);
}

void main() {
    vUv = uv;
    //vdefines

    vec3 pos = vec3(rotationMatrix(vec3(0.0, 0.0, 1.0), rotation) * vec4(position, 1.0));
    pos.xy *= scale;
    pos.xy += offset;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = vec4(1.0);
}{@}GLUIBatchText.glsl{@}#!ATTRIBUTES
attribute vec2 offset;
attribute vec2 scale;
attribute float rotation;
//attributes

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;
//varyings

#!SHADER: Vertex

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0);
}

void main() {
    vUv = uv;
    //vdefines

    vec3 pos = vec3(rotationMatrix(vec3(0.0, 0.0, 1.0), rotation) * vec4(position, 1.0));
    pos.xy *= scale;
    pos.xy += offset;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);

    gl_FragColor.rgb = v_uColor;
    gl_FragColor.a = alpha * v_uAlpha;
}
{@}GLUIColor.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: GLUIColor.vs
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

    #!SHADER: GLUIColor.fs
void main() {
    vec2 uv = vUv;
    vec3 uvColor = vec3(uv, 1.0);
    gl_FragColor = vec4(mix(uColor, uvColor, 0.0), uAlpha);
}{@}GLUIObject.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;
uniform float uHover;

#!VARYINGS
varying vec2 vUv;

#!SHADER: GLUIObject.vs
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: GLUIObject.fs
void main() {
    vec4 tex = texture2D(tMap, vUv);

    tex.rgb = mix(tex.rgb, tex.rgb*1.3, uHover);

    gl_FragColor = tex;
    gl_FragColor.a *= uAlpha;
}{@}GLUIObjectMask.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;
uniform float uHover;
uniform vec4 mask;

#!VARYINGS
varying vec2 vUv;
varying vec2 vWorldPos;

#!SHADER: GLUIObjectMask.vs
void main() {
    vUv = uv;
    vWorldPos = (modelMatrix * vec4(position.xy, 0.0, 1.0)).xy;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: GLUIObjectMask.fs
void main() {
    vec4 tex = texture2D(tMap, vUv);

    tex.rgb = mix(tex.rgb, tex.rgb*1.2, uHover);

    gl_FragColor = tex;
    gl_FragColor.a *= uAlpha;

    if (vWorldPos.x > mask.x + mask.z) discard;
    if (vWorldPos.x < mask.x) discard;
    if (vWorldPos.y > mask.y) discard;
    if (vWorldPos.y < mask.y - mask.w) discard;
}{@}luma.fs{@}float luma(vec3 color) {
  return dot(color, vec3(0.299, 0.587, 0.114));
}

float luma(vec4 color) {
  return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}{@}lut.fs{@}vec4 lookup(in vec4 textureColor, in sampler2D lookupTable) {
    mediump float blueColor = textureColor.b * 63.0;

    mediump vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);

    mediump vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);

    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);

    texPos1.y = 1.0-texPos1.y;

    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);

    texPos2.y = 1.0-texPos2.y;

    lowp vec4 newColor1 = texture2D(lookupTable, texPos1);
    lowp vec4 newColor2 = texture2D(lookupTable, texPos2);

    lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return newColor;
}{@}matcap.vs{@}vec2 reflectMatcap(vec3 position, mat4 modelViewMatrix, mat3 normalMatrix, vec3 normal) {
    vec4 p = vec4(position, 1.0);
    
    vec3 e = normalize(vec3(modelViewMatrix * p));
    vec3 n = normalize(normalMatrix * normal);
    vec3 r = reflect(e, n);
    float m = 2.0 * sqrt(
        pow(r.x, 2.0) +
        pow(r.y, 2.0) +
        pow(r.z + 1.0, 2.0)
    );
    
    vec2 uv = r.xy / m + .5;
    
    return uv;
}

vec2 reflectMatcap(vec3 position, mat4 modelViewMatrix, vec3 normal) {
    vec4 p = vec4(position, 1.0);
    
    vec3 e = normalize(vec3(modelViewMatrix * p));
    vec3 n = normalize(normal);
    vec3 r = reflect(e, n);
    float m = 2.0 * sqrt(
                         pow(r.x, 2.0) +
                         pow(r.y, 2.0) +
                         pow(r.z + 1.0, 2.0)
                         );
    
    vec2 uv = r.xy / m + .5;
    
    return uv;
}

vec2 reflectMatcap(vec4 mvPos, vec3 normal) {
    vec3 e = normalize(vec3(mvPos));
    vec3 n = normalize(normal);
    vec3 r = reflect(e, n);
    float m = 2.0 * sqrt(
                         pow(r.x, 2.0) +
                         pow(r.y, 2.0) +
                         pow(r.z + 1.0, 2.0)
                         );

    vec2 uv = r.xy / m + .5;

    return uv;
}{@}BasicMirror.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMirrorReflection;
uniform mat4 uMirrorMatrix;

#!VARYINGS
varying vec4 vMirrorCoord;

#!SHADER: BasicMirror.vs
void main() {
    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    vMirrorCoord = uMirrorMatrix * worldPos;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: BasicMirror.fs
void main() {
    gl_FragColor.rgb = vec3(texture2D(tMirrorReflection, vMirrorCoord.xy / vMirrorCoord.w));
    gl_FragColor.a = 1.0;
}{@}MouseFlowMapBlend.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D uTexture;
uniform sampler2D uStamp;
uniform float uSpeed;
uniform float uFirstDraw;

#!VARYINGS

varying vec2 vUv;

#!SHADER: MouseFlowMapBlend.vs

void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}

#!SHADER: MouseFlowMapBlend.fs

vec3 blend(vec3 base, vec3 blend, float opacity) {
    return blend + (base * (1.0 - opacity));
}

#require(range.glsl)

void main() {
    vec3 prev = texture2D(uTexture, vUv).rgb;
    prev = prev * 2.0 - 1.0;
    float amount = crange(length(prev.rg), 0.0, 0.4, 0.0, 1.0);
    amount = 0.5 + 0.48 * (1.0 - pow(1.0 - amount, 3.0));
    prev *= amount;
    prev = prev * 0.5 + 0.5;

    // blue not used
    prev.b = 0.5;

    vec4 tex = texture2D(uStamp, vUv);
    gl_FragColor.rgb = blend(prev, tex.rgb, tex.a);

    // Force a grey on first draw to have init values
    gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.5), uFirstDraw);
    gl_FragColor.a = 1.0;
}
{@}MouseFlowMapStamp.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform vec2 uVelocity;
uniform float uFalloff;
uniform float uAlpha;
uniform float uAspect;

#!VARYINGS

varying vec2 vUv;

#!SHADER: MouseFlowMapStamp.vs

void main() {
    vUv = uv;
    vec3 pos = position;
    pos.x *= 1.0 / uAspect;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

    #!SHADER: MouseFlowMapStamp.fs

void main() {
    gl_FragColor.rgb = vec3(uVelocity * 0.5 + 0.5, 1.0);
    gl_FragColor.a = smoothstep(0.5, 0.499 - (uFalloff * 0.499), length(vUv - 0.5)) * uAlpha;
}
{@}flowmap.fs{@}float getFlowMask(sampler2D map, vec2 uv) {
    vec2 flow = texture2D(map, uv).rg;
    return clamp(length(flow.rg * 2.0 - 1.0), 0.0, 1.0);
}

vec2 getFlow(sampler2D map, vec2 uv) {
    vec2 flow = texture2D(map, uv).rg * 2.0 - 1.0;
    flow.y *= -1.0;
    return flow;
}{@}normalmap.glsl{@}vec3 unpackNormal( vec3 eye_pos, vec3 surf_norm, sampler2D normal_map, float intensity, float scale, vec2 uv ) {
    surf_norm = normalize(surf_norm);
    
    vec3 q0 = dFdx( eye_pos.xyz );
    vec3 q1 = dFdy( eye_pos.xyz );
    vec2 st0 = dFdx( uv.st );
    vec2 st1 = dFdy( uv.st );
    
    vec3 S = normalize( q0 * st1.t - q1 * st0.t );
    vec3 T = normalize( -q0 * st1.s + q1 * st0.s );
    vec3 N = normalize( surf_norm );
    
    vec3 mapN = texture2D( normal_map, uv * scale ).xyz * 2.0 - 1.0;
    mapN.xy *= intensity;
    mat3 tsn = mat3( S, T, N );
    return normalize( tsn * mapN );
}

//mvPosition.xyz, normalMatrix * normal, normalMap, intensity, scale, uv{@}PBR.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: PBR.vs

#require(pbr.vs)

void main() {
    setupPBR(position);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: PBR.fs

#require(pbr.fs)

void main() {
    gl_FragColor = getPBR();
}{@}pbr.fs{@}uniform sampler2D tBaseColor;
uniform vec2 uEnv;

uniform sampler2D tMRO;
uniform vec3 uMRO;

uniform sampler2D tNormal;
uniform vec2 uNormalScale;

uniform sampler2D tLUT;
uniform sampler2D tEnvDiffuse;
uniform sampler2D tEnvSpecular;
uniform float uHDR;

uniform vec4 uLight;

const float PI = 3.14159265359;
const float PI2 = 6.28318530718;
const float RECIPROCAL_PI = 0.31830988618;
const float RECIPROCAL_PI2 = 0.15915494;
const float LOG2 = 1.442695;
const float EPSILON = 1e-6;
const float LN2 = 0.6931472;

const float ENV_LODS = 7.0;

struct PBRConfig {
    float reflection;
    float darken;
    vec3 color;
};

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vMPos;

vec4 SRGBtoLinear(vec4 srgb) {
    vec3 linOut = pow(srgb.xyz, vec3(2.2));
    return vec4(linOut, srgb.w);
}

vec4 RGBEToLinear(vec4 value) {
    return vec4(value.rgb * exp2(value.a * 255.0 - 128.0), 1.0);
}

vec4 RGBMToLinear(vec4 value) {
    float maxRange = 6.0;
    return vec4(value.xyz * value.w * maxRange, 1.0);
}

vec4 RGBDToLinear(vec4 value, float maxRange) {
    return vec4(value.rgb * ((maxRange / 255.0) / value.a), 1.0);
}

vec3 linearToSRGB(vec3 color) {
    return pow(color, vec3(1.0 / 2.2));
}

vec3 getNormal(vec2 uNormalScale, sampler2D tNormal /*, sampler tNormalSampler*/, vec2 vUv, vec3 vNormal, vec3 vMPos) {
    vec3 pos_dx = vec3(dFdx(vMPos.x), dFdx(vMPos.y), dFdx(vMPos.z));
    vec3 pos_dy = vec3(dFdy(vMPos.x), dFdy(vMPos.y), dFdy(vMPos.z));
    vec3 tex_dx = vec3(dFdx(vUv.x), dFdx(vUv.y), dFdx(0.0));
    vec3 tex_dy = vec3(dFdy(vUv.x), dFdy(vUv.y), dFdy(0.0));
    vec3 t = (tex_dy.y * pos_dx - tex_dx.y * pos_dy) / (tex_dx.x * tex_dy.y - tex_dy.x * tex_dx.y);

    vec3 ng = normalize(vNormal);

    t = normalize(t - ng * dot(ng, t));
    vec3 b = normalize(cross(ng, t));
    mat3 tbn = mat3(t, b, ng);

    vec3 n = texture2D(tNormal, vUv * uNormalScale.y).rgb;
    n = normalize(tbn * ((2.0 * n - 1.0) * vec3(uNormalScale.x, uNormalScale.x, 1.0)));

    return n;
}

vec3 specularReflection(vec3 specularEnvR0, vec3 specularEnvR90, float VdH) {
    return specularEnvR0 + (specularEnvR90 - specularEnvR0) * pow(clamp(1.0 - VdH, 0.0, 1.0), 5.0);
}

float geometricOcclusion(float NdL, float NdV, float roughness) {
    float r = roughness;
    float attenuationL = 2.0 * NdL / (NdL + sqrt(r * r + (1.0 - r * r) * (NdL * NdL)));
    float attenuationV = 2.0 * NdV / (NdV + sqrt(r * r + (1.0 - r * r) * (NdV * NdV)));
    return attenuationL * attenuationV;
}

float microfacetDistribution(float roughness, float NdH) {
    float roughnessSq = roughness * roughness;
    float f = (NdH * roughnessSq - NdH) * NdH + 1.0;
    return roughnessSq / (PI * f * f);
}

vec3 inverseTformDir(in vec3 dir, in mat4 matrix) {
    return normalize((vec4(dir, 0.0) * matrix).xyz);
}

float prange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

float pcrange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    return clamp(prange(oldValue, oldMin, oldMax, newMin, newMax), min(newMax, newMin), max(newMin, newMax));
}

vec2 cartesianToPolar(vec3 n, vec3 vMPos, vec3 cameraPosition, mat4 viewMatrix) {
    vec3 cameraToVertex = normalize(vMPos - cameraPosition);
    vec3 worldNormal = inverseTformDir(normalize(n), viewMatrix);
    vec3 reflectVec = normalize(reflect(cameraToVertex, worldNormal));
    vec3 reflectView = normalize((viewMatrix * vec4( reflectVec, 0.0)).xyz + vec3(0.0, 0.0, 1.0));
    return reflectView.xy * 0.5 + 0.5;
}

vec4 autoToLinear(vec4 texel, float uHDR) {
    vec4 rgbm = RGBMToLinear(texel);
    vec4 srgb = SRGBtoLinear(texel);
    return mix(srgb, rgbm, uHDR);
}

vec3 getIBLContribution(float NdV, float roughness, vec3 n, vec3 reflection, vec3 diffuseColor, vec3 specularColor, PBRConfig config, vec3 cameraPosition, mat4 viewMatrix, vec2 vUv, vec3 vMPos, vec2 uEnv, float uHDR, sampler2D tLUT, /*sampler tLUTSampler,*/ sampler2D tEnvDiffuse, /*sampler tEnvDiffuseSampler,*/ sampler2D tEnvSpecular /*, sampler tEnvSpecularSampler*/) {
    vec2 lutUV = vec2(NdV, roughness);
    vec2 diffuseUV = cartesianToPolar(n, vMPos, cameraPosition, viewMatrix);

    #test !!window.Metal
    lutUV.y = 1.0 - lutUV.y;
    diffuseUV.y = 1.0 - diffuseUV.y;
    #endtest

    vec3 brdf = SRGBtoLinear(texture2D(tLUT, lutUV)).rgb;
    vec3 diffuseLight = autoToLinear( texture2D(tEnvDiffuse, diffuseUV ), uHDR).rgb;

    // Sample 2 levels and mix between to get smoother degradation
    float blend = roughness * ENV_LODS;
    float level0 = floor(blend);
    float level1 = min(ENV_LODS, level0 + 1.0);
    blend -= level0;

    // Sample the specular env map atlas depending on the roughness value
    vec2 uvSpec = diffuseUV;
    uvSpec.y /= 2.0;

    vec2 uv0 = uvSpec;
    vec2 uv1 = uvSpec;

    uv0 /= pow(2.0, level0);
    uv0.y += 1.0 - exp(-LN2 * level0);

    uv1 /= pow(2.0, level1);
    uv1.y += 1.0 - exp(-LN2 * level1);

    #test !!window.Metal
    uv0.y = 1.0 - uv0.y;
    uv1.y = 1.0 - uv1.y;
    #endtest

    vec3 specular0 = autoToLinear(texture2D(tEnvSpecular, uv0), uHDR).rgb;
    vec3 specular1 = autoToLinear(texture2D(tEnvSpecular, uv1), uHDR).rgb;
    vec3 specularLight = mix(specular0, specular1, blend);

    vec3 diffuse = diffuseLight * diffuseColor;
    vec3 specular = specularLight * (specularColor * brdf.x + brdf.y);

    // A value to be able to push the strength and mimic HDR
    specular *= (1.0 + uEnv.y * specularLight) * config.reflection;
    return diffuse + specular;
}

vec3 calculatePBR(vec3 baseColor, PBRConfig config, vec3 cameraPosition, mat4 viewMatrix, vec2 vUv, vec3 vNormal, vec3 vMPos, vec2 uEnv, vec3 uMRO, vec2 uNormalScale, float uHDR, vec4 uLight, sampler2D tMRO, /*sampler tMROSampler,*/ sampler2D tNormal, /*sampler tNormalSampler,*/ sampler2D tLUT, /*sampler tLUTSampler,*/ sampler2D tEnvDiffuse, /*sampler tEnvDiffuseSampler,*/ sampler2D tEnvSpecular /*, sampler tEnvSpecularSampler*/) {
    // rgb = [metallic, roughness, occlusion] - still have a available
    vec4 mroSample = texture2D(tMRO, vUv * uNormalScale.y);
    float metallic = clamp(mroSample.r * uMRO.x, 0.04, 1.0);
    float roughness = clamp(mroSample.g * uMRO.y, 0.04, 1.0);

    vec3 diffuseColor = baseColor * 0.96 * (1.0 - metallic);
    vec3 specularColor = mix(vec3(0.04), baseColor, metallic);

    float reflectance = max(max(specularColor.r, specularColor.g), specularColor.b);
    float reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);
    vec3 specularEnvR0 = specularColor.rgb;
    vec3 specularEnvR90 = vec3(reflectance90);

    vec3 N = getNormal(uNormalScale, tNormal, vUv, vNormal, vMPos);
    vec3 V = normalize(cameraPosition - vMPos);
    vec3 L = normalize(uLight.xyz);
    vec3 H = normalize(L + V);
    vec3 reflection = -normalize(reflect(V, N));

    float NdL = pcrange(clamp(dot(N, L), 0.001, 1.0), 0.0, 1.0, 0.4, 1.0);
    float NdV = pcrange(clamp(abs(dot(N, V)), 0.001, 1.0), 0.0, 1.0, 0.4, 1.0);
    float NdH = clamp(dot(N, H), 0.0, 1.0);
//    float LdH = clamp(dot(L, H), 0.0, 1.0);
    float VdH = clamp(dot(V, H), 0.0, 1.0);

    vec3 F = specularReflection(specularEnvR0, specularEnvR90, VdH);
    float G = geometricOcclusion(NdL, NdV, roughness);
    float D = microfacetDistribution(roughness, NdH);

    vec3 diffuseContrib = (1.0 - F) * (diffuseColor / PI);
    vec3 specContrib = F * G * D / (4.0 * NdL * NdV) * uLight.w;
    vec3 color = NdL * (diffuseContrib + specContrib) * config.darken;

    color += getIBLContribution(NdV, roughness, N, reflection, diffuseColor, specularColor, config, cameraPosition, viewMatrix, vUv, vMPos, uEnv, uHDR, tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/) * config.color * uEnv.x;

    return mix(color, color * mroSample.b, uMRO.z);
}

vec4 getPBR() {
    PBRConfig config;
    config.reflection = 1.0;
    config.darken = 1.0;
    config.color = vec3(1.0);

    vec4 baseColor = SRGBtoLinear(texture2D(tBaseColor, vUv));
    vec3 color = calculatePBR(baseColor.rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), baseColor.a);
}

vec4 getPBR(PBRConfig config) {
    vec4 baseColor = SRGBtoLinear(texture2D(tBaseColor, vUv));
    vec3 color = calculatePBR(baseColor.rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), baseColor.a);
}

vec4 getPBR(vec3 inputColor) {
    PBRConfig config;
    config.reflection = 1.0;
    config.darken = 1.0;
    config.color = vec3(1.0);

    vec3 color = calculatePBR(SRGBtoLinear(vec4(inputColor, 1.0)).rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), 1.0);
}

vec4 getPBR(vec3 inputColor, PBRConfig config) {
    vec3 color = calculatePBR(SRGBtoLinear(vec4(inputColor, 1.0)).rgb, config, cameraPosition, viewMatrix, vUv, vNormal, vMPos, uEnv, uMRO, uNormalScale, uHDR, uLight, tMRO, /*tMROSampler,*/ tNormal, /*tNormalSampler,*/ tLUT, /*tLUTSampler,*/ tEnvDiffuse, /*tEnvDiffuseSampler,*/ tEnvSpecular /*, tEnvSpecularSampler*/);
    return vec4(linearToSRGB(color), 1.0);
}{@}pbr.vs{@}uniform sampler2D tBaseColor;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vMPos;

void setupPBR(vec3 p0) { //inlinemain
    vUv = uv;
    vec4 mPos = modelMatrix * vec4(p0, 1.0);
    vMPos = mPos.xyz / mPos.w;
    vNormal = normalMatrix * normal;
}{@}phong.fs{@}#define saturate(a) clamp( a, 0.0, 1.0 )

float dPhong(float shininess, float dotNH) {
    return (shininess * 0.5 + 1.0) * pow(dotNH, shininess);
}

vec3 schlick(vec3 specularColor, float dotLH) {
    float fresnel = exp2((-5.55437 * dotLH - 6.98316) * dotLH);
    return (1.0 - specularColor) * fresnel + specularColor;
}

vec3 calcBlinnPhong(vec3 specularColor, float shininess, vec3 normal, vec3 lightDir, vec3 viewDir) {
    vec3 halfDir = normalize(lightDir + viewDir);
    
    float dotNH = saturate(dot(normal, halfDir));
    float dotLH = saturate(dot(lightDir, halfDir));

    vec3 F = schlick(specularColor, dotLH);
    float G = 0.85;
    float D = dPhong(shininess, dotNH);
    
    return F * G * D;
}

vec3 calcBlinnPhong(vec3 specularColor, float shininess, vec3 normal, vec3 lightDir, vec3 viewDir, float minTreshold) {
    vec3 halfDir = normalize(lightDir + viewDir);

    float dotNH = saturate(dot(normal, halfDir));
    float dotLH = saturate(dot(lightDir, halfDir));

    dotNH = range(dotNH, 0.0, 1.0, minTreshold, 1.0);
    dotLH = range(dotLH, 0.0, 1.0, minTreshold, 1.0);

    vec3 F = schlick(specularColor, dotLH);
    float G = 0.85;
    float D = dPhong(shininess, dotNH);

    return F * G * D;
}

vec3 phong(float amount, vec3 diffuse, vec3 specular, float shininess, float attenuation, vec3 normal, vec3 lightDir, vec3 viewDir) {
    float cosineTerm = saturate(dot(normal, lightDir));
    vec3 brdf = calcBlinnPhong(specular, shininess, normal, lightDir, viewDir);
    return brdf * amount * diffuse * attenuation * cosineTerm;
}

vec3 phong(float amount, vec3 diffuse, vec3 specular, float shininess, float attenuation, vec3 normal, vec3 lightDir, vec3 viewDir, float minThreshold) {
    float cosineTerm = saturate(range(dot(normal, lightDir), 0.0, 1.0, minThreshold, 1.0));
    vec3 brdf = calcBlinnPhong(specular, shininess, normal, lightDir, viewDir, minThreshold);
    return brdf * amount * diffuse * attenuation * cosineTerm;
}

//viewDir = -mvPosition.xyz
//lightDir = normalize(lightPos){@}radialblur.fs{@}vec3 radialBlur( sampler2D map, vec2 uv, float size, vec2 resolution ) {
    vec3 color = vec3(0.0);

    const float pi2 = 3.141596 * 2.0;
    const float direction = 8.0;
    const float quality = 2.0;

    vec2 radius = size / resolution;

    for ( float d = 0.0; d < pi2 ; d += pi2 / direction ) {
        for ( float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality ) {
            color += texture2D( map, uv + vec2( cos( d ), sin( d )) * radius * i ).rgb / ( quality * direction );
        }
    }

    return color;
}{@}range.glsl{@}float range(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

float crange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    return clamp(range(oldValue, oldMin, oldMax, newMin, newMax), min(newMax, newMin), max(newMin, newMax));
}

vec2 crange(vec2 oldValue, vec2 oldMin, vec2 oldMax, vec2 newMin, vec2 newMax) {
    vec2 v;
    v.x = crange(oldValue.x, oldMin.x, oldMax.x, newMin.x, newMax.x);
    v.y = crange(oldValue.y, oldMin.y, oldMax.y, newMin.y, newMax.y);
    return v;
}

vec2 range(vec2 oldValue, vec2 oldMin, vec2 oldMax, vec2 newMin, vec2 newMax) {
    vec2 v;
    v.x = range(oldValue.x, oldMin.x, oldMax.x, newMin.x, newMax.x);
    v.y = range(oldValue.y, oldMin.y, oldMax.y, newMin.y, newMax.y);
    return v;
}

vec3 crange(vec3 oldValue, vec3 oldMin, vec3 oldMax, vec3 newMin, vec3 newMax) {
    vec3 v;
    v.x = crange(oldValue.x, oldMin.x, oldMax.x, newMin.x, newMax.x);
    v.y = crange(oldValue.y, oldMin.y, oldMax.y, newMin.y, newMax.y);
    v.z = crange(oldValue.z, oldMin.z, oldMax.z, newMin.z, newMax.z);
    return v;
}

vec3 range(vec3 oldValue, vec3 oldMin, vec3 oldMax, vec3 newMin, vec3 newMax) {
    vec3 v;
    v.x = range(oldValue.x, oldMin.x, oldMax.x, newMin.x, newMax.x);
    v.y = range(oldValue.y, oldMin.y, oldMax.y, newMin.y, newMax.y);
    v.z = range(oldValue.z, oldMin.z, oldMax.z, newMin.z, newMax.z);
    return v;
}{@}rgb2hsv.fs{@}vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}{@}rgbshift.fs{@}vec4 getRGB(sampler2D tDiffuse, vec2 uv, float angle, float amount) {
    vec2 offset = vec2(cos(angle), sin(angle)) * amount;
    vec4 r = texture2D(tDiffuse, uv + offset);
    vec4 g = texture2D(tDiffuse, uv);
    vec4 b = texture2D(tDiffuse, uv - offset);
    return vec4(r.r, g.g, b.b, g.a);
}{@}rotation.glsl{@}mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}{@}simplenoise.glsl{@}float getNoise(vec2 uv, float time) {
    float x = uv.x * uv.y * time * 1000.0;
    x = mod(x, 13.0) * mod(x, 123.0);
    float dx = mod(x, 0.01);
    float amount = clamp(0.1 + dx * 100.0, 0.0, 1.0);
    return amount;
}

highp float getRandom(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt = dot(co.xy, vec2(a, b));
    highp float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

float cnoise(vec3 v) {
    float t = v.z * 0.3;
    v.y *= 0.8;
    float noise = 0.0;
    float s = 0.5;
    noise += range(sin(v.x * 0.9 / s + t * 10.0) + sin(v.x * 2.4 / s + t * 15.0) + sin(v.x * -3.5 / s + t * 4.0) + sin(v.x * -2.5 / s + t * 7.1), -1.0, 1.0, -0.3, 0.3);
    noise += range(sin(v.y * -0.3 / s + t * 18.0) + sin(v.y * 1.6 / s + t * 18.0) + sin(v.y * 2.6 / s + t * 8.0) + sin(v.y * -2.6 / s + t * 4.5), -1.0, 1.0, -0.3, 0.3);
    return noise;
}

float cnoise(vec2 v) {
    float t = v.x * 0.3;
    v.y *= 0.8;
    float noise = 0.0;
    float s = 0.5;
    noise += range(sin(v.x * 0.9 / s + t * 10.0) + sin(v.x * 2.4 / s + t * 15.0) + sin(v.x * -3.5 / s + t * 4.0) + sin(v.x * -2.5 / s + t * 7.1), -1.0, 1.0, -0.3, 0.3);
    noise += range(sin(v.y * -0.3 / s + t * 18.0) + sin(v.y * 1.6 / s + t * 18.0) + sin(v.y * 2.6 / s + t * 8.0) + sin(v.y * -2.6 / s + t * 4.5), -1.0, 1.0, -0.3, 0.3);
    return noise;
}{@}transformUV.glsl{@}vec2 transformUV(vec2 uv, float a[9]) {

    // Convert UV to vec3 to apply matrices
	vec3 u = vec3(uv, 1.0);

    // Array consists of the following
    // 0 translate.x
    // 1 translate.y
    // 2 skew.x
    // 3 skew.y
    // 4 rotate
    // 5 scale.x
    // 6 scale.y
    // 7 origin.x
    // 8 origin.y

    // Origin before matrix
    mat3 mo1 = mat3(
        1, 0, -a[7],
        0, 1, -a[8],
        0, 0, 1);

    // Origin after matrix
    mat3 mo2 = mat3(
        1, 0, a[7],
        0, 1, a[8],
        0, 0, 1);

    // Translation matrix
    mat3 mt = mat3(
        1, 0, -a[0],
        0, 1, -a[1],
    	0, 0, 1);

    // Skew matrix
    mat3 mh = mat3(
        1, a[2], 0,
        a[3], 1, 0,
    	0, 0, 1);

    // Rotation matrix
    mat3 mr = mat3(
        cos(a[4]), sin(a[4]), 0,
        -sin(a[4]), cos(a[4]), 0,
    	0, 0, 1);

    // Scale matrix
    mat3 ms = mat3(
        1.0 / a[5], 0, 0,
        0, 1.0 / a[6], 0,
    	0, 0, 1);

	// apply translation
   	u = u * mt;

	// apply skew
   	u = u * mh;

    // apply rotation relative to origin
    u = u * mo1;
    u = u * mr;
    u = u * mo2;

    // apply scale relative to origin
    u = u * mo1;
    u = u * ms;
    u = u * mo2;

    // Return vec2 of new UVs
    return u.xy;
}

vec2 rotateUV(vec2 uv, float r, vec2 origin) {
    vec3 u = vec3(uv, 1.0);

    mat3 mo1 = mat3(
        1, 0, -origin.x,
        0, 1, -origin.y,
        0, 0, 1);

    mat3 mo2 = mat3(
        1, 0, origin.x,
        0, 1, origin.y,
        0, 0, 1);

    mat3 mr = mat3(
        cos(r), sin(r), 0,
        -sin(r), cos(r), 0,
        0, 0, 1);

    u = u * mo1;
    u = u * mr;
    u = u * mo2;

    return u.xy;
}

vec2 rotateUV(vec2 uv, float r) {
    return rotateUV(uv, r, vec2(0.5));
}

vec2 translateUV(vec2 uv, vec2 translate) {
    vec3 u = vec3(uv, 1.0);
    mat3 mt = mat3(
        1, 0, -translate.x,
        0, 1, -translate.y,
        0, 0, 1);

    u = u * mt;
    return u.xy;
}

vec2 scaleUV(vec2 uv, vec2 scale, vec2 origin) {
    vec3 u = vec3(uv, 1.0);

    mat3 mo1 = mat3(
        1, 0, -origin.x,
        0, 1, -origin.y,
        0, 0, 1);

    mat3 mo2 = mat3(
        1, 0, origin.x,
        0, 1, origin.y,
        0, 0, 1);

    mat3 ms = mat3(
        1.0 / scale.x, 0, 0,
        0, 1.0 / scale.y, 0,
        0, 0, 1);

    u = u * mo1;
    u = u * ms;
    u = u * mo2;
    return u.xy;
}

vec2 scaleUV(vec2 uv, vec2 scale) {
    return scaleUV(uv, scale, vec2(0.5));
}
{@}LightBlur.fs{@}uniform vec2 uDir;

#require(gaussianblur.fs)

void main() {
    gl_FragColor = blur9(tDiffuse, vUv, resolution, uDir);
}{@}VolumetricLight.fs{@}uniform vec2 lightPos;
uniform float fExposure;
uniform float fDecay;
uniform float fDensity;
uniform float fWeight;
uniform float fClamp;

const int iSamples = 20;

void main() {
    vec2 deltaTextCoord = vUv - lightPos;
    deltaTextCoord *= 1.0  / float(iSamples) * fDensity;
    vec2 coord = vUv;

    float illuminationDecay = 1.0;
    vec4 color = vec4(0.0);

    for (int i = 0; i < iSamples; i++) {
        coord -= deltaTextCoord;
        vec4 texel = texture2D(tDiffuse, coord);
        texel *= illuminationDecay * fWeight;

        color += texel;
        illuminationDecay *= fDecay;
    }

    color *= fExposure;
    color = clamp(color, 0.0, fClamp);
    gl_FragColor = color;
}{@}StageLayoutCapture.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec4 color = texture2D(tMap, vUv);
    gl_FragColor = color;
    gl_FragColor.a *= uAlpha;
}{@}BuildingPlane.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uTintFactor;
uniform vec3 uTint;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    float gradient = vUv.y;
    vec4 color = texture2D(tMap, vUv);
    color.rgb = mix(uTint, color.rgb, uTintFactor - gradient);
    gl_FragColor = color;
    gl_FragColor.a *= gradient;
}{@}PBRBuilding.glsl{@}#!ATTRIBUTES
//attribute vec4 random;

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uBaseTint;
uniform float uHueRange;
uniform float uRandomHeight;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying float vRandom;

#!SHADER: Vertex

#require(pbr.vs)
#require(lighting.vs)
#require(range.glsl)

void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;

//    pos.y -= uRandomHeight * random.y;

    setupLight(pos, transformedNormal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
//    vRandom = range(random.x, 0.0, 1.0, -1.0, 1.0);
}

#!SHADER: Fragment

#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(rgb2hsv.fs)

void main() {
    setupLight();

    vec3 color = texture2D(tBaseColor, vUv).xyz * uBaseTint;
//    color = rgb2hsv(color);
//    color.x += vRandom * uHueRange;
//    color = hsv2rgb(color);

    vec3 pbr = getPBR(color).rgb;
    pbr *= getDirectionalLightColor();

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PBRFence.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tOpacity;
uniform sampler2D tTilingTexture;
uniform vec2 uTile;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform float uTilingMask;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    // vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)

void main() {
    float opacity = texture2D(tOpacity, vUv).x;
    // if (opacity < 0.1) discard;

    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor();
    
    
    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    vec3 ads = texture2D(tTilingTexture, vUv * uTile).rgb;
    ads = mix(ads, vec3(1.0), step(uTilingMask, vUv.y));
    pbr *= mix(ads, uFogColor, fog);

    gl_FragColor = vec4(pbr, opacity);
}{@}PBRRoadSurface.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uShadowTint;
uniform float uOpacityFactor;
uniform sampler2D tOpacity;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)

void main() {
    vec4 opacity = texture2D(tOpacity, vUv);
    float a = mix(opacity.r, 1.0, uOpacityFactor);
    if (a < 0.7) discard;
    // float a = mix(opacity.r, 1.0, uOpacityFactor);
    // if (a < 0.9) discard;
    // if (mro.a < 0.02) discard;

    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor();
    pbr *= mix(uShadowTint, vec3(1.0), getShadow(vPos));

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PBRRoadSurfaceLightmap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uShadowTint;
uniform float uOpacityFactor;
uniform sampler2D tLightmap;
uniform vec2 uLightmapTile;
uniform float uLightmapBrightness;
uniform float uLineSpeed;
uniform float uLineFrequency;
uniform float uLineOffset;
uniform float uLineOffset2;
uniform float uLineCutoff;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uAlternateColor;
uniform float uAlternateColorFactor;
uniform float uAlternateColorFreq;
uniform float uEdgeFactor;
uniform vec2 uCloseFogRange;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)
#require(normalmap.glsl)

void main() {
    LightConfig lconfig;

    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);
    lconfig.normal = normal;

    setupLight();
    vec3 lightmap = texture2D(tLightmap, vUv * uLightmapTile).rgb;
    vec3 pbr = getPBR(uTint3).rgb;
    pbr *= getDirectionalLightColor();
    pbr += getPointLightColor(lconfig);

    float edgeGradient = crange(abs((vUv.x - 0.5) * 2.0), 0.85, 1.2, 0.0, 1.0) * 0.8;

    vec3 lightColor = mix(uTint2, uAlternateColor, step(0.5, sin(vUv.y * uAlternateColorFreq)));

    lightmap = vec3(crange(lightmap.r, 0.1, 0.8, 0.0, 1.0));
    lightmap = mix(uTint1, lightColor, lightmap.r);

    float lighttoggle = smoothstep(uLineCutoff - 0.1, uLineCutoff + 0.1, sin(vUv.y * uLineFrequency + uLineOffset));

    pbr += lightmap * clamp(lighttoggle, 0.00, 1.0) * uLightmapBrightness;
    pbr += lightmap * clamp(lighttoggle, 0.00, 1.0) * uLightmapBrightness;

    pbr *= mix(uShadowTint, vec3(1.0), getShadow(vPos));

    pbr += edgeGradient * uAlternateColor;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    float closefog = 1.0 - crange(vModelViewPos.z, uCloseFogRange.x, uCloseFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog + closefog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PBRSurface.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uTint;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    setupLight(pos, transformedNormal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)

void main() {
    setupLight();

    vec3 color = texture2D(tBaseColor, vUv).xyz * uTint;

    vec3 pbr = getPBR(color).rgb;
    pbr *= getDirectionalLightColor();

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PBRSurfaceAlpha.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tOpacity;
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    // vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)

void main() {
    float opacity = texture2D(tOpacity, vUv).x;
    // if (opacity < 0.1) discard;

    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor();
    
    
    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(pbr, opacity);
}{@}RealisticSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTile;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec2 st = vUv * uTile;
    vec4 color = texture2D(tMap, st);
    gl_FragColor = color;
}{@}Sun.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uRange;
uniform vec3 uTint1;
uniform vec3 uTint2;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float dist = crange(distance(vUv, vec2(0.5)), uRange.x, uRange.y, 1.0, 0.0);
    dist = pow(dist, 2.0);
    vec3 color = mix(uTint1, uTint2, dist);
    gl_FragColor.rgb = color;
    gl_FragColor.a = dist;
}{@}Building.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform float uPixellation;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);

    setupLight(pos, transformedNormal);
    gl_Position = projectionMatrix * modelViewPos;

    vUv = uv;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(lighting.fs)
#require(range.glsl)
void main() {
    setupLight();
    vec2 st = floor(vUv * uPixellation) / uPixellation;
    vec4 color = texture2D(tMap, st);
    color.rgb *= getDirectionalLightColor();

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color.rgb = mix(color.rgb, uFogColor, distanceFog);
    gl_FragColor = color;
}{@}BuildingTransparent.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec2 uTile;
uniform float uPixellation;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);

    setupLight(pos, transformedNormal);
    gl_Position = projectionMatrix * modelViewPos;

    vUv = uv;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(lighting.fs)
#require(range.glsl)
void main() {
    setupLight();
    vec2 st = floor((vUv * uTile) * uPixellation) / uPixellation;
    vec4 color = texture2D(tMap, st);

    if (color.a < 0.5) discard;

    color.rgb *= getDirectionalLightColor();

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color.rgb = mix(color.rgb, uFogColor, distanceFog);
    gl_FragColor = color;
}{@}GutterNN.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTextureTile;
uniform vec2 uTextureScroll;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform float uPixellation;
uniform vec2 uShadowRange;
uniform vec3 uShadowColor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment

#require(shadows.fs)
#require(range.glsl)

void main() {
    vec2 st = floor((vUv * uTextureTile + uTextureScroll) * uPixellation) / uPixellation;
    vec4 color = texture2D(tMap, st);
    color *= (step(0.5, getShadow(vPos)) + 0.5) / 1.5;

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color.rgb = mix(color.rgb, uFogColor, distanceFog);

    float ao = crange(abs((vUv.x - 0.5) * 2.0), uShadowRange.x, uShadowRange.y, 0.0, 1.0);
    color.rgb *= mix(vec3(1.0), uShadowColor, ao);

    gl_FragColor = color;
}{@}IntegraBuilding.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);

    setupLight(pos, transformedNormal);
    gl_Position = projectionMatrix * modelViewPos;

    vUv = uv;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(lighting.fs)
#require(range.glsl)
void main() {
    setupLight();
    vec4 color = texture2D(tMap, vUv);
    color.rgb *= getDirectionalLightColor();

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color.rgb = mix(color.rgb, uFogColor, distanceFog);
    gl_FragColor = color;
}{@}LookupSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform sampler2D tLut;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform float uPixellation;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(lut.fs)
void main() {
    vec2 st = floor((vUv * uTile + uScroll) * uPixellation) / uPixellation;
    vec4 color = texture2D(tMap, st);
//    color = lookup(color, tLut);
    gl_FragColor = color;
}{@}ObjectNN.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    vec4 color = texture2D(tMap, vUv);

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);
    color.rgb = mix(color.rgb, uFogColor, distanceFog);
    gl_FragColor = color;
}{@}RoadNN.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTextureTile;
uniform vec2 uTextureScroll;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform float uPixellation;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment

#require(shadows.fs)
#require(range.glsl)

void main() {
    vec2 st = floor((vUv * uTextureTile + uTextureScroll) * uPixellation) / uPixellation;
    vec4 color = texture2D(tMap, st);
    color *= (step(0.5, getShadow(vPos)) + 0.5) / 1.5;

    float distanceFog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color.rgb = mix(color.rgb, uFogColor, distanceFog);

    gl_FragColor = color;
}{@}NeonRailing.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uBrightness;
uniform float uOffset;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uTint4;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec2 uTile;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;
varying vec4 vRandom;

#!SHADER: Vertex
void main() {
    vec3 pos = position + normal * uOffset;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec4 tex = texture2D(tMap, vUv * uTile);
    vec3 color = vec3(0.0);

    color += tex.r * uTint1;
    color += tex.g * uTint2;
    color += tex.b * uTint3;

    color *= uBrightness;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    fog = clamp(fog, 0.0, 1.0);

    color += mix(color.rgb, uFogColor, fog) * (tex.r + tex.g + tex.b) * 2.0;
    color *= (1.0 - fog);
    
    gl_FragColor = vec4(color, 1.0);
}{@}NeonSign.glsl{@}#!ATTRIBUTES
attribute vec2 uv2;

#!UNIFORMS
uniform sampler2D tMap;
uniform float uBrightness;
uniform float uOffset;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uTint4;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec2 uTile;

#!VARYINGS
varying vec2 vUv;
varying vec2 vUv2;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;
varying vec4 vRandom;

#!SHADER: Vertex
void main() {
    vec3 pos = position + normal * uOffset;
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
    vUv2 = uv2;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec4 tex = texture2D(tMap, vUv * uTile);
    vec3 color = vec3(0.0);

    vec3 glowColor1 = uTint1;
    glowColor1 = mix(glowColor1, uTint2, floor(vUv2.x * 4.1));

    vec3 glowColor2 = uTint2;
    glowColor2 = mix(glowColor2, uTint3, floor(vUv2.y * 4.1));

    vec3 glowColor3 = uTint3;
    glowColor3 = mix(glowColor3, uTint4, floor(vUv2.x + vUv2.y - 0.01));

    color += tex.r * glowColor1;
    color += tex.g * glowColor2;
    color += tex.b * glowColor3;

    color *= uBrightness;

    // color = tex.rgb;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    fog = clamp(fog, 0.0, 1.0);

    color += mix(color.rgb, uFogColor, fog) * (tex.r + tex.g + tex.b) * 2.0;
    color *= (1.0 - fog);
    // color.rgb = mix(color.rgb, uFogColor, fog);
    
    gl_FragColor = vec4(color, 1.0);
}{@}NeonSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uRange;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    vec3 color = mix(uColor1, uColor2, gradient);
    gl_FragColor = vec4(color, gradient);
}{@}PBRRoadSurfaceLights.glsl{@}#!ATTRIBUTES
attribute vec4 random;

#!UNIFORMS
uniform vec3 uFogColor;
uniform vec3 uShadowTint;
uniform sampler2D tOpacity;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vRandom;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;

}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)
#require(normalmap.glsl)

void main() {
    LightConfig lconfig;

    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);
    lconfig.normal = normal;

    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor(lconfig);
    pbr += getPointLightColor(lconfig);

    pbr *= mix(uShadowTint, vec3(1.0), getShadow(vPos));

    float fog = crange(vModelViewPos.z, 0.0, -210.0, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PBRSurfaceLightmap.glsl{@}#!ATTRIBUTES
attribute vec4 random;

#!UNIFORMS
uniform vec3 uFogColor;
uniform sampler2D tLightmap;
uniform vec2 uFogRange;
uniform vec3 uVerticalFogColor;
uniform vec2 uVerticalFogRange;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;
uniform vec3 uColor5;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vRandom;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    setupLight(pos, transformedNormal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
    vRandom = random;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(normalmap.glsl)

void main() {
    LightConfig lconfig;

    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);
    lconfig.normal = normal;

    vec3 lightmapColor = texture2D(tLightmap, vUv).rgb;

    setupLight();

    vec3 color = texture2D(tBaseColor, vUv).xyz;

    vec3 pbr = getPBR(color).rgb;
    pbr *= getDirectionalLightColor(lconfig);
    pbr += getPointLightColor(lconfig);

    // pbr += lightmapColor.r * 0.750 * mix(vec3(0.0, 1.0, 0.0), uLightmapColor1, vRandom.x);
    vec3 glowColor = uColor1;
    glowColor = mix(glowColor, uColor2, floor(vRandom.x * 1.5));
    glowColor = mix(glowColor, uColor3, floor(vRandom.y * 1.5));
    glowColor = mix(glowColor, uColor4, floor(vRandom.z * 1.5));
    glowColor = mix(glowColor, uColor5, floor(vRandom.w * 1.5));

    vec3 glowColor2 = uColor1;
    glowColor2 = mix(glowColor2, uColor2, floor(vRandom.w * 1.5));
    glowColor2 = mix(glowColor2, uColor3, floor(vRandom.y * 1.5));
    glowColor2 = mix(glowColor2, uColor4, floor(vRandom.z * 1.5));
    glowColor2 = mix(glowColor2, uColor5, floor(vRandom.x * 1.5));

    // pbr += lightmapColor.r * mix(glowColor, glowColor2, lightmapColor.r);
    pbr += lightmapColor.r * 1.2 * glowColor + uFogColor * (1.0 - lightmapColor.g) * 0.2;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    float verticalFog = crange(vPos.y, uVerticalFogRange.x, uVerticalFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uVerticalFogColor, verticalFog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}RainParticle.glsl{@}#!ATTRIBUTES
attribute vec4 random;

#!UNIFORMS
uniform float uSize;
uniform vec2 uSizeRand;
uniform float uAlpha;
uniform vec2 uCameraFade;
uniform vec2 uAlphaRand;
uniform vec2 uDistFade;
uniform sampler2D tMap;
uniform sampler2D tPrevPos;
uniform vec3 uColor;
uniform float DPR;

#!VARYINGS
varying float vAlpha;
varying vec4 vRandom;
varying float vAngle;

#!SHADER: Vertex

#require(range.glsl)

void main() {
    vec4 decodedPos = texture2D(tPos, position.xy);
    vec3 prevPos = texture2D(tPrevPos, position.xy).xyz;
    vec3 pos = decodedPos.xyz;
    vec3 velocity = pos - prevPos;
//    velocity = vec3(uCameraMatrix * vec4(velocity, 1.0));

    vAngle = -atan(velocity.y, velocity.x);

    float dist = length(pos - cameraPosition);
    vRandom = random;

    vAlpha = uAlpha * crange(random.y, 0.0, 1.0, uAlphaRand.x, uAlphaRand.y);
    vAlpha *= crange(dist, uCameraFade.x, uCameraFade.x + uCameraFade.y, 0.0, 1.0);
    vAlpha *= crange(dist, uDistFade.x, uDistFade.x + uCameraFade.y, 1.0, 0.0);
    vAlpha *= crange(pos.y, 0.3, 0.15, 1.0, 0.0);

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    gl_PointSize = 0.02 * DPR * uSize * crange(random.x, 0.0, 1.0, uSizeRand.x, uSizeRand.y) * (1000.0 / length(mvPosition.xyz));
    gl_Position = projectionMatrix * mvPosition;
}

#!SHADER: Fragment

#require(transformUV.glsl)

void main() {
    vec2 uv = vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y);
    uv = rotateUV(uv, vAngle);

    vec2 map = texture2D(tMap, uv).rg;
    float mask = mix(map.r, map.g, vRandom.w);

    float alpha = vAlpha * mask;
    if (alpha < 0.002) discard;

    gl_FragColor = vec4(uColor, alpha);
}{@}Blimp.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uPixellation;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    vec3 pos = vec3(position.x, position.y + sin(time), position.z);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = pos;
}

#!SHADER: Fragment
void main() {
    vec2 st = floor((vUv) * uPixellation) / uPixellation;
    vec4 tex = texture2D(tMap, st);

    float mainMask = tex.r;
    vec3 color = vec3(0.0);
    color += tex.r * uTint1;
    color += tex.g * uTint2;
    color += tex.b * uTint3;

    gl_FragColor = vec4(color, 1.0);
}{@}PBROldNSXRetro.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tColor;
uniform sampler2D tWindowMask;
uniform sampler2D tWindowReflection;
uniform sampler2D tLookupTexture;
uniform vec2 uResolution;
uniform vec2 uTile;
uniform vec3 uWindowTint1;
uniform vec3 uWindowTint2;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
#require(pbr.vs)
void main() {
    setupPBR(position);
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * mvPosition;
    vMVPosition = mvPosition;
    vPos = position;
}

#!SHADER: Fragment
#require(carpbr.fs)
#require(range.glsl)
#require(lut.fs)
void main() {
    vec2 st = (gl_FragCoord.xy/uResolution.xy) * uTile;
    vec4 color = texture2D(tColor, vUv);
//     vec3 pbr = lookup(getPBR(), tLookupTexture).rgb;

    PBRConfig config;
    config.clearcoat = 1.0;
    config.darken = 1.0;
    config.reflection = 1.0;
    config.color = vec3(1.0);
    vec3 pbr = getPBR().rgb;
    vec3 clearCoat = getPBR(vec3(1.0), config).rgb;
    pbr += smoothstep(vec3(0.7), vec3(0.75), clearCoat) * 0.1;

    gl_FragColor = vec4(pbr, 1.0);
}{@}RetroCheckpoint.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec4 mask = texture2D(tMap, vUv);
    vec3 color = vec3(0.0);
    color += mask.r * uTint1;
    color += mask.g * uTint2;
    color += mask.b * uTint3;

    gl_FragColor = vec4(color, mask.a);
}{@}RetroClouds.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform vec2 uRange;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uTint4;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec3 tex = texture2D(tMap, vUv * uTile + uScroll).rgb;
    float a = clamp(tex.r + tex.g, 0.0, 1.0);
    vec3 color = vec3(0.0) + tex.r * uTint1 + tex.g * uTint2;

    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    vec3 gradientColor = mix(uTint3, uTint4, gradient);

    gl_FragColor = vec4(color + gradientColor, a);
}{@}RetroCoast.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tLUT;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uSky;
uniform vec2 uBlendRange;
uniform float uClipHeight;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex

#require(range.glsl)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    pos.y = max(pos.y, uClipHeight);
    setupLight(pos, transformedNormal);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vPos = pos;
}

#!SHADER: Fragment

#require(lighting.fs)
#require(rgb2hsv.fs)
#require(lut.fs)

void main() {
    vec3 st = vPos * vec3(uBlendRange.x, uBlendRange.y, uBlendRange.x);
    float coastline = step(0.5, st.y);
    vec3 color = mix(uTint1, uTint2, coastline);

    float volume = getDirectionalLightColor().r;
    color = rgb2hsv(color);
    color.z *= volume;
    color = hsv2rgb(color);
    color *= uSky;

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor = lookup(gl_FragColor, tLUT);
}{@}RetroMountains.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTile;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec2 st = vUv * uTile;
    float pixellation = 512.0 * 56.0;
    st = floor(st * pixellation) / pixellation;
    vec4 color = texture2D(tMap, st);
    gl_FragColor = color;
    gl_FragColor.a = color.r;
}{@}RetroRailing.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tNormal;
uniform sampler2D tOpacity;
uniform sampler2D tLUT;
uniform vec2 uTile;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uSky;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(normalmap.glsl)
#require(lut.fs)
void main() {

    // Road surface
    vec2 st = vUv * uTile;
    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, st);

    vec3 lightdir = vec3(0.0, 1.0, 1.0);
    float dp = dot(normal, lightdir);

    vec3 color = vec3(dp);
    color = mix(uTint1, uTint2, color.r);
    color *= uSky;

    vec4 opacity = texture2D(tOpacity, st);

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor = vec4(lookup(gl_FragColor, tLUT).rgb, opacity.r);
}{@}RetroRoad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tLUT;
uniform vec2 uTile;
uniform vec2 uEdgeGradient;
uniform float uEdgeSolid;
uniform float uStep;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uTint4;
uniform vec3 uTint5;
uniform vec3 uShadowTint;
uniform vec3 uLineColor;
uniform vec3 uSky;
uniform float uLineWidth;
uniform float uLineWidthCenter;
uniform float uLineLength;
uniform float uLineCount;
uniform float uInnerEdgeWidth;
uniform float uInnerEdgeDistance;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment

#require(shadows.fs)
#require(lut.fs)
#require(range.glsl)
#require(simplenoise.glsl)

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

float getGradient(vec2 edgeGradient, vec2 uv) {
    float leftGradient = smoothstep(edgeGradient.x, edgeGradient.y, uv.x);
    float rightGradient = 1.0 - smoothstep(1.0 - edgeGradient.y, 1.0 - edgeGradient.x, uv.x);
    float centerGradient = 1.0 - leftGradient * rightGradient;
    return centerGradient;
}

void main() {

    // Road surface
    vec2 st = vUv * uTile;
    vec2 ipos = floor(st);

    float centerGradient = getGradient(uEdgeGradient, vUv);
    float edgeGradient = getGradient(uEdgeGradient * 0.35, vUv + vec2(0.0, 10.0));

    vec3 mask = vec3(random( ipos ));
    vec3 mask2 = mask;

    mask *= centerGradient;
    mask = floor(mask * 2.0);

    mask2 *= edgeGradient;
    mask2 = floor(mask2 * 2.0);

    vec3 color = mix(uTint1, uTint2, mask.r);
    color = mix(color, uTint3, mask2.r);

    // Center line
    centerGradient = getGradient(vec2(0.0, 0.5), vUv);

    edgeGradient = step(uLineWidthCenter, centerGradient);
    centerGradient = step(uLineWidth, centerGradient);
    float lineMask = centerGradient - edgeGradient;
    lineMask *= sin(st.y * uLineCount);
    lineMask = step(uLineLength, lineMask);

    // Solid edge
    edgeGradient = getGradient(vec2(0.0, 0.5), vUv);
    float edgeSolid = 1.0 - step(uEdgeSolid, edgeGradient);

    // Inner edge
    edgeGradient = getGradient(vec2(0.0, 0.5), vUv);
    float innerEdge = (1.0 - step(uEdgeSolid - uInnerEdgeWidth, edgeGradient)) + step(uEdgeSolid - uInnerEdgeWidth / 2.0, edgeGradient);
    
    // Combine colors
    color = mix(color, uLineColor, lineMask);   // combine road surface and line
    color = mix(uTint4, color, edgeSolid);      // add solid edge
    color = mix(uTint5, color, innerEdge);      // add inner edge
    color *= uSky;

    // float distanceFog = crange(vModelViewPos.z, -2.0, -3.0, 1.0, 0.0);
    // color *= distanceFog;
    float shadow = getShadow(vPos);
    shadow = (step(0.5, shadow) + 0.5) / 1.5;

    color = mix(uShadowTint, color, shadow);
    gl_FragColor = vec4(color, 1.0);
//    gl_FragColor = lookup(gl_FragColor, tLUT);
}{@}RetroRoad2.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform float uTile;

uniform vec3 uRoadTint;
uniform vec3 uRoadBandTint;
uniform float uRoadBandCount;
uniform float uRoadBandWidth;

uniform vec3 uCenterLineTint;
uniform float uCenterLineWidth;
uniform float uCenterLineLength;
uniform float uCenterLineCount;

uniform vec3 uStripedEdgeTint1;
uniform vec3 uStripedEdgeTint2;
uniform float uStripedEdgeWidth;
uniform float uStripedEdgeLength;
uniform float uStripedEdgeCount;
uniform vec3 uStripedEdgeShadowTint;
uniform float uStripedEdgeShadowWidth;
uniform float uStripedEdgeShadowThickness;

uniform vec3 uDirtEdgeTint;
uniform float uDirtEdgeWidth;

uniform vec3 uShadowTint;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(shadows.fs)
#require(range.glsl)
void main() {
    vec2 st = vUv * vec2(1.0, uTile);

    // road
    float roadBands = abs(sin(st.y * uRoadBandCount));
    roadBands = step(1.0 - uRoadBandWidth, roadBands);
    vec3 roadColor = mix(uRoadTint, uRoadBandTint, roadBands);

    // center line
    float centerLine = 1.0 - abs((st.x - 0.5) * 2.0);
    centerLine = step(1.0 - uCenterLineWidth, centerLine);

    float centerLineDots = abs(sin(st.y * uCenterLineCount));
    centerLineDots = step(1.0 - uCenterLineLength, centerLineDots);
    centerLine *= centerLineDots;

    // striped edge

    float stripedEdgeMask = abs((st.x - 0.5) * 2.0);
    stripedEdgeMask = step(1.0 - uStripedEdgeWidth, stripedEdgeMask);

    float stripedEdgeDots = abs(sin(st.y * uStripedEdgeCount));
    stripedEdgeDots = step(1.0 - uStripedEdgeLength, stripedEdgeDots);
    float stripeMask = stripedEdgeMask * stripedEdgeDots;

    vec3 stripedEdge = mix(uStripedEdgeTint1, uStripedEdgeTint2, stripeMask);
    stripedEdge *= stripedEdgeMask;

    float stripedEdgeShadow = abs((st.x - 0.5 + uStripedEdgeShadowWidth) * 2.0);
    stripedEdgeShadow = 1.0 - step(1.0 - uStripedEdgeShadowThickness, stripedEdgeShadow);

    stripedEdge *= mix(vec3(1.0), uStripedEdgeShadowTint, stripedEdgeShadow);

    // dirt edge
    float dirtEdgeMask = abs((st.x - 0.5) * 2.0);
    dirtEdgeMask = step(1.0 - uDirtEdgeWidth, dirtEdgeMask);

    // mix
    vec3 color = mix(roadColor, uCenterLineTint, centerLine);
    color = mix (color, stripedEdge, stripedEdgeMask);
    color = mix(color, uDirtEdgeTint, dirtEdgeMask);

    float shadow = getShadow(vPos);
    shadow = (step(0.5, shadow) + 0.5) / 1.5;
    color = mix(uShadowTint, color, shadow);

    // vec3 color = stripedEdge;
    // color = vec3(dirtEdgeMask);
    gl_FragColor = vec4(color, 1.0);
}{@}RetroTree.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tLUT;
uniform vec2 uRange;
uniform vec2 uDistanceRange;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uBaseTint;
uniform vec3 uSky;
uniform float uBands;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex

#require(range.glsl)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    vec4 worldPos = modelMatrix * vec4(pos, 1.0);
    // pos.x += sin(time * 1.0 + pos.y * 0.12 + worldPos.z) * 2.0 * pos.y * 0.05; + sin(time * 1.21 + pos.y * 0.05) * 1.0 * pos.y * 0.06;
    pos.y += sin(time * 5.0 + uv.x * 4.0 + uv.y * 2.0 + worldPos.z) * crange(uv.y, 0.5, 1.0, 0.0, 1.0) * 0.1;
    vModelViewPos = modelViewMatrix * vec4(pos, 1.0);

    vec3 transformedNormal = normal;
    setupLight(pos, transformedNormal);

    gl_Position = projectionMatrix * vModelViewPos;
    vUv = uv;
    vPos = pos;
}

#!SHADER: Fragment

#require(range.glsl)
#require(lighting.fs)
#require(rgb2hsv.fs)
#require(lut.fs)

void main() {
    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    vec3 color = mix(uTint2, uBaseTint, gradient);
    float mixfactor = floor(crange(vModelViewPos.z, uDistanceRange.x, uDistanceRange.y, 0.0, 1.0) * uBands) / uBands;
    color.rgb = mix(color.rgb, uTint1, mixfactor);

    float volume = getDirectionalLightColor().r;
    color = rgb2hsv(color);
    color.z *= volume;
    color = hsv2rgb(color);

    color *= uSky;

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor = lookup(gl_FragColor, tLUT);

    // gl_FragColor = vec4(vec3(gradient), 1.0);
}{@}RetroWater.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform sampler2D tWaterNormal;
uniform sampler2D tLUT;
uniform mat4 uMirrorMatrix;
uniform sampler2D tMirrorReflection;
uniform float uWaterSpeed;
uniform float uUVScale;
uniform float uMirrorDistort;
uniform float uReflBlend;
uniform vec3 uReflColor;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec3 vLight;
varying vec4 vMirrorCoord;

#!SHADER: Vertex

#require(lights.vs)

void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normalMatrix * normal;
    vUv = uv;
    vPos = position;
    vLight = normalize(vec3(0.0, 1.0, 0.0));

    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    vMirrorCoord = uMirrorMatrix * worldPos;
}

#!SHADER: Fragment

#require(range.glsl)
#require(lut.fs)

vec4 getNoise(vec2 uv){
    float time = time * 0.001 * uWaterSpeed;
    vec2 uv0 = (uv/103.0)+vec2(time/17.0, time/29.0);
    vec2 uv1 = uv/107.0-vec2(time/-19.0, time/31.0);
    vec2 uv2 = uv/vec2(897.0, 983.0)+vec2(time/101.0, time/97.0);
    vec2 uv3 = uv/vec2(991.0, 877.0)-vec2(time/109.0, time/-113.0);
    float scale = uUVScale * 10.0;
    vec4 noise = (texture2D(tWaterNormal, uv0 * scale)) +
    (texture2D(tWaterNormal, uv0 * scale)) +
    (texture2D(tWaterNormal, uv0 * scale)) +
    (texture2D(tWaterNormal, uv0 * scale));
    return noise*0.5-1.0;
}

void main() {
    vec4 noise = getNoise(vUv);
    vec3 waternormal = normalize(noise.xzy * vec3(2.0, 1.0, 2.0));

    vec4 mirrorCoord = vMirrorCoord;
    mirrorCoord.xz += waternormal.xy * uMirrorDistort;

    vec4 reflection = texture2D(tMirrorReflection, mirrorCoord.xy / mirrorCoord.w);
    float mask = reflection.a;

    float volume = dot(vLight, waternormal);
    vec3 color = mix(uTint1, uTint2, step(volume, 0.6));
    color *= mix(vec3(1.0), mix(uReflColor, color, uReflBlend), mask);
    color *= uTint;

    gl_FragColor = vec4(color, 1.0);
}{@}PBRSnowRoad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)

void main() {
    setupLight();
    vec3 pbr = getPBR().rgb;
    vec4 mro = texture2D(tMRO, vUv);
    if (mro.a < 0.5) discard;
    pbr *= getDirectionalLightColor();
    pbr *= (getShadow(vPos) + 0.5) / 1.5;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);

    gl_FragColor = vec4(vec3(mro.r), mro.a);
}{@}PBRSnowSurface.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uFogColor;
uniform vec2 uFogRange;
uniform vec2 uFogBottomRange;
uniform vec2 uFogTopRange;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    vec3 transformedNormal = normal;
    setupLight(pos, transformedNormal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = pos;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)

void main() {
    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor();

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogTopRange.x, uFogTopRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogBottomRange.x, uFogBottomRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, 1.0 - fog);

    gl_FragColor = vec4(pbr, 1.0);
}{@}RDXFog.glsl{@}#!ATTRIBUTES
attribute vec3 lookup;
attribute vec4 random;

#!UNIFORMS
uniform sampler2D tPos;
uniform sampler2D tMap;
uniform vec4 uQuat;
uniform float uAlpha;
uniform float uScale;
uniform float uNoiseScale;
uniform float uNoiseStrength;
uniform float uNoiseTime;
uniform vec3 uColor;
uniform vec2 uDist;
uniform vec2 uDist2;

#!VARYINGS
varying vec4 vRandom;
varying vec3 vPos;
varying vec2 vUv;
varying float vAlpha;

#!SHADER: Vertex

#require(instance.vs)
#require(rotation.glsl)
#require(range.glsl)

void main() {
    vec3 offset = texture2D(tPos, lookup.xy).xyz;
    vec3 pos = transformPosition(position, offset, uScale, uQuat);

    vUv = uv;
    vRandom = random;
    vAlpha = uAlpha * 0.1 * crange(vRandom.w, 0.2, 1.0, 0.5, 1.0);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

    vPos = pos;
}

#!SHADER: Fragment

#require(range.glsl)
#require(transformUV.glsl)
#require(simplenoise.glsl)

vec2 getUV() {
    float noise = cnoise((vPos * uNoiseScale) + time*uNoiseTime);
    float scale = 1.0 + (noise * uNoiseStrength * 0.1);

    return scaleUV(vUv, vec2(scale));
}

void main() {

    float mask = texture2D(tMap, vUv).r;
//    float padding = 0.3;
//    mask *= crange(vUv.x, 0.0, padding, 0.0, 1.0) * crange(vUv.x, 1.0 - padding, 1.0, 1.0, 0.0);
//    mask *= crange(vUv.y, 0.0, padding, 0.0, 1.0) * crange(vUv.y, 1.0 - padding, 1.0, 1.0, 0.0);

    float alpha = mask * vAlpha;
    float clen = length(cameraPosition - vPos);
    alpha *= crange(clen, uDist.x, uDist.x + uDist.y, 1.0, 0.0);
    alpha *= crange(clen, uDist2.x, uDist2.x + uDist2.y, 0.0, 1.0);

    if (alpha < 0.001) discard;

    gl_FragColor = vec4(uColor, alpha);
}{@}Rock.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tNormal;
uniform vec2 uFogRange;
uniform vec2 uFogBottomRange;
uniform vec2 uFogTopRange;
uniform vec3 uFogColor;
uniform vec3 uColor;
uniform float uColorFactor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vNormal = normal;
    vModelViewPos = modelViewMatrix * vec4(pos, 1.0);


    setupLight(pos, normal);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vUv = uv;
}

#!SHADER: Fragment

#require(lighting.fs)
#require(normalmap.glsl)
#require(range.glsl)

void main() {
    // discard;
    LightConfig lconfig;

    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);
    lconfig.normal = normal;

    setupLight();
    vec4 color = vec4(1.0);
    color.rgb *= getDirectionalLightColor(lconfig);

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogTopRange.x, uFogTopRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogBottomRange.x, uFogBottomRange.y, 0.0, 1.0);

    color.rgb = mix(color.rgb, uColor, uColorFactor);
    color = mix(color, vec4(uFogColor, 1.0), 1.0 - fog);

    gl_FragColor = color;
}{@}Snow.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec2 uFogBottomRange;
uniform vec2 uFogTopRange;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vMvPosition;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    // vNormal = normalMatrix * normal;
    setupLight(pos, normal);
    gl_Position = projectionMatrix * mvPosition;
    vUv = uv;
    vMvPosition = mvPosition;
}

#!SHADER: Fragment
#require(lighting.fs)
#require(range.glsl)
void main() {
    setupLight();
    vec4 color = vec4(1.0);
    color.rgb *= getDirectionalLightColor();

    float fog = crange(vMvPosition.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogTopRange.x, uFogTopRange.y, 0.0, 1.0);
    fog *= crange(vPos.y, uFogBottomRange.x, uFogBottomRange.y, 0.0, 1.0);
    color = mix(color, vec4(0.8, 0.8, 0.8, 1.0), 1.0 - fog);
    // color.rgb = vec3(fog);
    
    gl_FragColor = color;
}{@}SnowParticle.glsl{@}#!ATTRIBUTES
attribute vec4 random;

#!UNIFORMS
uniform float uSize;
uniform vec2 uSizeRand;
uniform float uAlpha;
uniform vec2 uCameraFade;
uniform vec2 uAlphaRand;
uniform vec2 uDistFade;
uniform sampler2D tMap;
uniform vec3 uColor;
uniform float DPR;

#!VARYINGS
varying float vAlpha;
varying vec4 vRandom;

#!SHADER: Vertex

#require(range.glsl)

void main() {
    vec4 decodedPos = texture2D(tPos, position.xy);
    vec3 pos = decodedPos.xyz;

    float dist = length(pos - cameraPosition);
    vRandom = random;

    vAlpha = uAlpha * crange(random.y, 0.0, 1.0, uAlphaRand.x, uAlphaRand.y);
    vAlpha *= crange(dist, uCameraFade.x, uCameraFade.x + uCameraFade.y, 0.0, 1.0);
    vAlpha *= crange(dist, uDistFade.x, uDistFade.x + uCameraFade.y, 1.0, 0.0);
    vAlpha *= crange(pos.y, 0.3, 0.15, 1.0, 0.0);

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    gl_PointSize = 0.02 * DPR * uSize * crange(random.x, 0.0, 1.0, uSizeRand.x, uSizeRand.y) * (1000.0 / length(mvPosition.xyz));
    gl_Position = projectionMatrix * mvPosition;
}

#!SHADER: Fragment

#require(transformUV.glsl)

void main() {
    vec2 uv = vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y);
    uv = rotateUV(uv, radians(360.0 * vRandom.z));
    vec2 map = texture2D(tMap, uv).rg;
    float mask = mix(map.r, map.g, vRandom.w);

    float alpha = vAlpha * mask;
    if (alpha < 0.002) discard;

    gl_FragColor = vec4(uColor, alpha);
}{@}SnowParticleSpawn.glsl{@}#!ATTRIBUTES
attribute vec4 random;

#!UNIFORMS
uniform float uSize;
uniform vec2 uSizeRand;
uniform float uAlpha;
uniform vec2 uAlphaRand;
uniform sampler2D tMap;
uniform vec3 uColor;
uniform float DPR;

#!VARYINGS
varying float vAlpha;
varying vec4 vRandom;

#!SHADER: Vertex

#require(range.glsl)

void main() {
    vec4 decodedPos = texture2D(tPos, position.xy);
    vec3 pos = decodedPos.xyz;

    float dist = length(pos - cameraPosition);
    vRandom = random;

    vAlpha = uAlpha * crange(random.y, 0.0, 1.0, uAlphaRand.x, uAlphaRand.y);

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    gl_PointSize = 0.02 * DPR * uSize * crange(random.x, 0.0, 1.0, uSizeRand.x, uSizeRand.y) * (1000.0 / length(mvPosition.xyz));
    gl_Position = projectionMatrix * mvPosition;
}

#!SHADER: Fragment

#require(transformUV.glsl)

void main() {
    vec2 uv = vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y);
    uv = rotateUV(uv, radians(360.0 * vRandom.z));
    vec2 map = texture2D(tMap, uv).rg;
    float mask = mix(map.r, map.g, vRandom.w);

    float alpha = vAlpha * mask;
    if (alpha < 0.002) discard;

    gl_FragColor = vec4(uColor, alpha);
}{@}SnowRoad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTextureTile;
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment

#require(shadows.fs)
#require(range.glsl)

void main() {
    vec4 color = texture2D(tMap, vUv * uTextureTile);
    color *= (getShadow(vPos) + 0.5) / 1.5;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 1.0, 0.0);

    color = mix(color, vec4(0.8, 0.8, 0.8, 1.0), fog);

    gl_FragColor = color;
}{@}WinterSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform float uMix;
uniform vec2 uRange;
uniform vec2 uFogRange;
uniform vec3 uFogColor1;
uniform vec3 uFogColor2;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec2 st = (vUv + uScroll) * uTile;
    vec4 skytexture = texture2D(tMap, st);

    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    vec3 skygradient = mix(uTint1, uTint2, gradient);

    vec3 color = mix(skytexture.rgb, skygradient, uMix);

    float gradient2 = crange(vUv.y, uFogRange.x, uFogRange.y, 0.0, 1.0);
    vec3 fogColor = mix(uFogColor1, uFogColor2, gradient2);
    color = mix(color, fogColor, 1.0 - gradient2);

    gl_FragColor = vec4(color, 1.0);
}{@}PBRStructure.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec2 uRangeTop;
uniform vec2 uRangeBottom;
uniform vec2 uRangeTopEdge;
uniform float uLineFrequency;
uniform float uLineSpeed;
uniform float uLineOffset;
uniform float uLightBrightness;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)
#require(lighting.vs)

void main() {
    vec3 pos = position;
    setupLight(pos, normal);
    setupPBR(pos);
    vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(lighting.fs)
#require(shadows.fs)
#require(normalmap.glsl)

void main() {
    LightConfig lconfig;

    vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);
    lconfig.normal = normal;

    setupLight();
    vec3 pbr = getPBR().rgb;
    pbr *= getDirectionalLightColor();

    float topgradient = crange(vUv.x, uRangeTop.x, uRangeTop.y, 0.0, 1.0);
    float bottomgradient = crange(vUv.x, uRangeBottom.x, uRangeBottom.y, 0.0, 1.0);
    float topedgegradient = crange(vUv.x, uRangeTopEdge.x, uRangeTopEdge.y, 0.0, 1.0);
    topgradient = clamp(topgradient * bottomgradient, 0.0, 1.0);
    vec3 lightColor = vec3(topgradient);

    
    pbr *= lightColor;

    float light = clamp(sin(vUv.y * uLineFrequency - time * uLineSpeed + uLineOffset), 0.00, 1.0);
    light += clamp(sin(vUv.y * uLineFrequency * 2.3 - time * uLineSpeed * 2.0 + uLineOffset * 3.0), 0.00, 1.0);
    light += clamp(sin(vUv.y * uLineFrequency * 1.2 - time * uLineSpeed * 2.5 + uLineOffset * 3.0), 0.00, 1.0);
    
    light = pow(light, 2.0);
    light *= uLightBrightness;
    light *= topgradient;
    light *= bottomgradient;
    light += topedgegradient;

    pbr += mix(uTint1, uTint2, light);
    pbr *= uTint3;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    pbr = mix(pbr, uFogColor, fog);
    pbr += getPointLightColor(lconfig);

    gl_FragColor = vec4(pbr, 1.0);
}{@}TypeSSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uRange;
uniform vec2 uRange2;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform vec3 uSkyTint1;
uniform vec3 uSkyTint2;
uniform vec3 uSkyTint3;
uniform vec3 uGroundTint;
uniform vec3 uCloudTint;
uniform float uBands;
uniform vec2 uHighlightRange;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = pos;
}

#!SHADER: Fragment

#require(range.glsl)

void main() {
    vec4 clouds = texture2D(tMap, vUv * uTile + uScroll);

    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    gradient = floor(gradient * uBands) / uBands;

    vec3 sky = mix(uSkyTint1, uSkyTint2, gradient);
    vec3 color = sky;
    // color = mix(color, uCloudTint, clouds.r * step(0.5, vUv.y));

    gradient = crange(vUv.y, uHighlightRange.x, uHighlightRange.y, 0.0, 1.0);
    color += (1.0 - gradient);

    float gradient2 = crange(vUv.y, uRange2.x, uRange2.y, 0.0, 1.0);
    gradient2 = pow(gradient2, 2.0);
    color = mix(color, uSkyTint3, gradient2);

    gl_FragColor = vec4(color, 1.0);
}{@}Road.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTextureTile;
uniform vec2 uTextureScroll;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment

#require(shadows.fs)
#require(range.glsl)

void main() {
    vec4 color = texture2D(tMap, vUv * uTextureTile + uTextureScroll);
    color *= (getShadow(vPos) + 1.0) / 2.0;

    // float distanceFog = crange(vModelViewPos.z, -2.0, -3.0, 1.0, 0.0);
    // color *= distanceFog;

    gl_FragColor = color;
}{@}TestRoad.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uTextureTile;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
#require(lighting.vs)
#require(lights.vs)
void main() {
    vec3 pos = position;
    vNormal = normalMatrix * normal;
    setupLight(pos, vNormal);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vUv = uv;
}

#!SHADER: Fragment
#require(lighting.fs)
#require(shadows.fs)
void main() {
    setupLight();
    vec4 tex = texture2D(tMap, vUv * uTextureTile);
    vec4 color = tex;
    color.rgb *= getDirectionalLightColor();
    color.rgb *= (getShadow(vPos) + 1.0) / 2.0;
    gl_FragColor = color;
}{@}RetroSky.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uRange;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform vec3 uSkyTint1;
uniform vec3 uSkyTint2;
uniform vec3 uGroundTint;
uniform vec3 uCloudTint;
uniform float uBands;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = pos;
}

#!SHADER: Fragment

#require(range.glsl)

void main() {
    vec4 clouds = texture2D(tMap, vUv * uTile + uScroll);

    float gradient = crange(vPos.y * 0.3 + 0.5, uRange.x, uRange.y, 0.0, 1.0);
    gradient = floor(gradient * uBands) / uBands;

    vec3 sky = mix(uSkyTint1, uSkyTint2, gradient);
    vec3 color = mix(sky, uGroundTint, 1.0 - step(0.5, vUv.y));
    color = mix(color, uCloudTint, clouds.r * step(0.5, vUv.y));
    gl_FragColor = vec4(color, 1.0);
}{@}RetroSky2.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uRange;
uniform vec2 uRange2;
uniform vec2 uTile;
uniform vec2 uScroll;
uniform vec3 uSkyTint1;
uniform vec3 uSkyTint2;
uniform vec3 uSkyTint3;
uniform vec3 uGroundTint;
uniform vec3 uCloudTint;
uniform float uBands;
uniform vec2 uHighlightRange;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = pos;
}

#!SHADER: Fragment

#require(range.glsl)

void main() {
    vec4 clouds = texture2D(tMap, vUv * uTile + uScroll);

    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    gradient = floor(gradient * uBands) / uBands;

    vec3 sky = mix(uSkyTint1, uSkyTint2, gradient);
    vec3 color = mix(sky, uGroundTint, 1.0 - step(0.5, vUv.y));
    color = mix(color, uCloudTint, clouds.r * step(0.5, vUv.y));

    gradient = crange(vUv.y, uHighlightRange.x, uHighlightRange.y, 0.0, 1.0);
    color += (1.0 - gradient);

    float gradient2 = crange(vUv.y, uRange2.x, uRange2.y, 0.0, 1.0);
    gradient2 = pow(gradient2, 2.0);
    color = mix(color, uSkyTint3, gradient2);

    gl_FragColor = vec4(color, 1.0);
}{@}RetroSun.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec2 uRange;
uniform vec2 uHighlightRange;
uniform float uBands;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform float uCutOff;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec2 st = floor(vUv * 256.0) / 256.0;
    float gradient = crange(st.y, uRange.x, uRange.y, 0.0, 1.0);
    gradient = floor(gradient * uBands) / uBands;

    vec3 color = mix(uTint1, uTint2, gradient);

    float dist = 1.0 - distance(st, vec2(0.5));
    dist = step(0.5, dist);

    gradient = crange(st.y, uHighlightRange.x, uHighlightRange.y, 0.0, 1.0);
    color += (1.0 - gradient);

    gl_FragColor = vec4(color, dist * step(uCutOff, st.y));
}{@}SkyGradient.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uRange;
uniform vec3 uTint1;
uniform vec3 uTint2;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment

#require(range.glsl)

void main() {
    float gradient = crange(vUv.y, uRange.x, uRange.y, 0.0, 1.0);
    vec3 sky = mix(uTint1, uTint2, gradient);
    vec4 color = vec4(sky, 1.0);
    gl_FragColor = color;
}{@}SplashVFX.fs{@}uniform float uLowerResolution;
uniform sampler2D tCRT;
uniform float uCRTScale;
uniform float uVignette;
uniform float uCollision;
uniform float uRes;
uniform vec3 uCRTBlend;
uniform vec3 uNoise;

#require(range.glsl)

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    vec3 texel = texture2D(tDiffuse, vUv).rgb;

    vec3 crt = texture2D(tCRT, vUv * uCRTScale).rgb;
    vec3 color = texel.rgb;
    color = mix(color, crt*color*uCRTBlend.x, uCRTBlend.y) * uCRTBlend.z;

    color *= crange(dist, 0.0, 0.5, 1.0, uVignette);

    gl_FragColor = vec4(color, 1.0);
}{@}PBRTestCar.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uTint;
uniform sampler2D tPaintMask;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;

#!SHADER: Vertex
#require(pbr.vs)

void main() {
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vModelViewPos = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(pbr.fs)
#require(range.glsl)
#require(shadows.fs)

void main() {
    vec4 paintMask = texture2D(tPaintMask, vUv);
    vec3 pbr = getPBR().rgb;
    pbr *= uTint;
    // pbr *= getShadow(vPos, 1.0 / 2048.0);

    gl_FragColor = vec4(pbr, 1.0);
}{@}PixelCar.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uTint1;
uniform vec3 uTint2;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec4 color = texture2D(tMap, vUv);
    color.rgb *= uTint1;
    color.rgb += uTint2;
    gl_FragColor = color;
}{@}PixelShadow.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;
uniform vec3 uTint;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    vNormal = normal;
    vUv = uv;
    vPos = position;
}

#!SHADER: Fragment
void main() {
    vec4 color = vec4(uTint, uAlpha);
    gl_FragColor = color;
}{@}AntimatterSpawn.fs{@}uniform float uMaxCount;
uniform float uSetup;
uniform float decay;
uniform vec2 decayRandom;
uniform sampler2D tLife;
uniform sampler2D tAttribs;

#require(range.glsl)

void main() {
    vec2 uv = vUv;
    #test !window.Metal
    uv = gl_FragCoord.xy / fSize;
    #endtest

    vec4 data = texture2D(tInput, uv);

    if (vUv.x + vUv.y * fSize > uMaxCount) {
        gl_FragColor = vec4(9999.0);
        return;
    }

    vec4 life = texture2D(tLife, uv);
    vec4 random = texture2D(tAttribs, uv);
    if (life.x > 0.5) {
        data.xyz = life.yzw;
        data.x -= 999.0;
    } else {
        if (data.x < -500.0) {
            data.x = 1.0;
        } else {
            data.x -= 0.005 * decay * crange(random.w, 0.0, 1.0, decayRandom.x, decayRandom.y);
        }
    }

    if (uSetup > 0.5) {
        data = vec4(0.0);
    }

    gl_FragColor = data;
}{@}Cube2Equi.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform samplerCube tCube;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = vec2( 1.- uv.x, uv.y );
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#define M_PI 3.1415926535897932384626433832795

void main() {
    vec2 uv = vUv;
    float longitude = uv.x * 2. * M_PI - M_PI + M_PI / 2.;
    float latitude = uv.y * M_PI;

    vec3 dir = vec3(
        - sin( longitude ) * sin( latitude ),
        cos( latitude ),
        - cos( longitude ) * sin( latitude )
    );

    normalize(dir);
    gl_FragColor = textureCube(tCube, dir);
}{@}AreaLights.glsl{@}mat3 transposeMat3(  mat3 m ) {
	mat3 tmp;
	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
	return tmp;
}

// Real-Time Polygonal-Light Shading with Linearly Transformed Cosines
// by Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt
// code: https://github.com/selfshadow/ltc_code/
vec2 LTC_Uv(  vec3 N,  vec3 V,  float roughness ) {
	float LUT_SIZE  = 64.0;
	float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	float LUT_BIAS  = 0.5 / LUT_SIZE;
	float dotNV = clamp( dot( N, V ), 0.0, 1.0 );
	// texture parameterized by sqrt( GGX alpha ) and sqrt( 1 - cos( theta ) )
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}

float LTC_ClippedSphereFormFactor(  vec3 f ) {
	// Real-Time Area Lighting: a Journey from Research to Production (p.102)
	// An approximation of the form factor of a horizon-clipped rectangle.
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}

vec3 LTC_EdgeVectorFormFactor(  vec3 v1,  vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	// rational polynomial approximation to theta / sin( theta ) / 2PI
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}

vec3 LTC_Evaluate(  vec3 N,  vec3 V,  vec3 P,  mat3 mInv,  vec3 rectCoords[ 4 ] ) {
	// bail if point is on back side of plane of light
	// assumes ccw winding order of light vertices
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	// construct orthonormal basis around N
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 ); // negated from paper; possibly due to a different handedness of world coordinate system
	// compute transform
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
	// transform rect
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	// project rect onto sphere
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	// calculate vector form factor
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	// adjust for horizon clipping
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );

	return vec3( result );
}{@}Lighting.glsl{@}#!ATTRIBUTES

#!UNIFORMS
struct LightConfig {
    vec3 normal;
    bool phong;
    bool areaToPoint;
    float phongAttenuation;
    float phongShininess;
    vec3 phongColor;
};

uniform sampler2D tLTC1;
uniform sampler2D tLTC2;

#!VARYINGS
varying vec3 vPos;
varying vec3 vWorldPos;
varying vec3 vNormal;
varying vec3 vViewDir;

#!SHADER: lighting.vs

void setupLight(vec3 p0, vec3 p1) { //inlinemain
    vPos = p0;
    vNormal = normalize(normalMatrix * p1);
    vWorldPos = vec3(modelMatrix * vec4(p0, 1.0));
    vViewDir = -vec3(modelViewMatrix * vec4(p0, 1.0));
}

#test !window.Metal
void setupLight(vec3 p0) {
    setupLight(p0, normal);
}
#endtest

#!SHADER: lighting.fs

#require(LightingCommon.glsl)

void setupLight() {

}
vec3 getCombinedColor(LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix, sampler2D tLTC1, sampler2D tLTC2) {
    vec3 color = vec3(0.0);

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        if (lProps.w < 1.0) continue;

        if (lProps.w < 1.1) {
            color += lightDirectional(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        } else if (lProps.w < 2.1) {
            color += lightPoint(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        } else if (lProps.w < 3.1) {
            color += lightCone(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        } else if (lProps.w < 4.1) {
            color += lightArea(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
        }
    }

    return lclamp(color);
}

vec3 getCombinedColor(LightConfig config) {
    #test !window.Metal
    return getCombinedColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
    #endtest
    return vec3(0.0);
}

vec3 getCombinedColor() {
    LightConfig config;
    config.normal = vNormal;
    return getCombinedColor(config);
}

vec3 getCombinedColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getCombinedColor(config);
}

vec3 getCombinedColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix, sampler2D tLTC1, sampler2D tLTC2) {
    LightConfig config;
    config.normal = normal;
    return getCombinedColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
}

vec3 getPointLightColor(LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec3 color = vec3(0.0);

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        if (lProps.w > 1.9 && lProps.w < 2.1) {
            color += lightPoint(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        }
    }

    return lclamp(color);
}

vec3 getPointLightColor(LightConfig config) {
    #test !window.Metal
    return getPointLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
    #endtest
    return vec3(0.0);
}

vec3 getPointLightColor() {
    LightConfig config;
    config.normal = vNormal;
    return getPointLightColor(config);
}

vec3 getPointLightColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getPointLightColor(config);
}

vec3 getPointLightColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    LightConfig config;
    config.normal = normal;
    return getPointLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
}

vec3 getAreaLightColor(float roughness, LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix, sampler2D tLTC1, sampler2D tLTC2) {
    vec3 color = vec3(0.0);

    #test Lighting.fallbackAreaToPointTest()
    config.areaToPoint = true;
    #endtest

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        lData.w *= roughness;

        if (lProps.w > 3.9 && lProps.w < 4.1) {
            if (config.areaToPoint) {
                color += lightPoint(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
            } else {
                color += lightArea(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
            }
        }
    }

    return lclamp(color);
}

vec3 getAreaLightColor(float roughness, LightConfig config) {
    #test !window.Metal
    return getAreaLightColor(roughness, config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
    #endtest
    return vec3(0.0);
}


vec3 getAreaLightColor(float roughness) {
    LightConfig config;
    config.normal = vNormal;
    return getAreaLightColor(roughness, config);
}

vec3 getAreaLightColor() {
    LightConfig config;
    config.normal = vNormal;
    return getAreaLightColor(1.0, config);
}

vec3 getAreaLightColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getAreaLightColor(1.0, config);
}

vec3 getAreaLightColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix, sampler2D tLTC1, sampler2D tLTC2) {
    LightConfig config;
    config.normal = normal;
    return getAreaLightColor(1.0, config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix, tLTC1, tLTC2);
}


vec3 getSpotLightColor(LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec3 color = vec3(0.0);

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        if (lProps.w > 2.9 && lProps.w < 3.1) {
            color += lightCone(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        }
    }

    return lclamp(color);
}

vec3 getSpotLightColor(LightConfig config) {
    #test !window.Metal
    return getSpotLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
    #endtest
    return vec3(0.0);
}

vec3 getSpotLightColor() {
    LightConfig config;
    config.normal = vNormal;
    return getSpotLightColor(config);
}

vec3 getSpotLightColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getSpotLightColor(config);
}

vec3 getSpotLightColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    LightConfig config;
    config.normal = normal;
    return getSpotLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
}


vec3 getDirectionalLightColor(LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec3 color = vec3(0.0);

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        if (lProps.w > 0.9 && lProps.w < 1.1) {
            color += lightDirectional(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        }
    }

    return lclamp(color);
}

vec3 getDirectionalLightColor(LightConfig config) {
    #test !window.Metal
    return getDirectionalLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
    #endtest
    return vec3(0.0);
}

vec3 getDirectionalLightColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getDirectionalLightColor(config);
}

vec3 getDirectionalLightColor() {
    LightConfig config;
    config.normal = vNormal;
    return getDirectionalLightColor(config);
}

vec3 getDirectionalLightColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    LightConfig config;
    config.normal = vNormal;
    return getDirectionalLightColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
}

vec3 getStandardColor(LightConfig config, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec3 color = vec3(0.0);

    #pragma unroll_loop
    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 lColor = lightColor[i].rgb;
        vec3 lPos = lightPos[i].rgb;
        vec4 lData = lightData[i];
        vec4 lData2 = lightData2[i];
        vec4 lData3 = lightData3[i];
        vec4 lProps = lightProperties[i];

        if (lProps.w < 1.0) continue;

        if (lProps.w < 1.1) {
            color += lightDirectional(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        } else if (lProps.w < 2.1) {
            color += lightPoint(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
        }
    }

    return lclamp(color);
}

vec3 getStandardColor(LightConfig config) {
    #test !window.Metal
    return getStandardColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
    #endtest
    return vec3(0.0);
}

vec3 getStandardColor() {
    LightConfig config;
    config.normal = vNormal;
    return getStandardColor(config);
}

vec3 getStandardColor(vec3 normal) {
    LightConfig config;
    config.normal = normal;
    return getStandardColor(config);
}

vec3 getStandardColor(vec3 normal, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    LightConfig config;
    config.normal = normal;
    return getStandardColor(config, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);
}{@}LightingCommon.glsl{@}#require(AreaLights.glsl)

vec3 lworldLight(vec3 lightPos, vec3 localPos, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec4 mvPos = modelViewMatrix * vec4(localPos, 1.0);
    vec4 worldPosition = viewMatrix * vec4(lightPos, 1.0);
    return worldPosition.xyz - mvPos.xyz;
}

float lrange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    float oldRange = oldMax - oldMin;
    float newRange = newMax - newMin;
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin;
}

vec3 lclamp(vec3 v) {
    return clamp(v, vec3(0.0), vec3(1.0));
}

float lcrange(float oldValue, float oldMin, float oldMax, float newMin, float newMax) {
    return clamp(lrange(oldValue, oldMin, oldMax, newMin, newMax), min(newMax, newMin), max(newMin, newMax));
}

#require(Phong.glsl)

vec3 lightDirectional(LightConfig config, vec3 lColor, vec3 lPos, vec4 lData, vec4 lData2, vec4 lData3, vec4 lProps, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    vec3 lDir = lworldLight(lPos, vPos, modelViewMatrix, viewMatrix);
    float volume = dot(normalize(lDir), config.normal);

    return lColor * lcrange(volume, 0.0, 1.0, lProps.z, 1.0);
}

vec3 lightPoint(LightConfig config, vec3 lColor, vec3 lPos, vec4 lData, vec4 lData2, vec4 lData3, vec4 lProps, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    float dist = length(vWorldPos - lPos);
    if (dist > lProps.y) return vec3(0.0);

    vec3 color = vec3(0.0);

    vec3 lDir = lworldLight(lPos, vPos, modelViewMatrix, viewMatrix);

    if (config.phong) {
        color += phong(lProps.x, lColor, config.phongColor, config.phongShininess, config.phongAttenuation, config.normal, normalize(lDir), vViewDir, lProps.z);
    } else {
        float volume = dot(normalize(lDir), config.normal);
        volume = lcrange(volume, 0.0, 1.0, lProps.z, 1.0);
        float falloff = pow(lcrange(dist, 0.0, lProps.y, 1.0, 0.0), 2.0);
        color += lColor * volume * lProps.x * falloff;
    }

    return color;
}

vec3 lightCone(LightConfig config, vec3 lColor, vec3 lPos, vec4 lData, vec4 lData2, vec4 lData3, vec4 lProps, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix) {
    float dist = length(vWorldPos - lPos);
    if (dist > lProps.y) return vec3(0.0);

    vec3 lDir = lworldLight(lPos, vPos, modelViewMatrix, viewMatrix);
    vec3 sDir = degrees(-lData.xyz);
    float radius = lData.w;
    vec3 surfacePos = vWorldPos;
    vec3 surfaceToLight = normalize(lPos - surfacePos);
    float lightToSurfaceAngle = degrees(acos(dot(-surfaceToLight, normalize(sDir))));
    float attenuation = 1.0;

    vec3 nColor = lightPoint(config, lColor, lPos, lData, lData2, lData3, lProps, vPos, vWorldPos, vViewDir, modelViewMatrix, viewMatrix);

    float featherMin = 1.0 - lData2.x*0.1;
    float featherMax = 1.0 + lData2.x*0.1;

    attenuation *= smoothstep(lightToSurfaceAngle*featherMin, lightToSurfaceAngle*featherMax, radius);

    nColor *= attenuation;
    return nColor;
}

vec3 lightArea(LightConfig config, vec3 lColor, vec3 lPos, vec4 lData, vec4 lData2, vec4 lData3, vec4 lProps, vec3 vPos, vec3 vWorldPos, vec3 vViewDir, mat4 modelViewMatrix, mat4 viewMatrix, sampler2D tLTC1, sampler2D tLTC2) {
    float dist = length(vWorldPos - lPos);
    if (dist > lProps.y) return vec3(0.0);

    vec3 color = vec3(0.0);

    vec3 normal = config.normal;
    vec3 viewDir = normalize(vViewDir);
    vec3 position = -vViewDir;
    float roughness = lData.w;
    vec3 mPos = lData.xyz;
    vec3 halfWidth = lData2.xyz;
    vec3 halfHeight = lData3.xyz;

    float falloff = pow(lcrange(dist, 0.0, lProps.y, 1.0, 0.0), 2.0);

    vec3 rectCoords[ 4 ];
    rectCoords[ 0 ] = mPos + halfWidth - halfHeight;
    rectCoords[ 1 ] = mPos - halfWidth - halfHeight;
    rectCoords[ 2 ] = mPos - halfWidth + halfHeight;
    rectCoords[ 3 ] = mPos + halfWidth + halfHeight;

    vec2 uv = LTC_Uv( normal, viewDir, roughness );

    #test !!window.Metal
    uv.y = 1.0 - uv.y;
    #endtest

    vec4 t1 = texture2D(tLTC1, uv);
    vec4 t2 = texture2D(tLTC2, uv);

    mat3 mInv = mat3(
    vec3( t1.x, 0, t1.y ),
    vec3(    0, 1,    0 ),
    vec3( t1.z, 0, t1.w )
    );

    vec3 fresnel = ( lColor * t2.x + ( vec3( 1.0 ) - lColor ) * t2.y );
    color += lColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords ) * falloff * lProps.x;
    color += lColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords ) * falloff * lProps.x;

    return color;
}{@}LitMaterial.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;

#!SHADER: Vertex

#require(lighting.vs)

void main() {
    vUv = uv;
    vPos = position;
    setupLight(position);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(lighting.fs)
#require(shadows.fs)

void main() {
    setupLight();

    vec3 color = texture2D(tMap, vUv).rgb;
    color *= getShadow(vPos);

    color += getCombinedColor();

    gl_FragColor = vec4(color, 1.0);
}{@}Phong.glsl{@}float pclamp(float v) {
    return clamp(v, 0.0, 1.0);
}

float dPhong(float shininess, float dotNH) {
    return (shininess * 0.5 + 1.0) * pow(dotNH, shininess);
}

vec3 schlick(vec3 specularColor, float dotLH) {
    float fresnel = exp2((-5.55437 * dotLH - 6.98316) * dotLH);
    return (1.0 - specularColor) * fresnel + specularColor;
}

vec3 calcBlinnPhong(vec3 specularColor, float shininess, vec3 normal, vec3 lightDir, vec3 viewDir) {
    vec3 halfDir = normalize(lightDir + viewDir);
    
    float dotNH = pclamp(dot(normal, halfDir));
    float dotLH = pclamp(dot(lightDir, halfDir));

    vec3 F = schlick(specularColor, dotLH);
    float G = 0.85;
    float D = dPhong(shininess, dotNH);
    
    return F * G * D;
}

vec3 calcBlinnPhong(vec3 specularColor, float shininess, vec3 normal, vec3 lightDir, vec3 viewDir, float minTreshold) {
    vec3 halfDir = normalize(lightDir + viewDir);

    float dotNH = pclamp(dot(normal, halfDir));
    float dotLH = pclamp(dot(lightDir, halfDir));

    dotNH = lrange(dotNH, 0.0, 1.0, minTreshold, 1.0);
    dotLH = lrange(dotLH, 0.0, 1.0, minTreshold, 1.0);

    vec3 F = schlick(specularColor, dotLH);
    float G = 0.85;
    float D = dPhong(shininess, dotNH);

    return F * G * D;
}

vec3 phong(float amount, vec3 diffuse, vec3 specular, float shininess, float attenuation, vec3 normal, vec3 lightDir, vec3 viewDir, float minThreshold) {
    float cosineTerm = pclamp(lrange(dot(normal, lightDir), 0.0, 1.0, minThreshold, 1.0));
    vec3 brdf = calcBlinnPhong(specular, shininess, normal, lightDir, viewDir, minThreshold);
    return brdf * amount * diffuse * attenuation * cosineTerm;
}{@}ProtonAntimatter.fs{@}uniform sampler2D tOrigin;
uniform sampler2D tAttribs;
uniform float uMaxCount;
//uniforms

#require(range.glsl)
//requires

void main() {
    vec2 uv = vUv;
    #test !window.Metal
    uv = gl_FragCoord.xy / fSize;
    #endtest

    vec3 origin = texture2D(tOrigin, uv).xyz;
    vec4 inputData = texture2D(tInput, uv);
    vec3 pos = inputData.xyz;
    vec4 random = texture2D(tAttribs, uv);
    float data = inputData.w;

    if (vUv.x + vUv.y * fSize > uMaxCount) {
        gl_FragColor = vec4(9999.0);
        return;
    }

    //code

    gl_FragColor = vec4(pos, data);
}{@}ProtonAntimatterLifecycle.fs{@}uniform sampler2D tOrigin;
uniform sampler2D tAttribs;
uniform sampler2D tSpawn;
uniform float uMaxCount;
//uniforms

#require(range.glsl)
//requires

void main() {
    vec3 origin = texture2D(tOrigin, vUv).rgb;
    vec4 inputData = texture2D(tInput, vUv);
    vec3 pos = inputData.xyz;
    vec4 random = texture2D(tAttribs, vUv);
    float data = inputData.w;

    if (vUv.x + vUv.y * fSize > uMaxCount) {
        gl_FragColor = vec4(9999.0);
        return;
    }

    vec4 spawn = texture2D(tSpawn, vUv);

    if (spawn.x < -500.0) {
        pos = spawn.xyz;
        pos.x += 999.0;
        spawn.x = 1.0;
        gl_FragColor = vec4(pos, data);
        return;
    }

    //abovespawn
    if (spawn.x <= 0.0) {
        pos.x = 9999.0;
        gl_FragColor = vec4(pos, data);
        return;
    }

    //abovecode
    //code

    gl_FragColor = vec4(pos, data);
}{@}ProtonNeutrino.fs{@}//uniforms

#require(range.glsl)
//requires

void main() {
    //code
}{@}ProtonTube.glsl{@}#!ATTRIBUTES
attribute float angle;
attribute vec2 tuv;
attribute float cIndex;
attribute float cNumber;

#!UNIFORMS
uniform sampler2D tPos;
uniform sampler2D tLife;
uniform float radialSegments;
uniform float thickness;
uniform float taper;

#!VARYINGS
varying float vLength;
varying vec3 vNormal;
varying vec3 vViewPosition;
varying vec3 vPos;
varying vec2 vUv;
varying float vIndex;
varying float vLife;

#!SHADER: Vertex

//neutrinoparams

#require(ProtonTubesUniforms.fs)
#require(range.glsl)
#require(conditionals.glsl)

void main() {
    float headIndex = getIndex(cNumber, 0.0, lineSegments);
    float life = texture2D(tLife, getUVFromIndex(headIndex, textureSize)).x;
    vLife = life;

    vec2 iuv = getUVFromIndex(headIndex, textureSize);

    float scale = 1.0;
    //neutrinovs
    vec2 volume = vec2(thickness * 0.065 * scale);

    vec3 transformed;
    vec3 objectNormal;

    //extrude tube
    float posIndex = getIndex(cNumber, cIndex, lineSegments);
    float nextIndex = getIndex(cNumber, cIndex + 1.0, lineSegments);

    vLength = cIndex / (lineSegments - 2.0);
    vIndex = cIndex;

    vec3 current = texture2D(tPos, getUVFromIndex(posIndex, textureSize)).xyz;
    vec3 next = texture2D(tPos, getUVFromIndex(nextIndex, textureSize)).xyz;

    vec3 T = normalize(next - current);
    vec3 B = normalize(cross(T, next + current));
    vec3 N = -normalize(cross(B, T));

    float tubeAngle = angle;
    float circX = cos(tubeAngle);
    float circY = sin(tubeAngle);

    volume *= mix(crange(vLength, 1.0 - taper, 1.0, 1.0, 0.0) * crange(vLength, 0.0, taper, 0.0, 1.0), 1.0, when_eq(taper, 0.0));

    objectNormal.xyz = normalize(B * circX + N * circY);
    transformed.xyz = current + B * volume.x * circX + N * volume.y * circY;
    //extrude tube

    vec3 transformedNormal = normalMatrix * objectNormal;
    vNormal = normalize(transformedNormal);
    vUv = tuv.yx;

    vec3 pos = transformed;
    vec4 mvPosition = modelViewMatrix * vec4(transformed, 1.0);
    vViewPosition = -mvPosition.xyz;
    vPos = pos;
    gl_Position = projectionMatrix * mvPosition;

    //neutrinovspost
}

#!SHADER: Fragment
void main() {
    gl_FragColor = vec4(1.0);
}{@}ProtonTubesMain.fs{@}void main() {
    vec3 index = getData(tIndices, vUv);

    float CHAIN = index.x;
    float LINE = index.y;
    float HEAD = index.z;

    if (HEAD > 0.9) {

        //main

    } else {

        float followIndex = getIndex(LINE, CHAIN-1.0, lineSegments);
        float headIndex = getIndex(LINE, 0.0, lineSegments);
        vec3 followPos = texture2D(tInput, getUVFromIndex(followIndex, textureSize)).xyz;
        vec4 followSpawn = texture2D(tSpawn, getUVFromIndex(headIndex, textureSize));

        if (followSpawn.x <= 0.0) {
            pos.x = 9999.0;
            gl_FragColor = vec4(pos, data);
            return;
        }

        pos += (followPos - pos) * uLerp;
    }
}{@}ProtonTubesUniforms.fs{@}uniform sampler2D tIndices;
uniform float textureSize;
uniform float lineSegments;
uniform float uLerp;

vec2 getUVFromIndex(float index, float textureSize) {
    float size = textureSize;
    vec2 ruv = vec2(0.0);
    float p0 = index / size;
    float y = floor(p0);
    float x = p0 - y;
    ruv.x = x;
    ruv.y = y / size;
    return ruv;
}

float getIndex(float line, float chain, float lineSegments) {
    return (line * lineSegments) + chain;
}{@}SceneLayout.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.a *= uAlpha;
    gl_FragColor.rgb /= gl_FragColor.a;
}{@}Text3D.glsl{@}#!ATTRIBUTES
attribute vec3 animation;

#!UNIFORMS
uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;
uniform vec3 uTranslate;
uniform vec3 uRotate;
uniform float uTransition;
uniform float uWordCount;
uniform float uLineCount;
uniform float uLetterCount;
uniform float uByWord;
uniform float uByLine;
uniform float uPadding;
uniform vec3 uBoundingMin;
uniform vec3 uBoundingMax;

#!VARYINGS
varying float vTrans;
varying vec2 vUv;
varying vec3 vPos;

#!SHADER: Vertex

#require(range.glsl)
#require(eases.glsl)
#require(rotation.glsl)
#require(conditionals.glsl)

void main() {
    vUv = uv;
    vTrans = 1.0;

    vec3 pos = position;

    if (uTransition < 5.0) {
        float padding = uPadding;
        float letter = (animation.x + 1.0) / uLetterCount;
        float word = (animation.y + 1.0) / uWordCount;
        float line = (animation.z + 1.0) / uLineCount;

        float letterTrans = crange(uTransition, letter - padding, letter + padding, 0.0, 1.0);
        float wordTrans = crange(uTransition, word - padding, word + padding, 0.0, 1.0);
        float lineTrans = crange(uTransition, line - padding, line + padding, 0.0, 1.0);

        vTrans = mix(cubicOut(letterTrans), cubicOut(wordTrans), uByWord);
        vTrans = mix(vTrans, cubicOut(lineTrans), uByLine);

        float invTrans = (1.0 - vTrans);
        vec3 nRotate = normalize(uRotate);
        vec3 axisX = vec3(1.0, 0.0, 0.0);
        vec3 axisY = vec3(0.0, 1.0, 0.0);
        vec3 axisZ = vec3(0.0, 0.0, 1.0);
        vec3 axis = mix(axisX, axisY, when_gt(nRotate.y, nRotate.x));
        axis = mix(axis, axisZ, when_gt(nRotate.z, nRotate.x));
        pos = vec3(vec4(position, 1.0) * rotationMatrix(axis, radians(max(max(uRotate.x, uRotate.y), uRotate.z) * invTrans)));
        pos += uTranslate * invTrans;
    }

    vPos = pos;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment

#require(range.glsl)
#require(msdf.glsl)
#require(simplenoise.glsl)

vec2 getBoundingUV() {
    vec2 uv;
    uv.x = crange(vPos.x, uBoundingMin.x, uBoundingMax.x, 0.0, 1.0);
    uv.y = crange(vPos.y, uBoundingMin.y, uBoundingMax.y, 0.0, 1.0);
    return uv;
}

void main() {
    float alpha = msdf(tMap, vUv);

    //float noise = 0.5 + smoothstep(-1.0, 1.0, cnoise(vec3(vUv*50.0, time* 0.3))) * 0.5;

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha * vTrans;
}
{@}UnrealBloom.fs{@}uniform sampler2D tUnrealBloom;

void getUnrealBloom(inout vec4 texel, vec2 uv) {
    return texture2D(tUnrealBloom, uv).rgb;
}{@}UnrealBloomComposite.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D blurTexture1;
uniform float bloomStrength;
uniform float bloomRadius;
uniform vec3 bloomTintColor;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex.vs
void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}

#!SHADER: Fragment.fs

float lerpBloomFactor(const in float factor) {
    float mirrorFactor = 1.2 - factor;
    return mix(factor, mirrorFactor, bloomRadius);
}

void main() {
    gl_FragColor = bloomStrength * (lerpBloomFactor(1.0) * vec4(bloomTintColor, 1.0) * texture2D(blurTexture1, vUv));
}{@}UnrealBloomGaussian.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D colorTexture;
uniform vec2 texSize;
uniform vec2 direction;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex.vs
void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}

#!SHADER: Fragment.fs

float gaussianPdf(in float x, in float sigma) {
    return 0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}

void main() {
    vec2 invSize = 1.0 / texSize;
    float fSigma = float(SIGMA);
    float weightSum = gaussianPdf(0.0, fSigma);
    vec3 diffuseSum = texture2D( colorTexture, vUv).rgb * weightSum;
    for(int i = 1; i < KERNEL_RADIUS; i ++) {
        float x = float(i);
        float w = gaussianPdf(x, fSigma);
        vec2 uvOffset = direction * invSize * x;
        vec3 sample1 = texture2D( colorTexture, vUv + uvOffset).rgb;
        vec3 sample2 = texture2D( colorTexture, vUv - uvOffset).rgb;
        diffuseSum += (sample1 + sample2) * w;
        weightSum += 2.0 * w;
    }
    gl_FragColor = vec4(diffuseSum/weightSum, 1.0);
}{@}UnrealBloomLuminosity.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tDiffuse;
uniform vec3 defaultColor;
uniform float defaultOpacity;
uniform float luminosityThreshold;
uniform float smoothWidth;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex.vs
void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}

#!SHADER: Fragment.fs

#require(luma.fs)

void main() {
    vec4 texel = texture2D(tDiffuse, vUv);
    float v = luma(texel.xyz);
    vec4 outputColor = vec4(defaultColor.rgb, defaultOpacity);
    float alpha = smoothstep(luminosityThreshold, luminosityThreshold + smoothWidth, v);
    gl_FragColor = mix(outputColor, texel, alpha);
}{@}UnrealBloomPass.fs{@}#require(UnrealBloom.fs)

void main() {
    gl_FragColor = texture2D(tDiffuse, vUv);
    applyUnrealBloom(gl_FragColor, vUv);
}{@}PBRARX.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vMVPosition;

#!SHADER: Vertex
#require(pbr.vs)

void main() {
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vMVPosition = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(carcommon.fs)
#require(range.glsl)
#require(conditionals.glsl)
#require(shadows.fs)

void main() {
    // vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);

    vec4 baseColor = texture2D(tBaseColor, vUv);
    float mask = baseColor.a;
    float windows = and(when_gt(mask, 0.4), when_lt(mask, 0.6));
    float paint = when_gt(mask, 0.7);
    float reflection = clamp((paint * 0.7) + windows, 0.0, 1.0);
    vec3 color = baseColor.rgb * mix(vec3(1.0), uColor, paint);

    PBRConfig baseConfig;
    baseConfig.clearcoat = 0.0;
    baseConfig.darken = 1.0;
    baseConfig.shininess = reflection;
    baseConfig.reflection = 0.0;
    baseConfig.color = vec3(1.0);

    PBRConfig clearConfig;
    clearConfig.clearcoat = paint;
    clearConfig.darken = 1.0;
    clearConfig.shininess = 0.0;
    clearConfig.reflection = 0.0;
    clearConfig.color = vec3(1.0);

    vec3 pbr = getPBR(color, baseConfig).rgb;
    vec3 clearCoat = getPBR(vec3(1.0), clearConfig).rgb;
    pbr += smoothstep(vec3(uClearCoat.x), vec3(uClearCoat.y), clearCoat) * uClearCoat.z * mask;

    gl_FragColor = vec4(pbr, 0.0);
}{@}CarLightPBR.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform float uAlpha;

#!VARYINGS

#!SHADER: Vertex

#require(pbr.vs)

void main() {
    setupPBR(position);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(pbr.fs)

void main() {
    gl_FragColor = getPBR();
    gl_FragColor.a *= uAlpha;
}{@}PBRIntegra.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform float uLightBounce;
uniform float uAttenuation;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vMVPosition;
varying vec3 vViewDir;

#!SHADER: Vertex
#require(pbr.vs)

void main() {
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vMVPosition = modelViewPos;
    vPos = position;
    vViewDir = -vec3(modelViewMatrix * vec4(position, 1.0));
}

#!SHADER: Fragment
#require(carcommon.fs)
#require(range.glsl)
#require(phong.fs)
#require(conditionals.glsl)
#require(shadows.fs)

void main() {
    vec4 baseColor = texture2D(tBaseColor, vUv);
    baseColor.rgb *= uColor;
    vec3 normal = unpackNormal(vMVPosition.xyz, vNormal, tNormal, 1.0, 1.0, vUv); //mvPosition.xyz, normalMatrix * normal, normalMap, intensity, scale, uv

    float mask = baseColor.a;
    float windows = and(when_gt(mask, 0.4), when_lt(mask, 0.6));
    float paint = when_gt(mask, 0.7);
    float reflection = clamp((paint * 0.2) + windows*1.3, 0.0, 1.0);

    vec3 color = phong(uEnv.x, baseColor.rgb, vec3(1.0), reflection, uAttenuation, normal, normalize(uLight.xyz), vViewDir, uLightBounce);
    vec2 matuv = reflectMatcap(vMVPosition, normal);
    color += texture2D(tMatcap, matuv).rgb * reflection * uEnvReflection;

    gl_FragColor = vec4(color, 0.0);
}{@}OldNSX.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform sampler2D tMatcap;
uniform vec3 uColor;
uniform float uEnvReflection;
uniform float uGarageDeselect;

#!VARYINGS
varying vec3 vPos;
varying vec2 vUv;
varying vec2 vMUv;

#!SHADER: Vertex

#require(matcap.vs)

void main() {
    vPos = position;
    vUv = uv;
    vMUv = reflectMatcap(position, modelViewMatrix, normal);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec4 texel = texture2D(tMap, vUv);

    gl_FragColor.rgb = texel.rgb * uColor;
    gl_FragColor.a = 0.0;

    gl_FragColor.rgb += texture2D(tMatcap, vMUv).rgb * (1.0 - texel.a) * uEnvReflection;
    gl_FragColor.rgb += (1.0 - texel.a) * 0.1;

    gl_FragColor.rgb = mix(gl_FragColor.rgb, gl_FragColor.rgb*0.5, uGarageDeselect);
}{@}PBROldNSX.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vMVPosition;

#!SHADER: Vertex
#require(pbr.vs)

void main() {
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vMVPosition = modelViewPos;
    vPos = position;
}

#!SHADER: Fragment
#require(carcommon.fs)
#require(range.glsl)
#require(shadows.fs)

void main() {
    // vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);

    vec4 baseColor = texture2D(tBaseColor, vUv);
    float mask = baseColor.a;
    vec3 color = baseColor.rgb;

    PBRConfig baseConfig;
    baseConfig.clearcoat = 0.0;
    baseConfig.darken = 1.0;
    baseConfig.shininess = 1.0;
    baseConfig.reflection = 1.0;
    baseConfig.color = vec3(1.0);

    PBRConfig clearConfig;
    clearConfig.clearcoat = mask;
    clearConfig.darken = 1.0;
    clearConfig.shininess = 0.0;
    clearConfig.reflection = 1.0;
    clearConfig.color = vec3(1.0);

    vec3 pbr = getPBR(color, baseConfig).rgb;
    vec3 clearCoat = getPBR(vec3(1.0), clearConfig).rgb;
    pbr += smoothstep(vec3(uClearCoat.x), vec3(uClearCoat.y), clearCoat) * uClearCoat.z * mask;
    pbr = clamp(pbr, vec3(0.0), vec3(1.0));

    gl_FragColor = vec4(pbr, 1.0);
    gl_FragColor = lookup(gl_FragColor, tLookup);
    gl_FragColor.a = vPos.y / 1.67;
}{@}PBRRDX.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform float uBlend;

#!VARYINGS
varying vec3 vPos;
varying vec4 vModelViewPos;
varying vec4 vMVPosition;

#!SHADER: Vertex
#require(pbr.vs)

void main() {
    setupPBR(position);
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vMVPosition = modelViewPos;
    vPos = position;
}

    #!SHADER: Fragment
    #require(carcommon.fs)
    #require(range.glsl)
    #require(conditionals.glsl)
    #require(shadows.fs)

void main() {
    // vec3 normal = unpackNormal(vModelViewPos.xyz, vNormal, tNormal, 1.0, 1.0, vUv);

    vec4 baseColor = texture2D(tBaseColor, vUv);
    float mask = baseColor.a;
    vec3 color = baseColor.rgb * uColor;
    float windows = and(when_gt(mask, 0.4), when_lt(mask, 0.6));
    float paint = when_gt(mask, 0.7);
    float reflection = clamp((paint * 0.7) + windows, 0.0, 1.0);

    PBRConfig baseConfig;
    baseConfig.clearcoat = 0.0;
    baseConfig.darken = 1.0;
    baseConfig.shininess = reflection;
    baseConfig.reflection = 0.0;
    baseConfig.color = vec3(1.0);

    PBRConfig clearConfig;
    clearConfig.clearcoat = paint;
    clearConfig.darken = 1.0;
    clearConfig.shininess = 0.0;
    clearConfig.reflection = 0.0;
    clearConfig.color = vec3(1.0);

    vec3 pbr = getPBR(color, baseConfig).rgb;
    vec3 clearCoat = getPBR(vec3(1.0), clearConfig).rgb;
    pbr += smoothstep(vec3(uClearCoat.x), vec3(uClearCoat.y), clearCoat) * uClearCoat.z * mask;

    pbr = clamp(pbr, vec3(0.0), vec3(1.0));

    gl_FragColor = vec4(pbr, 1.0);
//    gl_FragColor = mix(gl_FragColor, lookup(gl_FragColor, tLookup), uBlend);
    gl_FragColor.a = 0.0;
}{@}PBRTypeS.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tCarBody;

#!VARYINGS
varying vec4 vMVPosition;

#!SHADER: Vertex

#require(pbr.vs)

void main() {
    setupPBR(position);

    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    vMVPosition = mvPosition;
    gl_Position = projectionMatrix * mvPosition;
}

#!SHADER: Fragment

#require(pbr.fs)
#require(carcommon.fs)

void main() {
    vec3 normal = unpackNormal(vMVPosition.xyz, vNormal, tNormal, 1.0, 1.0, vUv);

    vec4 carBody = texture2D(tCarBody, vUv);
    float reflective = carBody.g;
    float paint = carBody.r;

    vec3 baseColor = texture2D(tBaseColor, vUv).rgb;
//    vec3 reflection = getReflection(normal, reflective);
//    vec3 lightmap = getLightmap(normal);
//    baseColor = mix(baseColor, blendOverlay(baseColor, reflection), 0.5 * reflective);

    PBRConfig config;
    config.reflection = mix(1.0, 1.2, paint);
    config.darken = 1.0;
    config.clearcoat = paint;
    config.color = vec3(1.0);

    gl_FragColor = getPBR(baseColor, config);
}{@}AirStream.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS
varying float vLength;

#!SHADER: Vertex
void main() {

}

#!SHADER: Fragment
void main() {
    gl_FragColor = vec4(uColor, vLength * uAlpha * 0.2);
}{@}VolumetricMaskShader.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = vec4(0.0);
}{@}ChevronCheckpoint.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uRotSpeed;
uniform float uAlpha;
uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec2 uFogRange;
uniform vec3 uFogColor;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(range.glsl)

mat2 rotate2d(float angle){
    return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

void main() {
    vec2 st = vUv;
    float verticalGradient = 1.0 - crange(vUv.y, 0.5, 1.0, 0.0, 1.0);

    // move space from the center to the vec2(0.0)
    st -= vec2(0.5);
    // rotate the space
    st = rotate2d(time * uRotSpeed) * st.xy;
    // move it back to the original place
    st += vec2(0.5);

    vec4 color = texture2D(tMap, st);
    float chevronMask = 1.0;
    float lineMask = color.b;

    vec3 chevronColor = uTint1 * chevronMask;
    vec3 lineColor = uTint2 * lineMask;

    color.rgb = chevronColor + lineColor;
    color.rgb += (uTint3 * verticalGradient);
    // color.rgb /= color.a;
    color.a *= uAlpha;
    color.a *= step(0.5, vUv.y);

    color.rgb = clamp(color.rgb, 0.0, 1.0);

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    color.rgb = mix(color.rgb, uFogColor, fog);

    gl_FragColor = color;
    // gl_FragColor = vec4(verticalGradient);
}{@}FogCheckpoint.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform vec2 uFogRange;
uniform vec3 uFogColor;
uniform vec3 uTint;

#!VARYINGS
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
varying vec4 vModelViewPos;

#!SHADER: Vertex
void main() {
    vec4 modelViewPos = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewPos;
    vNormal = normal;
    vUv = uv;
    vPos = position;
    vModelViewPos = modelViewPos;
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    vec2 st = vUv;
    vec3 color = texture2D(tMap, vUv).rgb;
    color *= uTint;

    float fog = crange(vModelViewPos.z, uFogRange.x, uFogRange.y, 0.0, 1.0);
    color.rgb = mix(color.rgb, uFogColor, fog);

    gl_FragColor = vec4(color, 1.0);
}{@}PowerupShader.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uScaleY;
uniform float uAlpha;
uniform float uTimeScale;
uniform vec3 uColor;

#!VARYINGS
varying vec2 vUv;
varying float vA;

#!SHADER: Vertex

void main() {
    vUv = uv;
    vUv.y *= uScaleY;
    vUv.y -= time * uTimeScale;

    vA = uv.y;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(range.glsl)
#require(eases.glsl)

void main() {
    gl_FragColor = texture2D(tMap, vUv);

    float alpha = sineIn(crange(vA, 0.0, 0.1, 0.0, 1.0));
    alpha *= sineIn(crange(vA, 0.9, 1.0, 1.0, 0.0));

    gl_FragColor.rgb *= uColor;
    gl_FragColor.a *= alpha * uAlpha;
}{@}TutorialARXHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float dist = length( vUv - vec2( 0.5 ));
    float alpha = 1.0;
    alpha *= crange( cos( dist * 120.0 - time * 10.0 ), 0.75, 0.8, 0.0, 1.0 );
    alpha *= crange( dist, 0.3, 0.45, 0.0, 1.0 );
    alpha = crange( dist, 0.48, 0.4801, alpha, 1.0 );
    alpha *= crange( dist,  0.499, 0.5, 1.0, 0.0 );
    alpha *= uFill;
    alpha *= uAlpha;
    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha;
}{@}TutorialIcon.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uDirection;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec2 uv = vUv;
    uv.x = crange( uDirection, -1.0, 1.0, 1.0 - uv.x, uv.x );

    vec4 tex = texture2D( tMap, uv );
    tex.a *= uAlpha;

    gl_FragColor.rgb = tex.rgb;
    gl_FragColor.a = tex.a;
}{@}TutorialIntegraHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float alpha = crange( length( vUv - vec2( 0.5 )), 0.499, 0.5, 1.0, 0.0 );
    alpha *= uFill;
    alpha *= uAlpha;
    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha;
}{@}TutorialNewNSXHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uDist;
uniform float uWeight;
uniform float uFeather;
uniform float uGlow;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float dist = length( vUv - vec2( 0.5 ));

    float stroke = 1.0;
    stroke *= crange( dist, uDist + uWeight * 0.5, uDist + uWeight * 0.5 + 0.001, 1.0, 0.0 );
    stroke *= crange( dist, uDist - uWeight * 0.5, uDist - uWeight * 0.5 - 0.001, 1.0, 0.0 );

    float glow = 1.0;
    glow *= crange( dist, uDist, uDist + uFeather, 1.0, 0.0 );
    glow *= crange( dist, uDist, uDist - uFeather, 1.0, 0.0 );
    glow *= uGlow;

    float alpha = min( 1.0, stroke + glow );

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}{@}TutorialOldNSXHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float alpha = crange( length( vUv - vec2( 0.5 )), 0.499, 0.5, 1.0, 0.0 );
    alpha *= uFill;
    alpha *= uAlpha;
    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha;
}{@}TutorialRDXHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float alpha = crange( length( vUv - vec2( 0.5 )), 0.499, 0.5, 1.0, 0.0 );
    alpha *= uFill;
    alpha *= uAlpha;
    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha;
}{@}TutorialTypeSHit.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uFill;
uniform float uDist;
uniform float uWeight;
uniform float uFeather;
uniform float uGlow;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    float dist = length( vUv - vec2( 0.5 ));

    float stroke = 1.0;
    stroke *= crange( dist, uDist + uWeight * 0.5, uDist + uWeight * 0.5 + 0.001, 1.0, 0.0 );
    stroke *= crange( dist, uDist - uWeight * 0.5, uDist - uWeight * 0.5 - 0.001, 1.0, 0.0 );

    float glow = 1.0;
    glow *= crange( dist, uDist, uDist + uFeather, 1.0, 0.0 );
    glow *= crange( dist, uDist, uDist - uFeather, 1.0, 0.0 );
    glow *= uGlow;

    float alpha = min( 1.0, stroke + glow );

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}{@}RacingLineShader.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;
uniform float uScale;
uniform float uSpeed;
uniform float uAccuracy;
uniform vec3 uPos;
uniform vec2 uVisibility;
uniform float uVisMultiplier;
uniform float uHide;
uniform vec3 uTint;

#!VARYINGS
varying vec2 vUv;
varying float vAlpha;

#!SHADER: Vertex

#require(range.glsl)

void main() {
    vUv = uv;
    vUv.y *= uScale;
    vUv.y -= time * uSpeed;

    float dist = length(uPos - position);
    vAlpha = crange(dist, uVisibility.x, (uVisibility.x + uVisibility.y), 1.0, 0.0) * uAccuracy * uHide;
    vAlpha += uVisMultiplier;
    vAlpha = clamp(vAlpha, 0.0, 1.0);
    vAlpha *= uAlpha;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.rgb *= uTint;
    gl_FragColor.rgb /= gl_FragColor.a;
    gl_FragColor.a *= vAlpha;
}{@}ARXOutline.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform vec3 uColor;
uniform vec2 uEdge;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    float alpha = 0.0;

    // external border
    alpha += step(vUv.x, uEdge.x);
    alpha += step(1.0 - vUv.x, uEdge.x);
    alpha += step(vUv.y, uEdge.y);
    alpha += step(1.0 - vUv.y, uEdge.y);
    alpha = min(1.0, alpha);

    vec3 color = uColor;
    color = mix(color, uHoverColor, uHover);

    gl_FragColor = vec4(color, alpha * uAlpha);
}{@}ArxButton.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform vec3 uColor;
uniform vec2 uEdge;
uniform vec2 uInset;
uniform float uAlpha;
uniform float uHover;
uniform float uSelected;
uniform vec3 uHoverColor;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    float alpha = 0.0;

    // external border
    alpha += step(vUv.x, uEdge.x);
    alpha += step(1.0 - vUv.x, uEdge.x);
    alpha += step(vUv.y, uEdge.y);
    alpha += step(1.0 - vUv.y, uEdge.y);

    // center background
    alpha += step(uEdge.x + uInset.x, vUv.x) * step(vUv.x, 1.0 - uEdge.x - uInset.x)
    * step(uEdge.y + uInset.y, vUv.y) * step(vUv.y, 1.0 - uEdge.y - uInset.y);

    alpha = min(1.0, alpha);

    vec3 color = uColor;
    color = mix(color, uHoverColor, uHover);
    color = mix(color, uHoverColor, uSelected);

    gl_FragColor = vec4(color, alpha * uAlpha);
}{@}GameplayUIArxDefault.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform sampler2D tMask;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(displace.glsl)
void main() {
    vec2 uv = displace(vUv, tMask, 1.0 - uAlpha);

    gl_FragColor = texture2D(tMap, uv);
    gl_FragColor.a *= uAlpha;
}{@}GameplayUIArxMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform sampler2D tMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( 2.0 / uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 color = texture2D( tMapMask, vMapUV ).rgb;
    color = vec3( crange( color.r, 0.475, 0.485, 0.0, 1.0 ));
    float alpha = crange( center, 0.49, 0.5, 1.0, 0.0 );

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));

    alpha *= crange( color.r, 0.6, 0.675, 0.25, 1.0 );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIArxSpeedText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}
{@}GameplayUIArxSpeedometer.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uMax;
uniform vec3 uFill;
uniform sampler2D tMeter;
uniform float uValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(conditionals.glsl)
#require(range.glsl)

void main() {
    vec4 tex = texture2D( tMeter, vUv );
    vec3 color = mix( uFill, uMax, crange( tex.b, 0.0, 1.0, 0.0, 1.0 ));
    float speed = 1.0 - uValue;
    float alpha = tex.g *= when_ge( speed, tex.r );
    gl_FragColor = vec4( color, 1.0);
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIFigmaTestMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 color = texture2D( tMapMask, vMapUV ).rgb;
    float alpha = crange( center, 0.49, 0.5, 1.0, 0.0 );

    color = mix( color, uGhostColor, crange( ghost, 0.029 / uZoom, 0.03 / uZoom, 1.0, 0.0 ));
    color = mix( color, uPlayerColor, crange( center, 0.029, 0.03, 1.0, 0.0 ));

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha;
}{@}GameplayUIFigmaTestSpeedometer.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uMax;
uniform vec3 uBorder;
uniform vec3 uFill;
uniform sampler2D tMeter;
uniform float uValue;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(conditionals.glsl)
#require(range.glsl)
void main() {
    vec4 tex = texture2D( tMeter, vUv );

    float steps = 60.0;
    float speed = floor( 1.0 + uValue * steps ) / steps;

    vec3 color = mix( uFill, uMax, crange( tex.b, 0.0, 0.5, 0.0, 1.0 ));
    color = mix( color, uBorder, crange( tex.b, 0.5, 1.0, 0.0, 1.0 ));

    float alpha = tex.g *= when_ge( speed, tex.r );
    gl_FragColor = vec4( color, 1.0);
    gl_FragColor.a = alpha;
}{@}GameplayUIIntegraDefault.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment

void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.a *= uAlpha;
}{@}IntegraButton.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tBackground;
uniform vec3 uBorder;
uniform vec2 uEdge;
uniform float uAlpha;
uniform float uHover;
uniform float uSelected;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(rgb2hsv.fs)

void main() {
    vec2 uv = vUv;

    vec3 color = texture2D(tBackground, vUv).rgb;

    color = rgb2hsv(color);
    float hover = max( uHover, uSelected );
    color.y *= 1.0-hover;
    color.z *= 1.0+0.5*hover;
    color = hsv2rgb(color);

    float border = 0.0;
    border += step(vUv.x, uEdge.x);
    border += step(1.0 - vUv.x, uEdge.x);
    border += step(vUv.y, uEdge.y);
    border += step(1.0 - vUv.y, uEdge.y);
    border = min(1.0, border);
    color = mix(color, uBorder, border);

    gl_FragColor = vec4( color, uAlpha );
}{@}IntegraGradientText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform vec3 uBorder;
uniform float uScale;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;
varying vec2 vPixCoord;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

    vec3 ndc = gl_Position.xyz / gl_Position.w;
    vec2 viewportCoord = ndc.xy * 0.5 + 0.5;
    vPixCoord = viewportCoord * resolution;
}

#!SHADER: Fragment

#require(msdf.glsl)
#require(range.glsl)
void main() {
    float alpha = msdf(tMap, vUv);
    float outline = strokemsdf(tMap, vUv, 0.5, 0.53);

    vec3 color = mix( uColor, uBorder, outline );
    color *= vec3( 0.75 );
    color *= crange( sin( vPixCoord.y * 0.25 * uScale - time * 0.75 + cos( vPixCoord.x * 0.05 )), -1.0, 1.0, 0.8, 1.2 );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}
{@}IntegraOutlineText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform vec3 uBorder;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);
    float outline = strokemsdf(tMap, vUv, 0.5, 0.53);

    vec3 color = mix( uColor, uBorder, outline );
    color *= vec3(0.75);

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}
{@}IntegraShine.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D uTexture;
uniform float uOffset;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;
varying float vScale;

#!SHADER: Vertex
#require(range.glsl)
#require(transformUV.glsl)
void main() {
    float rate = 0.5;
    vScale = crange( cos( time * 2.0 ), -1.0, 1.0, 0.75, 1.0 );
    vUv = scaleUV( rotateUV( uv, time * rate + uOffset * 100.0 ), vec2( vScale ));
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec4 tex = texture2D(uTexture, vUv);
    vec3 color = tex.rgb;
    float alpha = crange( tex.r, 0.1, 0.8, 0.0, 1.0 );
    alpha *= crange( vScale, 0.75, 1.0, 0.5, 1.0 );
    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}IntegraTitleGradientText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uBorder;
uniform float uScale;
uniform float uAlpha;
uniform float uRate;
uniform float uOffset;

#!VARYINGS

varying vec2 vUv;
varying vec2 vPixCoord;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

    vec3 ndc = gl_Position.xyz / gl_Position.w;
    vec2 viewportCoord = ndc.xy * 0.5 + 0.5;
    vPixCoord = viewportCoord * resolution;
}

#!SHADER: Fragment

#require(msdf.glsl)
#require(range.glsl)
#require(rgb2hsv.fs)
void main() {
    float alpha = msdf(tMap, vUv);
    float outline = strokemsdf(tMap, vUv, 0.5, 0.53);

    float scale = 0.035 * ( 1.0 / uScale );
    float rate = 8.0;
    float shift = cos( time * 2.0 + vPixCoord.x * 0.0125 ) * 4.0;
    float t = time * uRate * -rate + shift + uOffset;

    float gradient1 = crange( tan(( vPixCoord.y + t ) * scale ), 0.0, 1.0, 0.0, 1.0 );
    float gradient2 = crange( tan(( vPixCoord.y + t ) * scale ), 0.0, -1.0, 0.0, 1.0 );
    float brightness = crange( sin(( vPixCoord.y + t ) * scale * 2.0 ), -1.0, 0.5, 1.5, 1.0 );
    vec3 color = mix( uColor2, uColor1, gradient1 );

    color = mix( color, uColor1, gradient2 );
    color = rgb2hsv( color );
    color.b *= brightness;
    color.g *= crange( brightness, 1.0, 1.5, 1.0, 0.5 );
    color = hsv2rgb( color );

    color = mix( color, uColor2, outline );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIIntegraMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)
#require(range.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( 2.0 / uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 color = texture2D( tMapMask, vMapUV ).rgb;
    color = vec3( crange( color.r, 0.475, 0.485, 0.0, 1.0 ));

    float alpha = 1.0;
    float icon = 0.01;

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));
    color = mix( color, uPlayerColor, crange( center, ( icon - 0.0001 ) * uZoom, icon * uZoom, 1.0, 0.0 ));

    alpha *= crange( color.r, 0.6, 0.675, 0.25, 1.0 );
    alpha = crange( center, 0.48, 0.4801, alpha, 1.0 );
    color = mix( color, vec3(0.0), crange( center, 0.48, 0.4801, 0.0, 1.0 ));
    alpha *= crange( center, 0.49, 0.5, 1.0, 0.0 );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIIntegraSpeedText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    vec3 pos = position;
    pos *= range(uAlpha, 0.0, 1.0, 1.2, 1.1);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}
{@}NewNSXButton.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform vec3 uColor;
uniform vec2 uEdge;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;
uniform float uSelected;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    float alpha = 0.0;

    // external border
    alpha += step(vUv.x, uEdge.x);
    alpha += step(1.0 - vUv.x, uEdge.x);
    alpha += step(vUv.y, uEdge.y);
    alpha += step(1.0 - vUv.y, uEdge.y);
    alpha = min(1.0, alpha);

    vec3 color = uColor;
    color = mix(color, uHoverColor, uHover);
    color = mix(color, uHoverColor, uSelected);

    gl_FragColor = vec4(color, alpha * uAlpha);
}{@}NewNSXText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex
#require(range.glsl)
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(msdf.glsl)
void main() {
    float alpha = msdf(tMap, vUv);
    vec3 color = uColor;

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}
{@}GameplayUINewNSXMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform sampler2D tMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( 2.0 / uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 track = texture2D( tMapMask, vMapUV ).rgb;
    track = vec3( crange( track.r, 0.55, 0.575, 0.0, 1.0 ));
    float alpha = crange( center, 0.49, 0.5, 1.0, 0.0 );

    alpha *= crange( track.r, 0.6, 0.675, 0.25, 1.0 );

    float gridScale = 250.0;
    float lineWeight = 0.025;

    float xDis = length( vMapUV - vec2( 0.5, vMapUV.y ));
    float xGrid = crange( cos( xDis * gridScale ), 1.0 - lineWeight, 1.0, 0.0, 1.0 );

    float yDis = length( vMapUV - vec2( vMapUV.x, 0.5 ));
    float yGrid = crange( cos( yDis * gridScale ), 1.0 - lineWeight, 1.0, 0.0, 1.0 );

    alpha = min( 1.0, mix( alpha, alpha * 1.0, xGrid ));
    alpha = min( 1.0, mix( alpha, alpha * 1.0, yGrid ));

    vec3 color = vec3( 0.0 );

    color = mix( color, vec3(0.15), xGrid );
    color = mix( color, vec3(0.15), yGrid );

    color = max( track, color );

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));


    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUINewNSXSpeedometer.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uMax;
uniform vec3 uFill;
uniform sampler2D tMeter;
uniform float uValue;
uniform float uSpinDist;
uniform float uFillMin;
uniform float uFillMax;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;
varying vec2 vRuv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    float pi = 3.141596;
    vUv = uv;
    vRuv = rotateUV( uv, uValue * 2.0 * pi + time );
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(conditionals.glsl)
#require(range.glsl)

void main() {
    float pi = 3.141596;

    vec2 origin = vUv - vec2( 0.5 );
    float dist = length( origin );

    vec4 otex = texture2D( tMeter, vUv );
    vec4 rtex = texture2D( tMeter, vRuv );
    vec4 tex = mix( otex, rtex, crange( dist, uSpinDist, uSpinDist + 0.001, 1.0, 0.0 ));

    float arcProgress = uValue * 2.0 * pi - pi;
    float stepTheta = atan( origin.x, origin.y );
    float stepAngle = arcProgress - stepTheta;
    float arc = crange( stepAngle * 1.2, 0.0, 0.2, 0.2, crange( uValue, 0.0, 0.5, 0.5, 1.0 ));

    arc += crange( cos( time * -4.0 + stepTheta * 2.0 ), -1.0, 1.0, -0.05, 0.05 );

    arc = max( arc, crange( dist, uFillMin - 0.001, uFillMin, 1.0, 0.0 ));
    arc = max( arc, crange( dist, uFillMax, uFillMax + 0.001, 0.0, 1.0 ));

    vec3 color = mix( uFill, uMax, crange( tex.b, 0.0, 1.0, 0.0, 1.0 ));
    color = mix( color, uFill, crange( arc, 0.3, 1.0, 1.0, 0.0 ));

    float needsRedCenter = crange( arcProgress, 0.6 * pi, 0.75 * pi, 0.0, 1.0 );
    needsRedCenter *= crange( dist, uSpinDist, uSpinDist + 0.001, 1.0, 0.0 );
    color = mix( color, uMax, needsRedCenter );

    float speed = uValue;
    float alpha = tex.g * arc;

    alpha *= uAlpha;

    gl_FragColor = vec4( color, 1.0);
    gl_FragColor.a = alpha;
}{@}GameplayUIOldNSXDefault.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(pixellize.glsl)

void main() {
    gl_FragColor = texture2D(tMap, pixellize(vUv, 50.0, 1.0 - uAlpha));
    gl_FragColor.a *= uAlpha;
}{@}UIOldNSXButton.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uBorder;
uniform vec3 uBackground;
uniform vec2 uEdge;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;
uniform float uSelected;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec2 uv = vUv;

    vec3 color = uBackground;
    float alpha = 1.0;

    color = mix(color, uHoverColor, uHover);
    color = mix(color, uHoverColor, uSelected);

    float xEdge = uEdge.x;
    float xMin = crange( uv.x, xEdge, xEdge + 0.0001, 0.0, 1.0 );
    float xMax = crange( uv.x, 1.0 - xEdge, 1.0 - ( xEdge + 0.0001 ), 0.0, 1.0 );
    color = mix( uBorder, color, xMin );
    color = mix( uBorder, color, xMax );

    float yEdge = uEdge.y;
    float yMin = crange( uv.y, yEdge, yEdge + 0.0001, 0.0, 1.0 );
    float yMax = crange( uv.y, 1.0 - yEdge, 1.0 - ( yEdge + 0.0001 ), 0.0, 1.0 );
    color = mix( uBorder, color, yMin );
    color = mix( uBorder, color, yMax );

    alpha *= crange( xMin + yMin, 0.0, 1.0, 0.0, 1.0 );
    alpha *= crange( xMin + yMax, 0.0, 1.0, 0.0, 1.0 );
    alpha *= crange( xMax + yMin, 0.0, 1.0, 0.0, 1.0 );
    alpha *= crange( xMax + yMax, 0.0, 1.0, 0.0, 1.0 );




    gl_FragColor.rgb = color;
    gl_FragColor.a = uAlpha * alpha;
}{@}UIOldNSXOutlineBox.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uBorder;
uniform vec2 uEdge;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
void main() {
    vec3 color = uBorder;
    float alpha = 0.0;

    float xEdge = uEdge.x;
    float xMin = crange( vUv.x, xEdge, xEdge + 0.0001, 1.0, 0.0 );
    float xMax = crange( vUv.x, 1.0 - xEdge, 1.0 - ( xEdge + 0.0001 ), 1.0, 0.0 );

    float yEdge = uEdge.y;
    float yMin = crange( vUv.y, yEdge, yEdge + 0.0001, 1.0, 0.0 );
    float yMax = crange( vUv.y, 1.0 - yEdge, 1.0 - ( yEdge + 0.0001 ), 1.0, 0.0 );

    float x = max( xMax, xMin );
    float y = max( yMax, yMin );

    alpha = max( x, y );
    alpha *= uAlpha;

    gl_FragColor = vec4( color, alpha );
}{@}UIOldNSXOutlineText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform vec3 uBorder;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)
#require(pixellize.glsl)

void main() {
    vec2 uv = pixellize(vUv, 50.0, 1.0 - uAlpha);
    float alpha = msdf(tMap, uv);
    float outline = strokemsdf(tMap, uv, 0.45, 0.0);

    vec3 color = uColor;// mix( uColor, uBorder, outline );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}
{@}GameplayUIOldNSXMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vec2 pos = uPlayerPosition;
    vMapUV = scaleUV( uv, vec2( uZoom ), pos );
    vGhostUV = scaleUV( uv, vec2( uZoom ), uGhostPosition - pos + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float factor = uAlpha;

    float lvls = 16.0 * factor;
    float uvScale = 64.0 * factor;
    vec2 puv = floor( vUv * lvls) / lvls;

    vec2 pmapuv = floor( vMapUV * uvScale ) / uvScale;
    vec2 pghostuv = floor( vGhostUV * lvls ) / lvls;

    float center = length( puv - vec2( 0.5 ));
    float ghost = length( puv - pghostuv );
    vec3 color = texture2D( tMapMask, pmapuv ).rgb;
    color = vec3( crange( color.r, 0.225, 0.225001, 0.0, 1.0 ));

    float alpha = crange( center, 0.4999, 0.5, 1.0, 0.0 );
    float icon = 0.01;

    lvls = 8.0;
    puv = floor( vUv * lvls) / lvls;
    center = length( puv - vec2( 0.5 ));

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) / uZoom, icon / uZoom, 1.0, 0.0 ));
    color = mix( color, uPlayerColor, crange( center, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIOldNSXSpeedText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)
#require(pixellize.glsl)

void main() {
    float alpha = msdf(tMap, pixellize(vUv, 100.0, 1.0 - uAlpha));

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}
{@}GameplayUIOldNSXSpeedometer.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uMax;
uniform vec3 uBorder;
uniform vec3 uFill;
uniform sampler2D tMeter;
uniform float uValue;
uniform float uScale;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(conditionals.glsl)
#require(range.glsl)
#require(pixellize.glsl)

void main() {
    vec4 tex = texture2D(tMeter, pixellize(vUv, uScale, 1.0 - uAlpha));

    float steps = 60.0;
    float speed = floor( 1.0 + uValue * steps ) / steps;

    vec3 color = mix( uFill, uMax, crange( tex.b, 0.0, 0.5, 0.0, 1.0 ));
    color = mix( color, uBorder, crange( tex.b, 0.5, 1.0, 0.0, 1.0 ));

    float alpha = crange( tex.g, 0.9, 1.0, 0.0, 1.0 ) * when_ge( speed, tex.r );
    gl_FragColor = vec4( color, 1.0);
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUIRDXDefault.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;
uniform sampler2D tMask;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(crossfade.glsl)
void main() {
    gl_FragColor = texture2D(tMap, vUv);

    vec2 screenUv = gl_FragCoord.xy / resolution.xy * 1.7;
    gl_FragColor.a *= crossfade(tMask, screenUv, uAlpha);
}{@}RDXButton.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uBackground;
uniform vec3 uBorder;
uniform vec2 uAspect;
uniform float uRadius;
uniform float uThickness;
uniform float uFill;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;
uniform float uSelected;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

float roundedRectangle (vec2 pos, vec2 size, float radius, float thickness, vec2 center)
{
  float d = length(max(abs(center - pos),size) - size) - radius;
  return smoothstep(0.66, 0.33, d / thickness * 5.0);
}

float roundedFrame (vec2 pos, vec2 size, float radius, float thickness, vec2 center)
{
  float d = length(max(abs(center - pos),size) - size) - radius;
  return smoothstep(0.55, 0.45, abs(d / thickness) * 5.0);
}

void main() {
    vec2 uv = vUv;
    vec2 st = uv;
    st.x *= uAspect.x/uAspect.y;
    vec2 center = vec2(0.5);
    center.x *= uAspect.x/uAspect.y;
    vec2 size = vec2(uAspect.x * 0.45, 0.45);

    float alpha = roundedRectangle(st, size, uRadius, uThickness, center);
    float shape = roundedFrame(st, size, uRadius, uThickness, center);

    vec3 color = uBackground;
    color = mix(color, uHoverColor, uHover);
    color = mix(color, uHoverColor, uSelected);

    color = mix(color, uBorder, shape);
    color = mix(color, vec3(0.0), uFill);

    gl_FragColor = vec4(color, alpha * uAlpha);
    gl_FragColor.a = (shape + alpha) * uAlpha;// * uFill;

    // float shape = roundedFrame(st, size, uRadius, uThickness, center);
    // gl_FragColor.rgb = mix(vec3(1.0, 0.2, 0.5), vec3(1.0), shape);
    // gl_FragColor.a = 1.0;
}{@}RDXTextureText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);
    vec3 color = uColor;
    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}
{@}GameplayUIRDXMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform sampler2D tMask;
uniform vec3 uPlayerColor;
uniform vec3 uGhostColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( 2.0 / uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
#require(crossfade.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 color = texture2D( tMapMask, vMapUV ).rgb;
    color = vec3( crange( color.r, 0.475, 0.485, 0.0, 1.0 ));
    float alpha = crange( center, 0.49, 0.5, 1.0, 0.0 );

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));

    alpha *= crange( color.r, 0.6, 0.675, 0.25, 1.0 );

    gl_FragColor.rgb = color;
    vec2 screenUv = gl_FragCoord.xy / resolution.xy * 1.7;
    gl_FragColor.a = alpha * crossfade(tMask, screenUv, uAlpha);
}{@}GameplayUIRDXSpeedText.glsl{@}#!ATTRIBUTES

#!UNIFORMS

uniform sampler2D tMap;
uniform vec3 uColor;
uniform float uAlpha;

#!VARYINGS

varying vec2 vUv;

#!SHADER: Vertex

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(msdf.glsl)

void main() {
    float alpha = msdf(tMap, vUv);

    gl_FragColor.rgb = uColor;
    gl_FragColor.a = alpha * uAlpha;
}
{@}TypeSButton.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform vec3 uColor;
uniform vec2 uEdge;
uniform vec2 uCorner;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;
uniform float uSelected;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    float alpha = 0.0;

    // Welcome to my nightmare
    
    alpha += step(0.5 * uEdge.x, vUv.x) * step(0.5 * uEdge.x, 1.0 - vUv.x) * step(0.5 * uEdge.y, vUv.y) * step(0.5 * uEdge.y, 1.0 - vUv.y);
    
    alpha *= step(vUv.x, uEdge.x * 1.5) + step(1.0 - vUv.x, uEdge.x * 1.5) + step(vUv.y, uEdge.y * 1.5) + step(1.0 - vUv.y, uEdge.y * 1.5);

    alpha += step(0.0, vUv.x) * step(vUv.x, uCorner.x) * step(0.0, vUv.y) * step(vUv.y, uCorner.y);
    alpha += step(0.0, vUv.x) * step(vUv.x, uCorner.x) * step(0.0, 1.0 - vUv.y) * step(1.0 - vUv.y, uCorner.y);
    alpha += step(0.0, 1.0 - vUv.x) * step(1.0 - vUv.x, uCorner.x) * step(0.0, vUv.y) * step(vUv.y, uCorner.y);
    alpha += step(0.0, 1.0 - vUv.x) * step(1.0 - vUv.x, uCorner.x) * step(0.0, 1.0 - vUv.y) * step(1.0 - vUv.y, uCorner.y);
    alpha *= 1.0 - (step(uEdge.x * 2.0, vUv.x) * step(uEdge.x * 2.5, 1.0 - vUv.x) * step(uEdge.y * 2.0, vUv.y) * step(uEdge.y * 2.0, 1.0 - vUv.y));

    vec3 color = uColor;
    color = mix(color, uHoverColor, uHover);
    color = mix(color, uHoverColor, uSelected);

    alpha = min( 1.0, alpha );

    gl_FragColor = vec4(color, alpha * uAlpha);
}{@}TypeSOutline.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform vec3 uColor;
uniform vec2 uEdge;
uniform float uAlpha;
uniform float uHover;
uniform vec3 uHoverColor;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    float alpha = 0.0;

    // external border
    alpha += step(vUv.x, uEdge.x);
    alpha += step(1.0 - vUv.x, uEdge.x);
    alpha += step(vUv.y, uEdge.y);
    alpha += step(1.0 - vUv.y, uEdge.y);
    alpha = min(1.0, alpha);

    vec3 color = uColor;
    color = mix(color, uHoverColor, uHover);

    gl_FragColor = vec4(color, alpha * uAlpha);
}{@}GameplayUITypeSMap.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMapMask;
uniform sampler2D tMask;
uniform vec3 uPlayerColor;
uniform vec3 uWaveColor;
uniform vec3 uTrackColor;
uniform vec2 uPlayerPosition;
uniform vec2 uGhostPosition;
uniform float uZoom;
uniform float uAlpha;

#!VARYINGS
varying vec2 vMapUV;
varying vec2 vGhostUV;
varying vec2 vUv;

#!SHADER: Vertex
#require(transformUV.glsl)

void main() {
    vMapUV = scaleUV( uv, vec2( uZoom ), uPlayerPosition );
    vGhostUV = scaleUV( uv, vec2( 2.0 / uZoom ), uGhostPosition - uPlayerPosition + vec2( 0.5 ));
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)

void main() {
    float center = length( vUv - vec2( 0.5 ));
    float ghost = length( vUv - vGhostUV );
    vec3 color = texture2D( tMapMask, vMapUV ).rgb;
    float track = crange( color.r, 0.55, 0.59, 0.0, 1.0 );
    color = mix( uTrackColor, vec3( 1.0 ), track );

//    color = mix( color, uGhostColor, crange( ghost, ( icon - 0.01 ) * uZoom, icon * uZoom, 1.0, 0.0 ));

    float alpha = crange( color.r, 0.8, 1.0, 0.1, 0.5 );
    float edge = crange( center, 0.465, 0.47, 0.0, 1.0 );


    color = mix( color, uTrackColor, edge );
    alpha = mix( alpha, 1.0, edge );

    float pi = 3.141596;

    float radial = crange( cos( center * 120.0 ), 0.9, 1.0, 0.0, 1.0 );
    alpha = min( 1.0, mix( alpha, alpha * 1.125, radial ));

    float wave = crange( tan(( -time * 0.175 + center * 1.25 ) * 20.0 ), pi, -pi * 0.25, 1.0, 0.0 );
    wave *= crange( center, 0.0, 0.3, 1.0, 0.075 );
    alpha = min( 1.0, mix( alpha, alpha * 2.25, wave ));

    alpha *= crange( center, 0.49, 0.5, 1.0, 0.0 );

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha * uAlpha;
}{@}GameplayUITypeSSpeedometer.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uMax;
uniform vec3 uFill;
uniform vec3 uBorder;
uniform sampler2D tMeter;
uniform float uRPM;
uniform float uSpeed;
uniform float uSpinDist;
uniform float uFillMin;
uniform float uFillMax;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(conditionals.glsl)
#require(range.glsl)

vec4 inner() {
    float pi = 3.141596;

    vec2 origin = vUv - vec2( 0.5 );
    float dist = length( origin );
    vec4 tex = texture2D( tMeter, vUv );

    float arcProgress = uRPM * 2.0 * pi - pi;
    float stepTheta = atan( origin.x, origin.y );
    float stepAngle = arcProgress - stepTheta;

    float arc = crange( stepAngle * 1.05, 0.0, 0.025, 0.2, crange( uRPM, 0.0, 0.5, 0.5, 1.0 ));
    arc += crange( cos( time * -4.0 + stepTheta * 2.0 ), -1.0, 1.0, -0.05, 0.05 );
    arc = max( arc, crange( dist, uFillMin - 0.001, uFillMin, 1.0, 0.0 ));
    arc = max( arc, crange( dist, uFillMax, uFillMax + 0.001, 0.0, 1.0 ));

    vec3 color = uBorder;
    color = mix( color, uFill, tex.r );
    color = mix( color, uMax, crange( tex.b, 0.0, 1.0, 0.0, 1.0 ));

    float needsRedCenter = crange( arcProgress, 0.6 * pi, 0.75 * pi, 0.0, 1.0 );
    needsRedCenter *= crange( dist, 0.27, 0.27 + 0.001, 1.0, 0.0 );
    color = mix( color, uMax, needsRedCenter );

    color += crange( cos( stepTheta * 12.0 + time ), -1.0, 1.0, 0.0, 0.15 );

    float alpha = tex.g * arc;
    
    return vec4( color, alpha );
}

vec4 outer( float alpha, float offset, float spread ) {
    float pi = 3.141596;
    vec2 origin = vUv - vec2( 0.5 );
    vec3 color = uBorder;

    float stepTheta = atan( origin.x, origin.y );

    float rate = (( 1.0 - uSpeed ) * 0.5 ) + offset;
    float t = rate - floor( rate );
    float angle = crange( stepTheta, -pi, pi, 0.0, 1.0 );
    float dist = min( abs( angle - t + 0.5 ), abs( angle - t - 0.5 ));

    alpha *= crange( dist, spread, spread + 0.0001, 1.0, 0.0 );

    return vec4( color, alpha );
}

void main() {
    vec4 tex = texture2D( tMeter, vUv );
    vec2 origin = vUv - vec2( 0.5 );
    float dist = length( origin );
    float side = crange( dist, 0.4, 0.4 + 0.001, 0.0, 1.0 );

    vec4 inside = inner();
    vec4 o1 = outer( tex.r, 0.25, 0.1 );
    vec4 o2 = outer( tex.b, 0.75, 0.15 );
    vec4 outside = mix( o1, o2, o2.a );
    outside.a *= 0.666;

    vec4 color = mix( inside, outside, side );
    float alpha = uAlpha * color.a;

    gl_FragColor.rgb = color.rgb;
    gl_FragColor.a = alpha;
}{@}CarMaskShader.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: Vertex
void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = vec4(1.0);
}{@}ARXVFX.fs{@}uniform sampler2D tVolumetricLight;
uniform sampler2D tUnrealBloom;
uniform sampler2D tDirt;
uniform float uVolumetricAdd;
uniform float uVignette;
uniform float uDirtAlpha;
uniform float uIntoSun;
uniform float uExposure;
uniform vec2 uContrast;
uniform vec2 uDirtVisibility;

#require(vfxcommon.fs)
#require(eases.glsl)

vec4 contrastAdjust(vec4 color, float c) {
    float t = 0.5 - c * 0.5; 
    color.rgb = color.rgb * c + t;
    return color;
}

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    vec4 color = getBlurredTexel();
    color = contrastAdjust(color, uContrast.x);
    color *= uContrast.y * mix(1.0, 1.4, uExposure);

    color += texture2D(tVolumetricLight, vUv) * uVolumetricAdd;
    color += texture2D(tUnrealBloom, vUv);

    color *= sineIn(crange(dist, 0.0, 0.5, 1.0, uVignette));
    color += texture2D(tDirt, vUv) * uDirtAlpha * mix(uDirtVisibility.x, uDirtVisibility.y, clamp(uIntoSun + uExposure, 0.0, 1.0));

    gl_FragColor = color;
}{@}IntegraVFX.fs{@}uniform float uLowerResolution;
uniform float uVignette;
uniform vec3 uNoise;
uniform vec3 uNoise2;
uniform vec3 uGlitchBlend;
uniform sampler2D tGlitch;
uniform float uGlitchRepeat;
uniform float uAcceleration;
uniform float uSepia;

#require(vfxcommon.fs)
#require(simplenoise.glsl)
#require(lut.fs)

vec3 sepia(vec3 color) {
    return vec3(
    clamp(color.r * 0.393 + color.g * 0.769 + color.b * 0.189, 0.0, 1.0),
    clamp(color.r * 0.349 + color.g * 0.686 + color.b * 0.168, 0.0, 1.0),
    clamp(color.r * 0.272 + color.g * 0.534 + color.b * 0.131, 0.0, 1.0)
    );
}

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    float res = uLowerResolution * 1024.0;
    vec2 st = floor((gl_FragCoord.xy / resolution) * res) / res;
    st.x += cnoise(vUv.yy * uNoise2.x + time*uNoise2.y) * 0.01 * uNoise2.z * crange(length(vUv.x - 0.5), 0.4, 0.5, 0.0, 1.0) * uAcceleration;

    vec3 color = getBlurredTexel(st, 1.0, 0.0).rgb;

    vec2 guv = vUv;
    guv.y *= uGlitchRepeat;
    guv += cnoise(vUv.yy * uNoise.x + time*uNoise.y) * 0.3 * uNoise.z;


    vec3 glitch = texture2D(tGlitch, guv).rgb;
    color = mix(color, glitch*color*uGlitchBlend.x, uGlitchBlend.y) * uGlitchBlend.z;

    color = mix(color, sepia(color), uSepia);

    color *= crange(dist, 0.0, 0.5, 1.0, uVignette);

    gl_FragColor = vec4(clamp(color, vec3(0.0), vec3(1.0)), 1.0);
}{@}NewNSXVFX.fs{@}uniform sampler2D tUnrealBloom;
uniform sampler2D tRain;
uniform vec3 uTint1;
uniform float uTintFactor;
uniform vec2 uTintRange;
uniform float uNoiseMin;
uniform float uVignette;
uniform float uRainRefraction;

#require(vfxcommon.fs)
#require(simplenoise.glsl)
#require(eases.glsl)
#require(transformUV.glsl)

vec2 getRainUV(float rain, float vignette) {
    vec2 uv = vUv;
    uv.x += uRainRefraction*0.1*0.1 * smoothstep(0.05, 0.2, rain) * vignette;
    uv.y += uRainRefraction*0.1*0.1 * smoothstep(0.05, 0.2, rain) * vignette;
    uv.x += uRainRefraction*0.05*0.1 * rain * vignette;
    uv.y += uRainRefraction*0.05*0.1 * rain * vignette;

    uv = scaleUV(uv, -vec2(range(rain * vignette, 0.0, 1.0, 1.0, 0.97)), uv);
    return uv;
}

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    vec2 uv = vUv;

    float rain = 0.0;
    float v = crange(dist, 0.2, 0.3, 0.0, 1.0);

    float mask = crange(texture2D(tCarMask, vUv).r, 1.0, 0.0, 0.75, 1.0);

    #test Tests.renderRain()
    rain = texture2D(tRain, vUv).r;
    uv = getRainUV(crange(rain, 0.05, 1.0, 0.0, 1.0), v);
    #endtest

    vec4 color = getBlurredTexel(uv, 1.0, 1.0);
    // vec4 bloomFlipped = texture2D(tUnrealBloom, vec2(1.0 - vUv.x, 1.0 - vUv.y));
    color += texture2D(tUnrealBloom, uv) * 3.0 * mask;

    color.rgb += uTint1 * (1.0 - crange(color.r, uTintRange.x, uTintRange.y, 0.0, 1.0)) * uTintFactor;
    color.rgb *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);

    // float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb *= sineIn(crange(dist, 0.0, 0.5, 1.0, uVignette));
    color.rgb += rain * 0.025 * v;
    
    gl_FragColor = color;
}{@}OldNSXVFX.fs{@}uniform float uLowerResolution;
uniform sampler2D tCRT;
uniform float uCRTScale;
uniform float uVignette;
uniform float uCollision;
uniform float uRes;
uniform vec3 uCRTBlend;
uniform vec3 uNoise;

#require(vfxcommon.fs)
#require(simplenoise.glsl)

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    float res = uLowerResolution * 512.0 * uRes;
    vec2 st = floor((gl_FragCoord.xy / resolution) * res) / res;
    st += cnoise(vUv.yy * uNoise.x + time*uNoise.y) * 0.01 * uNoise.z * (crange(dist, 0.3, 0.5, 0.0, 1.0) + uCollision);

    vec3 crt = texture2D(tCRT, vUv * uCRTScale).rgb;
    vec4 texel = getBlurredTexel(st, 1.0, 1.0);
    vec3 color = texel.rgb;
    color = mix(color, crt*color*uCRTBlend.x, uCRTBlend.y) * uCRTBlend.z;

    color *= crange(dist, 0.0, 0.5, 1.0, uVignette);

    gl_FragColor = vec4(color, 1.0);
}{@}RDXVFX.fs{@}uniform sampler2D tUnrealBloom;
uniform float uVignette;
uniform sampler2D tLUT;
uniform sampler2D tFog;
uniform float uFogBlend;
uniform float uNoiseMin;

#require(vfxcommon.fs)
#require(eases.glsl)
#require(lut.fs)
#require(simplenoise.glsl)

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    vec4 color = getBlurredTexel();
    color *= sineIn(crange(dist, 0.0, 0.5, 1.0, uVignette));
    color += texture2D(tUnrealBloom, vUv);

    #test Tests.renderRDXFog()
    vec3 fog = texture2D(tFog, vUv).rgb;
    float depth = getDepthValue(tDepth, vUv, 0.1, 200.0);
    color.rgb = mix(color.rgb, color.rgb * (1.0 - fog), uFogBlend);
    #endtest

    color += texture2D(tUnrealBloom, vUv);

    gl_FragColor = vec4(clamp(color.rgb, vec3(0.0), vec3(1.0)), 1.0);
    gl_FragColor = lookup(gl_FragColor, tLUT);
    gl_FragColor.rgb *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);
    gl_FragColor.rgb *= 1.2;
}{@}TypesVFX.fs{@}uniform sampler2D tUnrealBloom;
uniform float uVignette;
uniform float uNoiseMin;
uniform vec3 uTint1;
uniform vec2 uContrast;

#require(vfxcommon.fs)
#require(simplenoise.glsl)
#require(eases.glsl)

vec4 contrastAdjust(vec4 color, float c) {
    float t = 0.5 - c * 0.5;
    color.rgb = color.rgb * c + t;
    return color;
}

void main() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    float mask = crange(texture2D(tCarMask, vUv).r, 1.0, 0.0, 0.75, 1.0);

    vec4 color = getBlurredTexel();
    color += texture2D(tUnrealBloom, vUv) * mask;

    color.rgb *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);
    color.rgb *= sineIn(crange(dist, 0.0, 0.5, 1.0, uVignette));

    // color.rgb = blendOverlay(color.rgb, uTint1);
    color = contrastAdjust(color, uContrast.x);
    color *= uContrast.y;

    gl_FragColor = color;
}{@}vfxcommon.fs{@}uniform sampler2D tCarMask;
uniform sampler2D tDepth;
uniform sampler2D tGhost;
uniform vec2 uBlurDistRange;
uniform vec3 uGhostColor;
uniform float uCarAcceleration;
uniform float uBlurSampleDist;
uniform float uBlurBaseStrength;
uniform float uBaseRGBStrength;
uniform float uAccelerationRGB;

#require(rgbshift.fs)
#require(depthvalue.fs)
#require(range.glsl)
#require(blendmodes.glsl)

vec4 tunnelBlur(sampler2D tDiffuse, vec2 uv, float sampleDist, float strength) {
    float samples[10];
    samples[0] = -0.08;
    samples[1] = -0.05;
    samples[2] = -0.03;
    samples[3] = -0.02;
    samples[4] = -0.01;
    samples[5] =  0.01;
    samples[6] =  0.02;
    samples[7] =  0.03;
    samples[8] =  0.05;
    samples[9] =  0.08;

    vec2 dir = 0.5 - uv;
    float dist = sqrt(dir.x*dir.x + dir.y*dir.y);
    dir = dir / dist;

    vec4 texel = texture2D(tDiffuse, uv);
    vec4 sum = texel;

    for (int i = 0; i < 10; i++) {
        sum += texture2D(tDiffuse, uv + dir * samples[i] * sampleDist);
    }

    sum *= 1.0/10.0;
    float t = clamp(dist * strength, 0.0, 1.0);

    return mix(texel, sum, t);
}

vec4 tunnelBlurRGB(sampler2D tDiffuse, vec2 uv, float sampleDist, float strength, float angle, float rgbStrength) {
    float samples[10];
    samples[0] = -0.08;
    samples[1] = -0.05;
    samples[2] = -0.03;
    samples[3] = -0.02;
    samples[4] = -0.01;
    samples[5] =  0.01;
    samples[6] =  0.02;
    samples[7] =  0.03;
    samples[8] =  0.05;
    samples[9] =  0.08;

    vec2 dir = 0.5 - uv;
    float dist = sqrt(dir.x*dir.x + dir.y*dir.y);
    dir = dir / dist;

    vec4 texel = getRGB(tDiffuse, uv, angle, rgbStrength);
    vec4 sum = texel;

    for (int i = 0; i < 10; i++) {
        sum += getRGB(tDiffuse, uv + dir * samples[i] * sampleDist, angle, rgbStrength);
    }

    sum *= 1.0/10.0;
    float t = clamp(dist * strength, 0.0, 1.0);

    return mix(texel, sum, t);
}

vec4 getBlurredTexelBase(vec2 uv, float strength) {
    vec4 texel;

    #test Tests.renderSpeedBlur()
    float mask = 1.0 - texture2D(tCarMask, uv).r;
    float depth = getDepthValue(tDepth, uv, 0.1, 200.0);
    float depthStrength = crange(depth, uBlurDistRange.x, uBlurDistRange.y, 1.0, 0.0);
    texel = tunnelBlur(tDiffuse, uv, uBlurSampleDist, uBlurBaseStrength * strength * mask * uCarAcceleration * depthStrength);
    #endtest

    #test !Tests.renderSpeedBlur()
    texel = texture2D(tDiffuse, uv);
    #endtest

    return texel;
}

vec4 getBlurredTexelRGB(vec2 uv, float strength, float rgbStrength) {
    vec4 texel;

    vec2 d = uv - vec2(0.5);
    float a = atan(d.y, d.x);

    #test Tests.renderSpeedBlur()
    float depth = getDepthValue(tDepth, uv, 0.1, 200.0);
    float depthStrength = crange(depth, uBlurDistRange.x, uBlurDistRange.y, 1.0, 0.0);
    float mask = 1.0 - texture2D(tCarMask, uv).r;
    texel = tunnelBlurRGB(tDiffuse, uv, uBlurSampleDist, uBlurBaseStrength * strength * mask * uCarAcceleration * depthStrength, a, rgbStrength * 0.002 * uBaseRGBStrength + (0.0005 * uAccelerationRGB * uCarAcceleration));
    #endtest

    #test !Tests.renderSpeedBlur()
    texel = getRGB(tDiffuse, uv, a, rgbStrength * 0.002 * uBaseRGBStrength);
    #endtest

    return texel;
}

vec4 getBlurredTexel(vec2 iuv, float strength, float rgbStrength) {
    vec4 texel;
    vec2 uv = iuv;

    float mask = 1.0 - texture2D(tCarMask, uv).r;
    vec4 ghost = texture2D(tGhost, vUv);
//    uv += mix(0.0, crange(ghost.x, 0.0, 1.0, -1.0, 1.0) * 0.02, ghost.y * mask) * ghost.zw;

    #test Tests.renderRGBShift()
    texel = getBlurredTexelRGB(uv, strength, rgbStrength * mix(1.0, 2.0, ghost.y * mask));
    #endtest

    #test !Tests.renderRGBShift()
    texel = getBlurredTexelBase(uv, strength);
    #endtest

    texel.rgb = mix(texel.rgb, blendAdd(texel.rgb, ghost.r * uGhostColor), ghost.y * mask * 0.5);

    return texel;
}

vec4 getBlurredTexel() {
    vec2 uv = vUv;
    vec4 texel = getBlurredTexel(uv, 1.0, 1.0);

    return texel;
}{@}ArxSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform vec3 uFillColor;
uniform vec3 uBorderColor;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;
    float value = floor(0.5 + (uSpecValue * uAlpha * 10.0)) / 10.0;
    vec4 tex = texture2D(tBackground, uv);

    float border = tex.r;
    float mask = tex.g * step(uv.x, uSpecValue);

    vec3 color = mix(uFillColor, uBorderColor, border);
    float alpha = (border + mask) * uAlpha * tex.a;

    gl_FragColor = vec4(color, alpha);
}{@}IntegraSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform sampler2D tFill;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;
    float value = floor(0.5 + (uSpecValue * uAlpha * 10.0)) / 10.0;
    
    gl_FragColor = mix(
        texture2D(tBackground, uv),
        texture2D(tFill, uv),
    step(uv.x, value));
    gl_FragColor.a *= uAlpha;
}{@}NewNSXSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform vec3 uFillColor;
uniform vec3 uBackgroundColor;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;
    float value = floor(0.5 + (uSpecValue * uAlpha * 10.0)) / 10.0;
    vec4 tex = texture2D(tBackground, uv);

    float mask = tex.g * step(uv.x, uSpecValue);
    vec3 color = mix(uBackgroundColor, uFillColor, mask);

    gl_FragColor = vec4(color, uAlpha);
}{@}OldNSXSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform vec3 uFillColor;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;
    float value = floor(0.5 + (uSpecValue * uAlpha * 10.0)) / 10.0;;

    vec4 color = texture2D(tBackground, uv);
    color.rgb = mix(color.rgb, color.rgb * uFillColor, step(uv.x, value));

    gl_FragColor = color;
    gl_FragColor.a *= uAlpha;
}{@}RDXSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform sampler2D tArrow;
uniform vec3 uBackgroundColor;
uniform float uBackgroundAlpha;
uniform vec3 uFillColor;
uniform float uFillAlpha;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;

    float value = step(uv.x, uSpecValue * uAlpha);
    
    vec4 arrow = texture2D(tArrow, vec2(uv.x + 0.5 - uSpecValue * uAlpha, uv.y));
    vec4 grid = texture2D(tBackground, vUv);
    vec3 color = mix(uBackgroundColor, uFillColor, value);
    float alpha = mix(uBackgroundAlpha, uFillAlpha, value);

    color += arrow.rgb;
    alpha += arrow.a;

    gl_FragColor = vec4(color + grid.rgb, (alpha + grid.a) * uAlpha);
}{@}TypeSSpecBar.glsl{@}#!ATTRIBUTES


#!UNIFORMS
uniform sampler2D tBackground;
uniform vec3 uFillColor;
uniform float uSpecValue;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

void main() {
    vec2 uv = vUv;
    float value = floor(0.5 + (uSpecValue * uAlpha * 10.0)) / 10.0;
    vec4 tex = texture2D(tBackground, uv);

    float mask = mix(tex.g, tex.r + tex.g, smoothstep(uv.x, uv.x + 0.01, uSpecValue));
    // float mask = mix(tex.g, tex.r + tex.g, step(uv.x, uSpecValue));
    gl_FragColor = vec4(uFillColor, mask * uAlpha);
}{@}GarageNeons.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMap;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vec3 pos = position;
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
void main() {
    gl_FragColor = texture2D(tMap, vUv);
    gl_FragColor.a = 1.0;
}{@}PBRGarageFloor.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform mat4 uMirrorMatrix;
uniform sampler2D tMirrorReflection;
uniform float uMirrorDistort;
uniform float uReflAdd;
uniform float uContrast;

#!VARYINGS
varying vec4 vMirrorCoord;

#!SHADER: PBRGarageFloor.vs

#require(pbr.vs)

void main() {
    setupPBR(position);

    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    vMirrorCoord = uMirrorMatrix * worldPos;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: PBRGarageFloor.fs

#require(pbr.fs)
#require(luma.fs)
#require(range.glsl)
#require(eases.glsl)
#require(radialblur.fs)

vec4 contrastAdjust(vec4 color, float c) {
    float t = 0.5 - c * 0.5;
    color.rgb = color.rgb * c + t;
    return color;
}

void main() {
    vec3 normal = texture2D(tNormal, vUv * uNormalScale.y).rgb;
    normal = range(normal, vec3(0.0), vec3(1.0), vec3(-1.0), vec3(1.0));

    gl_FragColor = getPBR();

    #test Tests.renderGarageMirror()
    vec3 mro = texture2D(tMRO, vUv * uNormalScale.y).rgb;
    vec4 mirrorCoord = vMirrorCoord;
    mirrorCoord.xz += normal.xy * 0.1 * uMirrorDistort;
    vec4 reflection = texture2D(tMirrorReflection, mirrorCoord.xy / mirrorCoord.w);


    //    reflection.rgb *= mix(1.0, uContrast, reflection.a * crange(luma(reflection.rgb), 0.2, 1.0, 0.0, 1.0));
    gl_FragColor.rgb += contrastAdjust(reflection, uContrast).rgb * uReflAdd * (1.0 - mro.y);

    #endtest

    #test Tests.renderGarageMirrorBlur()
    vec3 mro = texture2D(tMRO, vUv * uNormalScale.y).rgb;
    vec4 mirrorCoord = vMirrorCoord;
    mirrorCoord.xz += normal.xy * 0.1 * uMirrorDistort;
    vec4 reflection = vec4(radialBlur(tMirrorReflection, mirrorCoord.xy / mirrorCoord.w, 100.0 * mro.g, vec2(2048.0)), 1.0);


    //    reflection.rgb *= mix(1.0, uContrast, reflection.a * crange(luma(reflection.rgb), 0.2, 1.0, 0.0, 1.0));
    gl_FragColor.rgb += contrastAdjust(reflection, uContrast).rgb * uReflAdd * (1.0 - mro.y);

    #endtest
}{@}PBRGarageLedge.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: Vertex

#require(pbr.vs)

void main() {
    setupPBR(position);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(pbr.fs)

void main() {
    gl_FragColor = vec4(getPBR().rgb, 0.0);
}{@}PBRGarageWall.glsl{@}#!ATTRIBUTES

#!UNIFORMS

#!VARYINGS

#!SHADER: Vertex

#require(pbr.vs)

void main() {
    setupPBR(position);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment

#require(pbr.fs)

void main() {
    gl_FragColor = vec4(getPBR().rgb, 0.0);
}{@}GarageVFXPass.fs{@}uniform float uIndex;

uniform float uRGBStrength;
uniform float uRGBAngle;
uniform float uNoiseMin;

uniform float uLowerResolution;
uniform sampler2D tCRT;
uniform float uCRTScale;
uniform float uVignette;
uniform float uCollision;
uniform vec3 uCRTBlend;
uniform vec3 uNoise;

uniform vec3 uGlitchBlend;
uniform sampler2D tGlitch;
uniform float uGlitchRepeat;
uniform float uSepia;

uniform sampler2D tRDXLUT;

uniform vec3 uTint1;
uniform vec3 uTint2;
uniform vec3 uTint3;
uniform vec3 uTint4;
uniform vec3 uTint5;
uniform vec3 uTint6;

#require(rgbshift.fs)
#require(rgb2hsv.fs)
#require(lut.fs)
#require(luma.fs)
#require(range.glsl)
#require(simplenoise.glsl)

vec3 sepia(vec3 color) {
    return vec3(
    clamp(color.r * 0.393 + color.g * 0.769 + color.b * 0.189, 0.0, 1.0),
    clamp(color.r * 0.349 + color.g * 0.686 + color.b * 0.168, 0.0, 1.0),
    clamp(color.r * 0.272 + color.g * 0.534 + color.b * 0.131, 0.0, 1.0)
    );
}

vec3 getOldNSXColor() {
    vec2 delta = vUv - 0.5;
    float dist = length(delta);

    float res = uLowerResolution * 512.0;
    vec2 st = floor((gl_FragCoord.xy / resolution) * res) / res;

    vec3 texel = texture2D(tDiffuse, st).rgb;

    vec3 crt = texture2D(tCRT, vUv * uCRTScale).rgb;
    vec3 color = texel.rgb;
    color = mix(color, crt*color*uCRTBlend.x, uCRTBlend.y) * uCRTBlend.z;

    return color;
}

vec3 getIntegraColor() {
    float res = uLowerResolution * 1024.0;
    vec2 st = floor((gl_FragCoord.xy / resolution) * res) / res;

    vec4 texel = getRGB(tDiffuse, st, 0.1 * uRGBAngle, 0.002 * uRGBStrength);
    vec3 color = texel.rgb;

    vec2 guv = vUv;
    guv.y *= uGlitchRepeat;
    guv += cnoise(vUv.yy * uNoise.x + time*uNoise.y) * 0.3 * uNoise.z;

    vec3 glitch = texture2D(tGlitch, guv).rgb;
    color = mix(color, glitch*color*uGlitchBlend.x, uGlitchBlend.y) * uGlitchBlend.z;

    color = mix(color, sepia(color), uSepia);
    color *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);

    return color;
}

vec3 getRegularColor() {
    vec3 color = getRGB(tDiffuse, vUv, 0.1 * uRGBAngle, 0.002 * uRGBStrength).rgb;
    color *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);
    return color;
}

vec3 getRDXColor() {
    vec3 color = getRGB(tDiffuse, vUv, 0.1 * uRGBAngle, 0.002 * uRGBStrength).rgb;
    color *= crange(getNoise(vUv, time), 0.0, 1.0, uNoiseMin, 1.0);

    return lookup(vec4(color, 1.0), tRDXLUT).rgb;
}

void main() {
    vec3 oldNSXColor = vec3(0.0);
    vec3 integraColor = vec3(0.0);
//    vec3 rdxColor = vec3(0.0);
    vec3 regularColor = vec3(0.0);

    if (uIndex <= 1.0) oldNSXColor = getOldNSXColor();
    if (uIndex >= 0.0 && uIndex <= 2.0) integraColor = getIntegraColor();
//    if (uIndex >= 1.0 && uIndex <= 3.0) rdxColor = getRDXColor();
    if (uIndex >= 1.0) regularColor = getRegularColor();

    vec3 color = mix(oldNSXColor, integraColor, crange(uIndex, 0.0, 1.0, 0.0, 1.0));
//    color = mix(color, rdxColor, crange(uIndex, 1.0, 2.0, 0.0, 1.0));
    color = mix(color, regularColor, crange(uIndex, 1.0, 2.0, 0.0, 1.0));

    vec3 tint = mix(uTint1, uTint2, crange(uIndex, 0.0, 1.0, 0.0, 1.0));
    tint = mix(tint, uTint3, crange(uIndex, 1.0, 2.0, 0.0, 1.0));
    tint = mix(tint, uTint4, crange(uIndex, 2.0, 3.0, 0.0, 1.0));
    tint = mix(tint, uTint5, crange(uIndex, 3.0, 4.0, 0.0, 1.0));
    tint = mix(tint, uTint6, crange(uIndex, 4.0, 6.0, 0.0, 1.0));
    color *= mix(vec3(1.0), tint, 1.0 - luma(color));

    vec3 darken = rgb2hsv(color);
    darken.y *= 0.45;
    darken.z *= 0.35;
    darken = hsv2rgb(darken);

    color = mix(color, darken, 1.0-smoothstep(0.9, 0.45, vUv.x));

    gl_FragColor = vec4(color, 1.0);
}{@}BasicTransition.fs{@}uniform sampler2D tFrom;
uniform sampler2D tTo;
uniform float uTransition;

varying vec2 vUv;

void main() {
    vec4 from = texture2D(tFrom, vUv);
    vec4 to = texture2D(tTo, vUv);
    gl_FragColor = mix(from, to, uTransition);
}{@}CRTTransition.fs{@}uniform sampler2D tFrom;
uniform sampler2D tTo;
uniform sampler2D tCRT;
uniform float uTransition;
uniform float uBlend;
uniform float uPadding;
uniform float uCRTScale;
uniform float uCRTTransition;
uniform float uCRTCenter;
uniform float uCRTAffect;
uniform float uCRTAffect2;
uniform float uRGBStrength;
uniform float uRGBTransition;
uniform float uFromZoom;
uniform float uToZoom;
uniform float uBrighten;
uniform float uBrighten2;
uniform float uSwap;

varying vec2 vUv;

#require(depthvalue.fs)
#require(range.glsl)
#require(eases.glsl)
#require(transformUV.glsl)
#require(rgbshift.fs)
#require(blendmodes.glsl)

void main() {
    vec2 dist = vUv - 0.5;
    float a = atan(dist.y, dist.x);
    float padding = uPadding * 0.1;
    float transition = crange(uBlend, 0.0, 1.0, -0.2, 1.2);

    vec2 fromUV = vUv;
    vec2 toUV = vUv;
    fromUV = scaleUV(fromUV, vec2(sineIn(crange(expoOut(length(dist)), 0.0, 0.3, 1.0, 1.0 + (1.0 * uFromZoom)))));
//    toUV = scaleUV(toUV, vec2( crange(quarticIn(length(dist)), 0.0, 0.5, 1.0, 1.0 + (0.1 * (1.0 - uToZoom)) )));

    vec2 crtUV = vUv * uCRTScale;
    crtUV = scaleUV(crtUV, vec2(uCRTTransition * range(quarticIn(length(dist)), 0.0, 0.3, 1.0, 0.3 + (1.25 * uTransition))), vec2(uCRTCenter));
    vec4 crt = texture2D(tCRT, crtUV) + (2.0 * uBrighten);

    vec4 from = texture2D(tFrom, fromUV);//getRGB(tFrom, fromUV, a, 0.001 * uRGBStrength * uRGBTransition);
    vec4 to = texture2D(tTo, toUV);//getRGB(tTo, toUV, a, 0.001 * uRGBStrength * uRGBTransition);

    vec3 color = mix(from, to, uSwap).rgb;

    gl_FragColor.rgb = color * mix(vec3(1.0), mix(color, crt.rgb, 0.55), uCRTAffect * uCRTAffect2 * 0.8 * crange(length(dist), 0.5, 0.3, 1.0, uCRTAffect2));
    gl_FragColor.rgb = mix(gl_FragColor.rgb, gl_FragColor.rgb * 1.1, uBrighten2 * uBrighten);
    gl_FragColor.a = 1.0;
}{@}CRTTransition2.fs{@}uniform sampler2D tFrom;
uniform sampler2D tTo;
uniform sampler2D tCRT;
uniform float uTransition;
uniform float uBlend;
uniform float uPadding;
uniform float uCRTScale;
uniform float uCRTTransition;
uniform float uCRTCenter;
uniform float uCRTAffect;
uniform float uCRTAffect2;
uniform float uRGBStrength;
uniform float uRGBTransition;
uniform float uFromZoom;
uniform float uToZoom;
uniform float uBrighten;
uniform float uBrighten2;
uniform float uSwap;

varying vec2 vUv;

#require(depthvalue.fs)
#require(range.glsl)
#require(eases.glsl)
#require(transformUV.glsl)
#require(rgbshift.fs)
#require(blendmodes.glsl)
#require(simplenoise.glsl)

void main() {
    vec2 dist = vUv - 0.5;
    float distLength = length(dist);
    float a = atan(dist.y, dist.x);
    float padding = uPadding * 0.1;
    float transition = crange(uBlend, 0.0, 1.0, -0.2, 1.2);

    vec2 fromUV = vUv;
    vec2 toUV = vUv;
    fromUV = scaleUV(fromUV, vec2(sineIn(crange(expoOut(length(dist)), 0.0, 0.3, 1.0, 1.0 + (1.5 * uFromZoom)))));
    //    toUV = scaleUV(toUV, vec2( crange(quarticIn(length(dist)), 0.0, 0.5, 1.0, 1.0 + (0.1 * (1.0 - uToZoom)) )));

    vec2 crtUV = vUv * uCRTScale;
    crtUV = scaleUV(crtUV, vec2(uCRTTransition * range(quarticIn(length(dist)), 0.0, 0.3, 1.0, 0.3 + (2.0 * uTransition))), vec2(uCRTCenter));
    vec4 crt = texture2D(tCRT, crtUV) + (2.0 * uBrighten);



    vec2 ringUV = vUv;
    ringUV = scaleUV(ringUV, vec2(1.0, (resolution.x/resolution.y)*0.8));
    ringUV += cnoise(vec3(ringUV*2.0, time+uSwap))*0.13*uSwap;
    float ringLength = length(ringUV - 0.5);
    float swapGradient = smoothstep(uSwap-0.2, uSwap, ringLength);
    float bounceSwapGradient = smoothstep(0.0,0.4,uSwap)*smoothstep(1.0,0.4,uSwap);
    float swapGradientRing = smoothstep(0.0, 0.5, swapGradient)*smoothstep(1.0, 0.5, swapGradient)*bounceSwapGradient;

    vec3 from = getRGB(tFrom, fromUV, a, 0.005 * bounceSwapGradient).rgb;
    vec3 to = getRGB(tTo, toUV, a, 0.005 * bounceSwapGradient).rgb;
    to *= 1.0+bounceSwapGradient;
    vec3 color = mix(to, from, swapGradient);

    color += bounceSwapGradient*swapGradient*0.3;
    color = mix(color, blendAdd(color, vec3(1.0)), swapGradientRing);
    color * mix(vec3(1.0), mix(color, crt.rgb, 0.8), swapGradientRing);
    color * mix(vec3(1.0), mix(color, crt.rgb, 0.55), uCRTAffect * uCRTAffect2 * 0.8 * crange(distLength, 0.5, 0.3, 1.0, uCRTAffect2));
    color = mix(color, color * 1.05, uBrighten2 * uBrighten);

    gl_FragColor.rgb = color;
    gl_FragColor.a = 1.0;
}{@}GameTransition.fs{@}uniform sampler2D tFrom;
uniform sampler2D tTo;
uniform float uTransition;
uniform float uPadding;

varying vec2 vUv;

#require(transformUV.glsl)
#require(conditionals.glsl)
#require(range.glsl)

vec2 barrelPincushion(vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    float theta = atan(st.x, st.y);
    float radius = sqrt(dot(st, st));
    radius *= 1.0 + strength * (radius * radius);

    return 0.5 + radius * vec2(sin(theta), cos(theta));
}

void main() {
    float aspect = resolution.x / resolution.y;
    vec2 d = scaleUV(vUv, vec2(1.0, aspect)) - 0.5;
    float l = length(d);

    float padding = uPadding * 0.01;
    float trans = crange(uTransition, l - padding, l + padding, 0.0, 1.0);

    vec2 fromUV = barrelPincushion(vUv, -uTransition);

    vec4 from = texture2D(tFrom, fromUV);
    vec4 to = texture2D(tTo, vUv);

    vec4 tex = mix(from, to, trans);

    gl_FragColor = tex;
}{@}GarageTransition.fs{@}uniform sampler2D tFrom;
uniform sampler2D tTo;
uniform float uTransition;

varying vec2 vUv;

#require(transformUV.glsl)
#require(conditionals.glsl)

vec2 barrelPincushion(vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    float theta = atan(st.x, st.y);
    float radius = sqrt(dot(st, st));
    radius *= 1.0 + strength * (radius * radius);

    return 0.5 + radius * vec2(sin(theta), cos(theta));
}

void main() {
    vec2 fromUV = translateUV(vUv, vec2(0.0, uTransition));
    vec2 toUV = translateUV(vUv, vec2(0.0, - (1.0 - uTransition)));

    fromUV = barrelPincushion(fromUV, -uTransition);

    vec4 from = texture2D(tFrom, fromUV);
    vec4 to = texture2D(tTo, toUV);
    gl_FragColor = mix(from, to, step(vUv.y, uTransition));
}{@}Transition.vs{@}varying vec2 vUv;

void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}{@}displace.glsl{@}vec2 displaceUv(sampler2D mask, float progress) {
    vec2 screenUv = gl_FragCoord.xy / resolution.xy * 4.0;
    vec2 disp = texture2D(mask, screenUv).rg;
    return disp * progress * 0.4;
}

vec2 displace(vec2 uv, sampler2D mask, float progress) {
    return uv + displaceUv(mask, progress);
}
{@}pixellize.glsl{@}vec2 pixellize(vec2 uv, float scale, float progress) {
    scale = mix(scale, 1.0, progress);
    // scale *= progress;
    float ratio = scale;
    // float ratio = floor(scale / (resolution.x / resolution.y));
    vec2 pos;
    pos.x = floor(uv.x * scale) / scale;
    pos.y = floor(uv.y * ratio) / ratio;
    
    pos = mix(uv, pos, step(0.001, progress));
    return pos;
}{@}crossfade.glsl{@}float crossfade(sampler2D mask, vec2 uv, float progress) {
    return step(texture2D(mask, uv).g, progress);
}{@}UIGlow.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform vec3 uColor;
uniform float uRadius;
uniform float uFeather;
uniform float uOpacity;
uniform float uNoiseSpeed;
uniform float uNoiseStrength;
uniform vec2 uNoiseScale;
uniform float uAlpha;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(range.glsl)
#require(simplenoise.glsl)
#require(transformUV.glsl)
void main() {
    vec3 color = uColor;
    float alpha = uOpacity * uAlpha;

    float center = length( vUv - vec2( 0.5 ));
    float radius = uRadius - center;
    alpha *= crange( radius, 0.0, 0.00001 + uFeather, 0.0, 1.0 );

    vec2 uv = scaleUV( vUv, uNoiseScale );
    float noise = cnoise( vec3( uv, time * uNoiseSpeed ));
    alpha *= 1.0 + noise * uNoiseStrength * 0.1;

    gl_FragColor.rgb = color;
    gl_FragColor.a = alpha;
}{@}MultiplayerShine.glsl{@}#!ATTRIBUTES

#!UNIFORMS
uniform sampler2D tMask;
uniform vec3 uColor;
uniform float uWidth;
uniform float uAlpha;
uniform float uProgress;

#!VARYINGS
varying vec2 vUv;

#!SHADER: Vertex
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

#!SHADER: Fragment
#require(transformUV.glsl)
#require(range.glsl)
void main() {
    float mask = texture2D( tMask, vUv ).r;
    vec2 uv = rotateUV( vUv, 0.1 );
    vec3 color = uColor;
    float alpha = 1.0;
    float progress = crange( uProgress, 0.0, 1.0, -0.5, 1.5 );
    float width = uWidth / 100.0;
    alpha *= crange( uv.x, progress - width, progress, 0.0, 1.0 );
    alpha *= crange( uv.x, progress + width, progress, 0.0, 1.0 );
    alpha *= uAlpha;
    alpha *= 0.666;
    alpha *= mask;
    gl_FragColor = vec4(color, alpha );
}