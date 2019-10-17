
uniform sampler2D u_texture;
uniform float u_time;

varying vec2 v_texCoords;
varying vec3 v_fragPosition;

// retorna cor invertida
vec3 invert(vec3 color) {
    vec3 one = vec3(1.0,1.0,1.0);
    return vec3(abs(one.x-color.x), abs(one.y-color.y), abs(one.z-color.z));
    //return color;

}

// retorna cor em escala de cinza
/*vec3 toGrayscale(vec3 color) {
    //float mv = (color.x+color.y+color.z)/3;
    float hv = color.r*0.2989+color.g*0.5870+color.b*0.1140;
    return vec3(hv,hv,hv);
}*/

vec3 blur(sampler2D tex, vec2 texCoords) {
    // cria um vetor 3x3 contendo o deslocamento de cada pixel adjacente a este
    // (do kernel)
    float offset = 1.0 / 300.0;
    vec2 kernelOffsets[9];
        kernelOffsets[0]  = vec2(-offset,  offset);     // cima-esquerda
        kernelOffsets[1]  = vec2(      0.0,  offset);      // cima-meio
        kernelOffsets[2]  = vec2( offset,  offset);      // cima-direita
        kernelOffsets[3]  = vec2(-offset,       0.0);      // meio-esquerda
        kernelOffsets[4]  = vec2(      0.0,       0.0);      // meio-meio
        kernelOffsets[5]  = vec2( offset,       0.0);      // meio-direita
        kernelOffsets[6]  = vec2(-offset, -offset);      // baixo-esquerda
        kernelOffsets[7]  = vec2(      0.0, -offset);      // baixo-meio
        kernelOffsets[8]  = vec2( offset, -offset);      // baixo-direita
    

    
    // kernel de blur
    float constantWeight = 1.0 / 16.0;
    float kernelWeights[9];
    kernelWeights[0] = constantWeight;
    kernelWeights[1] = constantWeight*2.0; 
    kernelWeights[2] = constantWeight;
    kernelWeights[3] = constantWeight*2.0; 
    kernelWeights[4] = constantWeight*4.0;   
    kernelWeights[5] = constantWeight*2.0;
    kernelWeights[6] = constantWeight;   
    kernelWeights[7] = constantWeight*2.0; 
    kernelWeights[8] = constantWeight;
    
    // kernel de aguçar imagem (sharpen)
    //float kernelWeights[9] = float[](
    //    -1, -1, -1,
    //    -1,  9, -1,
    //    -1, -1, -1
    //);

    // kernel de detectar bordas
    //float kernelWeight[9] = float[](
    //     1,  1,  1,
    //     1, -9,  1,
    //     1,  1,  1
    //);

    // olha na textura quais são as cores dos vizinhos deste pixel
    vec3 neighborsColors[9];
    for (int i = 0; i < 9; i++) {
        neighborsColors[i] = texture2D(tex, texCoords + kernelOffsets[i]).xyz;
    }

    // aplica a convolução, fazendo com que a cor resultante deste pixel
    // seja uma combinação das cores dos pixels adjacentes (3x3) multiplicadas
    // pelos pesos (do kernel)
    vec3 resultingColor = vec3(0.0);
    for (int i = 0; i < 9; i++) {
        resultingColor += neighborsColors[i] * kernelWeights[i];
    }

    return resultingColor;
}


void main() {
    vec3 colorFromTexture = texture2D(u_texture, v_texCoords).xyz;
    gl_FragColor = vec4(blur(u_texture, v_texCoords), 1.0);
}