#version 460

in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat3 normalMatrix;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;

void main() {
    tangent = at_tangent;

    geoNormal = normalMatrix * vaNormal;
    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    
    vec4 viewPos = modelViewMatrix * vec4(vaPosition + chunkOffset, 1.0);
    viewSpacePosition = viewPos.xyz;
    
    gl_Position = projectionMatrix * viewPos;
}