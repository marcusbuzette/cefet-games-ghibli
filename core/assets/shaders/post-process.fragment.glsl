
uniform sampler2D u_texture;
uniform float u_time;

varying vec2 v_texCoords;
varying vec3 v_fragPosition;

// retorna cor invertida
vec3 invert(vec3 color) {
    return vec3(1.0-color);
}

// retorna cor em escala de cinza
vec3 toGrayscale(vec3 color) {
    return vec3(color*0.33);
}


vec3 blur(sampler2D tex, vec2 texCoords) {
    // cria um vetor 3x3 contendo o deslocamento de cada pixel adjacente a este
    // (do kernel)
    float offset = 1.0 / 300.0;
    vec2 kernelOffsets[9];
    kernelOffsets[0] = vec2(-offset,  offset);
    kernelOffsets[1] = vec2(      0,  offset);
    kernelOffsets[2] = vec2( offset,  offset);
    kernelOffsets[3] = vec2(-offset,       0);
    kernelOffsets[4] = vec2(      0,       0);
    kernelOffsets[5] = vec2( offset,       0);
    kernelOffsets[6] = vec2(-offset, -offset);
    kernelOffsets[7] = vec2(      0, -offset);
    kernelOffsets[8] = vec2( offset, -offset);

/*
    (
             // meio-esquerda
        ,      // meio-meio
        ,      // meio-direita
        ,      // baixo-esquerda
        ,      // baixo-meio
               // baixo-direita
    );
*/
    
    // kernel de blur
    float constantWeight = 1.0 / 16.0;
    float kernelWeights[9] = float[](
        constantWeight,   constantWeight*2.0, constantWeight,
        constantWeight*2.0, constantWeight,   constantWeight*2.0,
        constantWeight,   constantWeight*2.0, constantWeight
    );

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
    vec3 colorFromTexture = texture(u_texture, v_texCoords).xyz;
    // colorFromTexture = toGrayscale(colorFromTexture)
    gl_FragColor = vec4(blur(u_texture, v_texCoords), 1.0);
}