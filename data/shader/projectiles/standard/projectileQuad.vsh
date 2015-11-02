#version 120

varying vec3 clr;

varying float time;



void main()
{

	gl_TexCoord[0].st = vec2(mod(floor(gl_MultiTexCoord0.w * 2.0), 2.0), mod(floor(gl_MultiTexCoord0.w * 4.0), 2.0));
	
	clr = vec3(gl_MultiTexCoord0.xyz);
	
	gl_Position = gl_ModelViewProjectionMatrix * vec4(gl_Vertex.xyz, 1.0);
	
	time = gl_Vertex.w;
	
	gl_FrontColor = gl_Color;
	
}