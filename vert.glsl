#define PROCESSING_TEXTURE_SHADER



//properties automaticaly set by processing for
// a PROCESSING_TEXTURE_SHADER 
uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 vertex;
attribute vec4 color;
attribute vec2 texCoord;

//properties that we set for the frag shader
varying vec4 vertColor;
varying vec4 uvs;

// this function runs for each vertex 
// its primary purpose is to set gl_position
//multiply uvs being passed in my matrix 
void main(){
	//set uvs for frag shader
	uvs = texMatrix*vec4(texCoord,1.0,1.0);

	//set vertex screen position for the gpu
	gl_Position = transform*vertex;

}