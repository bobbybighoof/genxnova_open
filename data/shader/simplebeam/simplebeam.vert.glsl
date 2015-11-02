#version 120



uniform float size;

varying vec3 outOrigPos;
varying vec3 outNormal;


void main()
{
	
	outOrigPos = gl_Vertex.xyz;
	outOrigPos.x *= size;
	gl_TexCoord[0] = gl_MultiTexCoord0;
	
	outNormal = normalize( gl_NormalMatrix * gl_Normal );
	
	gl_Position = gl_ModelViewProjectionMatrix * vec4(outOrigPos, 1.0);
	
	
}

