#version 120

varying vec3 outOrigPos;
varying vec3 outNormal;

uniform sampler3D noiseTex;
uniform vec4 thrustColor0;
uniform vec4 thrustColor1;
uniform float ticks;
uniform float texCoordMult;
uniform float size;
uniform float sizeInv;
uniform float lenDiff;

void main()
{
	float cosang;
	float edgeAlpha;
	vec4 tc;
	    
	float noiseval;
	float noiseval2;
	
	float heatfactor = thrustColor0.a;

	float heat = 1-clamp((outOrigPos.z*0.5), 0.0, 1.0);
	
	vec2 len = vec2(outOrigPos.y, outOrigPos.x*size);
	
	heat *= clamp(1.0-length(len)*2.222, 0.0, 1.0);
	
	
	float x = (gl_TexCoord[0].x) * 0.2 - ticks;
	float y = (gl_TexCoord[0].y * texCoordMult) * 0.5 + (ticks*heatfactor);
	float z = ticks;
	vec4 noise = texture3D(noiseTex, vec3(x, y, z));
	vec4 noise2 = texture3D(noiseTex, vec3((gl_TexCoord[0].x)+ticks*2.0, (gl_TexCoord[0].y * texCoordMult) + ticks, ticks * 3.0));
	
	noiseval2 = pow(noise2.x,1.0+1.5*heatfactor);
	noiseval = pow(noise.x*1.4, 0.5*heatfactor);
	 
	tc.rgb = ( 2.5*noiseval*thrustColor1.rgb + 10.0*noiseval*pow(heat*heatfactor,3.5)*thrustColor0.rgb); 
	
	float xx = (gl_TexCoord[0].x - 0.5) *0.5*sizeInv;
	float yy = (gl_TexCoord[0].y - 0.5) *0.5;
	
	
	
	edgeAlpha = 1.0 - max(0.0,  length(xx));
	
	edgeAlpha = max(0.0, edgeAlpha-0.1) * 2.0;
	
	//if((gl_TexCoord[0].y) <	 0.5){
		edgeAlpha *= 1.0 - abs(1.0-pow(gl_TexCoord[0].y,0.17*pow(lenDiff,3.0)) );
	//}
	
	tc.a = (edgeAlpha) * pow(heat, 0.85 + 25.0 * (1.01-heatfactor));
	
	tc.rgb *= noiseval2;
	
	if((tc.a - 0.6) < 0.0501 ){
		discard;
	}
	
	gl_FragColor = tc;
	
	gl_FragColor.a = max(0.0, gl_FragColor.a - 0.6);
}





   