#version 460 compatibility
uniform sampler2D lightmap; 
uniform sampler2D depthtex0;
uniform float viewHeight;
uniform float viewWidth;
uniform vec3 shadowLightPosition;
uniform vec3 fogColor;
uniform mat4 gbufferModelViewInverse;
uniform float far;
uniform float near;
uniform float dhFarPlane;
uniform float dhNearPlane;

layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;

float linearizeDepth(float depth, float near, float far) {
    return (2.0 * near * far) / (far + near - depth * (far - near));
}

void main() {
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 worldGeoNormal = normalize(mat3(gbufferModelViewInverse) * geoNormal);
    
    float lightBrightness = clamp(dot(shadowLightDirection, worldGeoNormal), 0.0, 1.0);
    
    float ambientStrength = 0.3;
    float finalLighting = lightBrightness * 0.7 + ambientStrength;
    
    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));
    vec4 outputColorData = blockColor;
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * lightColor;
    float transparency = outputColorData.a;
    
    if(transparency < 0.1) {
        discard;
    }
    
    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texCoord).r;
    float dhDepth = gl_FragCoord.z;
    float depthLinear = linearizeDepth(depth, near, far*4);
    float dhDepthLinear = linearizeDepth(dhDepth, dhNearPlane, dhFarPlane);
    
    if(depthLinear < dhDepthLinear && depth != 1) {
        discard;
    }
    
    float distanceFromCamera = distance(vec3(0), viewSpacePosition);
    float dhBlend = pow(smoothstep(far-.5*far, far, distanceFromCamera), .6);
    transparency = mix(0.0, transparency, dhBlend);
    
    float maxFogDistance = 200.0;
    float minFogDistance = 150.0;
    float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance), 0.0, 1.0);
    
    outputColor *= finalLighting;
    outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);
    
    outColor0 = vec4(pow(outputColor, vec3(1.0/2.2)), transparency);
}