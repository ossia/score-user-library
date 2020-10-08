import Score 1.0

Script {
  // Declare our inputs & outputs
  FloatSlider { id: in1; min: 20; max: 800; init: 440; objectName: "Frequency" }
  AudioOutlet { id: out1 }
  
  // Index to keep track of the phase
  property real phase: 0;

  tick: function(token, state) {
    var arr = [ ];

    // How many samples we must write
    var n = token.physical_write_duration(state.model_to_samples);
    
    if(n > 0) {
      // Computer the sin() coefficient
      var freq = in1.value;

      // Notice how we get sample_rate from state.
      var phi = 2 * Math.PI * freq / state.sample_rate;

      // Where we must start to write samples
      var i0 = token.physical_start(state.model_to_samples);

      // Fill our array
      for(var s = 0; s < n; s++) {
        phase += phi;
        var sample = Math.sin(phase);
        sample = freq > 0 ? sample : 0;
        arr[i0 + s] = 0.3 * sample;
      }
    }

    // Write two audio channels, which will give stereo output by default in score.
    out1.setChannel(0, arr);
    out1.setChannel(1, arr);
  }
}
