/*#version 460 compatibility

in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main() {
    geoNormal = normalMatrix * vaNormal;
    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    
    vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1.0);
    viewSpacePosition = viewPos.xyz;
    
    gl_Position = projectionMatrix * viewPos;
}*/

#version 460 compatibility

out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main() {
    geoNormal = gl_NormalMatrix * gl_Normal;

    blockColor = gl_Color;

    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    gl_Position = ftransform();
}