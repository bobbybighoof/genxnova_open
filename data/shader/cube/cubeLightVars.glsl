
uniform mat4 v_inv;
varying vec3 lightDir;
varying vec4 vPos;
varying vec3 normalVec;
varying vec3 viewDirection;
varying vec3 tangent;
varying vec3 binormal;
const float shininess = 30.0;
const float attenuation = 1.1;

#IFDEF nospotlights
#ELSEIF vertexLighting
#ELSE 
uniform int spotCount;
#ENDIF 