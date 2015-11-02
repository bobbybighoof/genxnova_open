#version 120
uniform sampler2D tex;
varying float distance;
varying float time;
varying vec4 color;

void main()
{
	vec4 pColor = texture2D(tex,   vec2(gl_TexCoord[0].x, gl_TexCoord[0].z));
	
	float tt = abs(gl_TexCoord[0].s - 0.5);
	
	float alpha = pow(max(0.0,(0.5-tt)), 1.2) * 5.0;
	
		
	float p = min(1.0, pow(gl_TexCoord[0].t , 0.6));
	float p2 = min(1.0, pow(1.0-gl_TexCoord[0].t, 0.6));
	
	alpha *= p;
	alpha *= p2;
	
	
	if(alpha < 0.1){
		discard;
	}
	alpha -= 0.1;
	//pColor *= 2.0;
	gl_FragColor =  vec4(pColor.x,pColor.y,pColor.z, alpha)*(alpha+0.4)*color;//vec4(1,1,1,0.5f);
}