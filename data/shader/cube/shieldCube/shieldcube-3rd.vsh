#version 120

uniform int animationTime;


uniform vec3 segPos;
uniform vec3 m_Collisions[8];
uniform float m_TexCoordMult;
uniform int m_CollisionNum;


uniform vec3 normals[6];


uniform vec3 quadPosMark[6];
uniform vec3 texOrder[12];

const float tiling = 0.0625;
const float tilingH = 0.03;
const float adi = 0.00485;

//some crappy ATI cards do not support varying arrays
varying float dist0;
varying float dist1;
varying float dist2;
varying float dist3;
varying float dist4;
varying float dist5;
varying float dist6;
varying float dist7;

void main()
{

	float indexInfo = gl_Vertex.x;
	
	
	float blue =  floor(indexInfo / 1048576.0);
	indexInfo -= blue * 1048576.0;
	
	float green =  floor(indexInfo / 65536.0);
	indexInfo -= green * 65536.0;
	
	float red =  floor(indexInfo / 4096.0);
	indexInfo -= red * 4096.0;
	
	float vIndex = floor(indexInfo);
	indexInfo -= vIndex;
	
	

	float info = gl_Vertex.y;
	
	float extFlag =  floor(info / 2097152.0);
	info -= extFlag * 2097152.0;
	
	float animatedE =  floor(info / 1048576.0);
	info -= animatedE * 1048576.0;
	
	float hitPointsE =  floor(info / 131072.0) ;
	info -= hitPointsE * 131072.0;
	
	float typeE =  floor(info / 512.0) ;
	info -= typeE * 512.0;
	
	float layerE =  floor(info * 0.03125) ; // / 32.0
	info -= layerE * 32.0;
	
	float sideId =  (floor(info * 0.25)); // /4.0
	info -= sideId * 4.0;
	
	float vertNumCodeE = (floor(info));


	#IFDEF threeComp
	float zPos = floor(gl_Vertex.z / 65536.0); 
	float zIndex = gl_Vertex.z - (zPos * 65536.0);
	float yPos = floor(zIndex * 0.00390625); //divided by 256 
	float xPos = ( zIndex - (yPos * 256)); 
	#ENDIF

	
	float type = typeE;

	vec2 texCoords;
	
	float mVertNum = (vertNumCodeE) * 0.25;
	float mTex = (extFlag) * 0.25;
	
	vec3 occlusion =  vec3(max(0.05, red * 0.0625), max(0.05, green * 0.0625), max(0.05, blue * 0.0625)); // / 16
	
	
	
	float textureIndex = layerE;
	
	type += animatedE * animationTime;
	
	float xIndex = mod(type, 16.0);
	float yIndex = floor(type * 0.0625 ); // / 16.0
	
	
	int sInt = int(sideId);
	vec3 normal = normals[sInt];
	vec3 qpm = quadPosMark[sInt];
	
	
	vec2 quad = vec2(
			mod(floor(mTex * (2.0)), 2.0), 
			mod(floor(mTex * (4.0)), 2.0)
			);
	//either 0,0; 0,1; 1,1; 1,0
	
	
	
	
	 //8,8,8 = 8736
	float z = floor(vIndex * 0.00390625); //divided by 256
	float y = floor((vIndex - z * 256.0) * 0.0625);
	float x = vIndex - (y * 16.0 + z * 256.0);
	
	
	vec3 vertexPos = vec3(x-8.0,y-8.0,z-8.0);
	
	
	
	
	float xP = ((1.0 - (abs(normal.x))) * -0.5) + mod(floor(mVertNum * qpm.x), 2.0);
	float yP = ((1.0 - (abs(normal.y))) * -0.5) + mod(floor(mVertNum * qpm.y), 2.0);
	float zP = ((1.0 - (abs(normal.z))) * -0.5) + mod(floor(mVertNum * qpm.z), 2.0);
	
	vertexPos += vec3(xP,yP,zP) + (normal * 0.5);	
	
	
	
	
	vec2 adip = vec2(
	((1.0 -((quad.x)*adi)) + (abs(quad.x - 1.0)*adi)), 
	((1.0 -((quad.y)*adi)) + (abs(quad.y - 1.0)*adi)));

	texCoords = vec2(quad.x *tiling, quad.y *tiling );

	
	
	vec2 vcord = vec2(texCoords.x, texCoords.y);
	
	vec2 overlayTexCoords = ceil(hitPointsE / 512.0)*vec2(vcord.x + 0.125 * hitPointsE, vcord.y);
	
	vec2 mainTexCoords = vec2( texCoords.x + tiling * xIndex, texCoords.y + tiling * yIndex);
	
	#IFDEF threeComp
	float segPosX = (xPos - 128.0) * 16.0;
	float segPosY = (yPos - 128.0) * 16.0;
	float segPosZ = (zPos - 128.0) * 16.0;
	vertexPos.x += segPosX ;
	vertexPos.y += segPosY ;
	vertexPos.z += segPosZ ;
	#ENDIF
	
	//calculateLight(normal, vertexPos);
	
	mainTexCoords += adip;
	
	//note: this is a directional light! 
	//lightDir = normalize(gl_LightSource[0].position.xyz);

	vec4 vPos = gl_ModelViewMatrix * vec4(vertexPos,1.0); 
	
	
	gl_TexCoord[0].xy = quad;
	
	vec3 viewDir = normalize(-(vPos.xyz));
	
	gl_Position =  gl_ProjectionMatrix * vPos;
	
	
	dist0 = length(vertexPos.xyz - m_Collisions[0]);
	dist1 = length(vertexPos.xyz - m_Collisions[1]);
	dist2 = length(vertexPos.xyz - m_Collisions[2]);
	dist3 = length(vertexPos.xyz - m_Collisions[3]);
	dist4 = length(vertexPos.xyz - m_Collisions[4]);
	dist5 = length(vertexPos.xyz - m_Collisions[5]);
	dist6 = length(vertexPos.xyz - m_Collisions[6]);
	dist7 = length(vertexPos.xyz - m_Collisions[7]);
	
	
	
	
	

	
}

