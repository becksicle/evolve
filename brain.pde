class Neuron {
  Neuron[] inputs;
  float[] weights;
  float bias;
  float val = 0;
  
  Neuron(Neuron[] inputs, float[] weights, float bias) {
    this.inputs = inputs;
    this.weights = weights;
    this.bias = bias;
  }
  
  Neuron() {
  }
  
  void calculateValue() {
    float v = 0;
    for(int i=0; i < inputs.length; i++) {
      v += inputs[i].val * weights[i];
    }
    v += bias;
    val = 1 / (1 + exp(-v));
  }
}

class Brain {
  // one set for all the prey within FOV and 
  // one set for all the predators within FOV
  Neuron[] inputs;
  
  // 1 for direction, 1 for speed
  Neuron[] outputs;

  Brain(int inputSize) {
    inputs = new Neuron[inputSize];
    for(int i=0; i < inputs.length; i++) {
      inputs[i] = new Neuron();
    }
    
    outputs = new Neuron[2];
    for (int i=0; i < outputs.length; i++) {
      outputs[i] = new Neuron(inputs, randomWeights(inputs.length), randomBias());
    }
  }
  
  void calculateOutput() {
    for(int i=0; i < outputs.length; i++) {
      outputs[i].calculateValue();
    }
  }
  
  float[] randomWeights(int size) {
    float[] weights = new float[size];
    for(int i=0; i < size; i++) { 
      weights[i] = randomGaussian();
    }
    return weights;
  }
  
  float randomBias() {
    return randomGaussian();
  }
  
  void resetInputs() {
    for(Neuron input : inputs) {
      input.val = 0;
    }
  }
}
