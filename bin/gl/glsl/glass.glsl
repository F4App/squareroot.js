//#vertex
attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;

uniform mat4 uConcatMatrix;
uniform mat3 uNormalMatrix;
uniform mat4 uMatrix;

uniform vec3 uEyePosition;


varying vec3 t;
varying vec3 tr;
varying vec3 tg;
varying vec3 tb;
varying float fac;

const vec3 chromaticDispertion = vec3(0.90, 0.97, 1.04);
// const vec3 chromaticDispertion = vec3(0, 0, 0);
const float bias = 0.9;
const float scale = 0.7;
const float power = 1.1;
     
void main() {
	vec3 vNormal = -normalize(uNormalMatrix * aVertexNormal);

	vec3 worldPosition = (uMatrix * vec4(aVertexPosition, 1.0)).xyz;
	vec3 incident = normalize(worldPosition - uEyePosition);

	t = reflect(incident, vNormal);	
	tr = refract(incident, vNormal, chromaticDispertion.x);
	tg = refract(incident, vNormal, chromaticDispertion.y);
	tb = refract(incident, vNormal, chromaticDispertion.z);

	fac = bias + scale * pow(1.0 + dot(incident, vNormal), power);

	gl_Position = uConcatMatrix * vec4(aVertexPosition, 1.0);
}

//#fragment
#ifdef GL_ES
precision highp float;
#endif

uniform samplerCube uCubemap;
              
varying vec3 t;
varying vec3 tr;
varying vec3 tg;
varying vec3 tb;
varying float fac;

void main() {
	// vec4 ref = vec4(0, 0, 0, 1.0);
	vec4 ref = textureCube(uCubemap, t);

	vec4 ret = vec4(0, 0, 0, 1.0);
	ret.r = textureCube(uCubemap, tr).r;
	ret.g = textureCube(uCubemap, tg).g;
	ret.b = textureCube(uCubemap, tb).b;

	vec3 c = (ret * fac + ref * (1.0 - fac)).rgb;
	// c *= 0.75;
	
	gl_FragColor = vec4(c, 1.0);
}



