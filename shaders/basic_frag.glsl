#version 460
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4      gbufferModelViewInverse;
uniform sampler2D normals;
uniform float far;
uniform float dhNearPlane;
uniform vec3 shadowLightPosition;
uniform vec3 fogColor; 

layout (location = 0) out vec4 outColor0;

in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;

mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}

void main() {
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal; 

    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

    vec4 normalData = texture(normals, texCoord) * 2.0 - 1.0;
    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0 - dot(normalData.xy, normalData.xy)));
    mat3 TBN = tbnNormalTangent(worldGeoNormal, worldTangent);
    vec3 normalWorldSpace = TBN * normalNormalSpace;

    float lightBrightness = clamp(dot(shadowLightDirection, normalWorldSpace), 0.1, 1.0);
    
    float ambientStrength = 0.1;
    float finalLighting = lightBrightness * 0.7 + ambientStrength;
    
    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));
    vec4 outputColorData = texture(gtexture, texCoord);
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2)) * lightColor;
    float transparency = outputColorData.a;
    
    if(transparency < 0.1) {
        discard;
    }
    
    float distanceFromCamera = length(viewSpacePosition);
    float dhBlend = smoothstep(far * 0.5, far, distanceFromCamera);
    transparency = mix(transparency, 0.0, pow(dhBlend, 0.6));
    
    float maxFogDistance = 200.0;
    float minFogDistance = 150.0;
    float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance), 0.0, 1.0);
    
    outputColor *= finalLighting;
    
    outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);
    
    outColor0 = vec4(pow(outputColor, vec3(1.0/2.2)), transparency);
}