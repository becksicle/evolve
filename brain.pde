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
  
  Neuron(Neuron other) {
    if(other.inputs != null) {
      inputs = new Neuron[other.inputs.length];
      for(int i=0; i < inputs.length; i++) {
        inputs[i] = new Neuron(other.inputs[i]);
      }
    }
    
    if(other.weights != null) {
      weights = new float[other.weights.length];
      for(int i=0; i < weights.length; i++) {
        weights[i] = other.weights[i];
      }
    }
    
    bias = other.bias;
    val = other.val;
  }
  
  void calculateValue() {
    float v = 0;
    for(int i=0; i < inputs.length; i++) {
      //println(i+" : "+inputs[i].val + " x "+weights[i]);
      v += inputs[i].val * weights[i];
    }
    //println("bias: "+bias);
    v += bias;
    val = min(1, max(-1, v));
    //println("v = "+val);
    //val = 1 / (1 + exp(-v));
    //println(this.toString()+" :raw v: "+v + " val: "+val);
  }
  
  void mutate() {
    for(int i=0; i < inputs.length; i++) {
      float mutation = random(-0.1, 0.1);
      weights[i] += mutation;
      weights[i] = min(1, max(-1, weights[i]));
    }
    
  }
  
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append("weights: ");
    for(int i=0; i < weights.length; i++) {
      sb.append(nf(weights[i], 0, 2)).append(" ");
    }
    sb.append("bias: ").append(nf(bias, 0, 2));
    return sb.toString();
  }
}

class Brain {
  // one set for all the prey within FOV and 
  // one set for all the predators within FOV
  Neuron[] inputs;
  
  Neuron[] hiddenLayer;
  
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
  
  Brain(Brain other) {
    inputs = new Neuron[other.inputs.length];
    for(int i=0; i < inputs.length; i++) {
      inputs[i] = new Neuron(other.inputs[i]);
    }
    
    outputs = new Neuron[other.outputs.length];
    for(int i=0; i < outputs.length; i++) {
      outputs[i] = new Neuron(other.outputs[i]);
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
      weights[i] = random(-1, 1);
    }
    
    //weights[int(random(weights.length))] = random(1);
    return weights;
  }
  
  float randomBias() {
    return random(-1, 1);
  }
  
  void resetInputs() {
    for(Neuron input : inputs) {
      input.val = 0;
    }
  }
  
  void mutate() {
    for(Neuron n : outputs) {
      n.mutate();
    }
  }
  
  String toString() {
    StringBuffer sb = new StringBuffer();
    for(Neuron n : outputs) {
      sb.append(n).append("\n");
    }
    return sb.toString();
  }
}
